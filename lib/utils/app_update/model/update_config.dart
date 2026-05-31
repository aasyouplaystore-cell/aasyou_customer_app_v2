enum UpdateStatus { upToDate, optionalUpdate, forceUpdate }

class UpdateConfig {
  final UpdateStatus status;
  final String title;
  final String message;
  final String iosStoreUrl;
  final String androidStoreUrl;
  final bool updateAvailable;
  final String updateType;
  final String? minSupportedVersion;
  final String? latestVersion;

  const UpdateConfig({
    required this.status,
    required this.title,
    required this.message,
    required this.iosStoreUrl,
    required this.androidStoreUrl,
    this.updateAvailable = false,
    this.updateType = 'optional',
    this.minSupportedVersion,
    this.latestVersion,
  });

  factory UpdateConfig.upToDate() => const UpdateConfig(
        status: UpdateStatus.upToDate,
        title: '',
        message: '',
        iosStoreUrl: '',
        androidStoreUrl: '',
      );
}
