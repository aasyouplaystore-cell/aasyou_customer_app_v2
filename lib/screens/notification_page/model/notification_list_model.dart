
import '../../../config/helper.dart';

class NotificationsResponse {
  final bool? success;
  final String? message;
  final NotificationsData? data;

  NotificationsResponse({
    this.success,
    this.message,
    this.data,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null
          ? NotificationsData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        if (data != null) 'data': data!.toJson(),
      };
}

class NotificationsData {
  final List<NotificationItem> notifications;
  final int? unreadCount;
  final Pagination? pagination;

  NotificationsData({
    this.notifications = const [],
    this.unreadCount,
    this.pagination,
  });

  factory NotificationsData.fromJson(Map<String, dynamic> json) {
    return NotificationsData(
      notifications: _parseNotifications(json['notifications']),
      unreadCount: parseInt(json['unread_count']),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'notifications': notifications.map((e) => e.toJson()).toList(),
        'unread_count': unreadCount,
        if (pagination != null) 'pagination': pagination!.toJson(),
      };

  static List<NotificationItem> _parseNotifications(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(NotificationItem.fromJson)
        .toList();
  }
}

class Pagination {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;

  Pagination({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
      perPage: parseInt(json['per_page']),
      total: parseInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'last_page': lastPage,
        'per_page': perPage,
        'total': total,
      };
}

class NotificationItem {
  final String? id;
  final int? userId;
  final int? storeId;
  final int? orderId;
  final String? type;
  final String? sentTo;
  final String? title;
  final String? message;
  final bool? isRead;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? data;
  final String? createdAt;
  final String? updatedAt;

  NotificationItem({
    this.id,
    this.userId,
    this.storeId,
    this.orderId,
    this.type,
    this.sentTo,
    this.title,
    this.message,
    this.isRead,
    this.metadata,
    this.data,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: parseString(json['id']),
      userId: parseInt(json['user_id']),
      storeId: parseInt(json['store_id']),
      orderId: parseInt(json['order_id']),
      type: parseString(json['type']),
      sentTo: parseString(json['sent_to']),
      title: parseString(json['title']),
      message: parseString(json['message']),
      isRead: parseBool(json['is_read']),
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : null,
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'store_id': storeId,
        'order_id': orderId,
        'type': type,
        'sent_to': sentTo,
        'title': title,
        'message': message,
        'is_read': isRead,
        'metadata': metadata,
        'data': data,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  NotificationItem copyWith({
    String? id,
    int? userId,
    int? storeId,
    int? orderId,
    String? type,
    String? sentTo,
    String? title,
    String? message,
    bool? isRead,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? data,
    String? createdAt,
    String? updatedAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storeId: storeId ?? this.storeId,
      orderId: orderId ?? this.orderId,
      type: type ?? this.type,
      sentTo: sentTo ?? this.sentTo,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Optional: convenience getters for common metadata patterns
  int? get orderItemReturnId => metadata?['order_item_return_id'] as int?;
  int? get orderItemId => metadata?['order_item_id'] as int?;
  String? get returnStatus => metadata?['return_status'] as String?;
  int? get sellerStatementId => metadata?['seller_statement_id'] as int?;
  String? get settlementReference =>
      metadata?['settlement_reference'] as String?;
  int? get walletTransactionId => metadata?['wallet_transaction_id'] as int?;
  String? get transactionType => metadata?['transaction_type'] as String?;
  String? get entryType => metadata?['entry_type'] as String?;
  int? get withdrawalRequestId => metadata?['withdrawal_request_id'] as int?;
}
