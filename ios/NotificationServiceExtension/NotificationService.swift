import UserNotifications

/// Notification Service Extension that downloads the remote image referenced
/// in the FCM payload and attaches it to the notification so iOS can render
/// the rich (image) notification in background / terminated state.
///
/// The backend must send the push with `mutable-content: 1` (FCM auto-injects
/// this when `notification.image` or `apns.fcm_options.image` is present) and
/// either:
///   - `apns.fcm_options.image = "<url>"`, or
///   - `data.image = "<url>"` (custom key used elsewhere in this app).
class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent
        guard let bestAttempt = bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        let userInfo = request.content.userInfo

        // Try common locations for the image URL, in order of FCM convention.
        var imageUrlString: String?
        if let fcmOptions = userInfo["fcm_options"] as? [String: Any],
           let image = fcmOptions["image"] as? String {
            imageUrlString = image
        } else if let image = userInfo["image"] as? String {
            imageUrlString = image
        } else if let aps = userInfo["aps"] as? [String: Any],
                  let fcmOptions = aps["fcm_options"] as? [String: Any],
                  let image = fcmOptions["image"] as? String {
            imageUrlString = image
        }

        guard let urlString = imageUrlString,
              let url = URL(string: urlString) else {
            contentHandler(bestAttempt)
            return
        }

        URLSession.shared.downloadTask(with: url) { [weak self] tempURL, _, _ in
            defer {
                if let self = self, let bestAttempt = self.bestAttemptContent {
                    contentHandler(bestAttempt)
                }
            }

            guard let tempURL = tempURL else { return }

            // Preserve the file extension so iOS recognises the attachment type.
            let fileExtension = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
            let destination = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(fileExtension)

            do {
                try FileManager.default.moveItem(at: tempURL, to: destination)
                let attachment = try UNNotificationAttachment(
                    identifier: "image",
                    url: destination,
                    options: nil
                )
                self?.bestAttemptContent?.attachments = [attachment]
            } catch {
                // Silently fall back to a text-only notification if anything fails.
            }
        }.resume()
    }

    /// Called by iOS just before the extension is killed. We must hand back
    /// whatever we have so far (image may not have finished downloading).
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler,
           let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
