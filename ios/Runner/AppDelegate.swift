import Flutter
import UIKit
import GoogleMaps
import Firebase
import FirebaseAuth
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    application.registerForRemoteNotifications()

    GMSServices.provideAPIKey("AIzaSyCAnrqmgpy6k2-wXI71-BSfEfQNw68-K3s")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Firebase phone-auth reCAPTCHA fallback (always used on iOS Simulator,
  // and on real devices when silent APNs verification fails) redirects back
  // to the app via the reversed-client-ID URL scheme registered in Info.plist.
  // Without this override, the redirect arrives in Flutter plugins instead of
  // Firebase Auth, so `codeSent` never fires and the UI hangs on the loader.
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if Auth.auth().canHandle(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
}