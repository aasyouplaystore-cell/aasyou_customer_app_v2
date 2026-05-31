part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationItem> notifications;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final int unreadCount;

  NotificationLoaded({
    required this.notifications,
    required this.hasReachedMax,
    required this.isLoadingMore,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props =>
      [notifications, hasReachedMax, isLoadingMore, unreadCount];
}

class NotificationFailed extends NotificationState {
  final String error;

  NotificationFailed({required this.error});

  @override
  List<Object?> get props => [error];
}
