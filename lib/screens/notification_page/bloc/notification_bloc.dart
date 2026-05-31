import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/notification_page/model/notification_list_model.dart';
import 'package:aasyou/screens/notification_page/repo/notification_repo.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<FetchMoreNotifications>(_onFetchMoreNotifications);
    on<MarkAsReadSpecificNotification>(_onMarkAsReadSpecificNotification);
    on<MarkAllAsRead>(_onMarkAllAsRead);
  }

  final repository = NotificationRepository();

  int currentPage = 1;
  int perPage = 10;
  bool hasReachedMax = false;
  bool isLoadingMore = false;

  /// ✅ Initial fetch — resets pagination state
  Future<void> _onFetchNotifications(
    FetchNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    try {
      currentPage = 1;
      hasReachedMax = false;
      isLoadingMore = false;

      final response = await repository.fetchNotifications(
        page: currentPage,
        perPage: perPage,
      );

      final notificationsResponse = NotificationsResponse.fromJson(response);

      if (notificationsResponse.success == true) {
        final notifications = notificationsResponse.data?.notifications ?? [];
        final pagination = notificationsResponse.data?.pagination;

        hasReachedMax =
            (pagination?.currentPage ?? 1) >= (pagination?.lastPage ?? 1) ||
                notifications.length < perPage;

        final unreadCount = notificationsResponse.data?.unreadCount ?? 0;

        emit(NotificationLoaded(
          notifications: notifications,
          hasReachedMax: hasReachedMax,
          isLoadingMore: false,
          unreadCount: unreadCount,
        ));
      } else {
        emit(NotificationFailed(
          error:
              notificationsResponse.message ?? 'Failed to fetch notifications',
        ));
      }
    } catch (e) {
      emit(NotificationFailed(error: e.toString()));
    }
  }

  /// ✅ Load more — appends next page without duplicates
  Future<void> _onFetchMoreNotifications(
    FetchMoreNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (hasReachedMax || isLoadingMore) return;

    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    isLoadingMore = true;

    // Emit loading-more state immediately so UI shows spinner
    emit(NotificationLoaded(
      notifications: currentState.notifications,
      hasReachedMax: currentState.hasReachedMax,
      isLoadingMore: true,
      unreadCount: currentState.unreadCount,
    ));

    try {
      currentPage += 1;

      final response = await repository.fetchNotifications(
        page: currentPage,
        perPage: perPage,
      );

      final notificationsResponse = NotificationsResponse.fromJson(response);

      if (notificationsResponse.success == true) {
        final newNotifications =
            notificationsResponse.data?.notifications ?? [];
        final pagination = notificationsResponse.data?.pagination;

        hasReachedMax =
            (pagination?.currentPage ?? 1) >= (pagination?.lastPage ?? 1) ||
                newNotifications.length < perPage;

        // Merge avoiding duplicates
        final updated = List<NotificationItem>.from(currentState.notifications);
        for (final item in newNotifications) {
          if (!updated.any((existing) => existing.id == item.id)) {
            updated.add(item);
          }
        }

        final unreadCount = notificationsResponse.data?.unreadCount ?? currentState.unreadCount;

        emit(NotificationLoaded(
          notifications: updated,
          hasReachedMax: hasReachedMax,
          isLoadingMore: false,
          unreadCount: unreadCount,
        ));
      } else {
        currentPage -= 1;
        emit(NotificationLoaded(
          notifications: currentState.notifications,
          hasReachedMax: currentState.hasReachedMax,
          isLoadingMore: false,
          unreadCount: currentState.unreadCount,
        ));
      }
    } catch (e) {
      currentPage -= 1;
      emit(NotificationLoaded(
        notifications: currentState.notifications,
        hasReachedMax: currentState.hasReachedMax,
        isLoadingMore: false,
        unreadCount: currentState.unreadCount,
      ));
    } finally {
      isLoadingMore = false;
    }
  }

  /// ✅ Mark specific notification as read
  Future<void> _onMarkAsReadSpecificNotification(
    MarkAsReadSpecificNotification event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      // 1. Optimistically update local state
      int unreadCount = currentState.unreadCount;
      final updatedNotifications = currentState.notifications.map((item) {
        if (item.id == event.notificationId) {
          if (item.isRead == false) {
            unreadCount = (unreadCount - 1).clamp(0, unreadCount + 1);
          }
          return item.copyWith(isRead: true);
        }
        return item;
      }).toList();

      emit(NotificationLoaded(
        notifications: updatedNotifications,
        hasReachedMax: currentState.hasReachedMax,
        isLoadingMore: currentState.isLoadingMore,
        unreadCount: unreadCount,
      ));

      // 2. Call API
      try {
        await repository.markAsRead(event.notificationId);
      } catch (e) {
        // Optional: revert state on error if needed, or just let it stay (will fix on next refresh)
      }
    }
  }

  /// ✅ Mark all notifications as read
  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      // 1. Optimistically update local state
      final updatedNotifications = currentState.notifications.map((item) {
        return item.copyWith(isRead: true);
      }).toList();

      emit(NotificationLoaded(
        notifications: updatedNotifications,
        hasReachedMax: currentState.hasReachedMax,
        isLoadingMore: currentState.isLoadingMore,
        unreadCount: 0,
      ));

      // 2. Call API
      try {
        await repository.markAllAsRead();
      } catch (e) {
        // Revert or show error toast? For now, we follow the pattern of silent failure or next-refresh fix.
      }
    }
  }
}
