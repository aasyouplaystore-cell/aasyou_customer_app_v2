abstract class AppUpdateEvent {}

/// Fired once on splash init — fetches version from API
class CheckAppUpdate extends AppUpdateEvent {}