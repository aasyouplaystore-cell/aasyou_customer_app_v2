part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Triggered on first load or manual refresh — resets pagination
class FetchNotifications extends NotificationEvent {}

/// Triggered when user scrolls near the bottom to load next page
class FetchMoreNotifications extends NotificationEvent {}

class MarkAsReadSpecificNotification extends NotificationEvent {
  final String notificationId;

  MarkAsReadSpecificNotification({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllAsRead extends NotificationEvent {}
