import '../../../config/helper.dart';

class OrderTransactionsModel {
  final bool? success;
  final String? message;
  final OrderTransactionsData? data;

  OrderTransactionsModel({
    this.success,
    this.message,
    this.data,
  });

  factory OrderTransactionsModel.fromJson(Map<String, dynamic> json) {
    return OrderTransactionsModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null
          ? OrderTransactionsData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}

class OrderTransactionsData {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final List<OrderTransactionsDetail> data;

  OrderTransactionsData({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    List<OrderTransactionsDetail>? data,
  }) : data = data ?? const [];

  factory OrderTransactionsData.fromJson(Map<String, dynamic> json) {
    return OrderTransactionsData(
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
      perPage: parseInt(json['per_page']),
      total: parseInt(json['total']),
      data: _parseTransactions(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
    'data': data.map((e) => e.toJson()).toList(),
  };

  static List<OrderTransactionsDetail> _parseTransactions(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(OrderTransactionsDetail.fromJson)
        .toList();
  }
}

class OrderTransactionsDetail {
  final int? id;
  final String? uuid;
  final int? orderId;
  final int? userId;
  final String? transactionId;
  final String? amount;
  final String? currency;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? message;
  final PaymentDetails? paymentDetails;
  final String? createdAt;
  final String? updatedAt;

  OrderTransactionsDetail({
    this.id,
    this.uuid,
    this.orderId,
    this.userId,
    this.transactionId,
    this.amount,
    this.currency,
    this.paymentMethod,
    this.paymentStatus,
    this.message,
    this.paymentDetails,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderTransactionsDetail.fromJson(Map<String, dynamic> json) {
    return OrderTransactionsDetail(
      id: parseInt(json['id']),
      uuid: parseString(json['uuid']),
      orderId: parseInt(json['order_id']),
      userId: parseInt(json['user_id']),
      transactionId: parseString(json['transaction_id']),
      amount: parseString(json['amount']),
      currency: parseString(json['currency']),
      paymentMethod: parseString(json['payment_method']),
      paymentStatus: parseString(json['payment_status']),
      message: parseString(json['message']),
      paymentDetails: json['payment_details'] != null
          ? PaymentDetails.fromJson(json['payment_details'])
          : null,
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'order_id': orderId,
    'user_id': userId,
    'transaction_id': transactionId,
    'amount': amount,
    'currency': currency,
    'payment_method': paymentMethod,
    'payment_status': paymentStatus,
    'message': message,
    'payment_details': paymentDetails?.toJson(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PaymentDetails {
  final String? id;
  final String? entity;
  final double? amount;
  final String? currency;
  final String? status;
  final int? orderId;
  final String? invoiceId;
  final bool? international;
  final String? method;
  final int? amountRefunded;
  final String? refundStatus;
  final bool? captured;
  final String? description;
  final String? cardId;
  final String? bank;
  final String? wallet;
  final String? vpa;
  final String? email;
  final String? contact;
  final Notes? notes;
  final int? fee;
  final int? tax;
  final String? errorCode;
  final String? errorDescription;
  final String? errorSource;
  final String? errorStep;
  final String? errorReason;
  final AcquirerData? acquirerData;
  final int? createdAt;
  final String? reward;
  final int? baseAmount;

  PaymentDetails({
    this.id,
    this.entity,
    this.amount,
    this.currency,
    this.status,
    this.orderId,
    this.invoiceId,
    this.international,
    this.method,
    this.amountRefunded,
    this.refundStatus,
    this.captured,
    this.description,
    this.cardId,
    this.bank,
    this.wallet,
    this.vpa,
    this.email,
    this.contact,
    this.notes,
    this.fee,
    this.tax,
    this.errorCode,
    this.errorDescription,
    this.errorSource,
    this.errorStep,
    this.errorReason,
    this.acquirerData,
    this.createdAt,
    this.reward,
    this.baseAmount,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      id: parseString(json['id']),
      entity: parseString(json['entity']),
      amount: parseDouble(json['amount']),
      currency: parseString(json['currency']),
      status: parseString(json['status']),
      orderId: parseInt(json['order_id']),
      invoiceId: parseString(json['invoice_id']),
      international: parseBool(json['international']),
      method: parseString(json['method']),
      amountRefunded: parseInt(json['amount_refunded']),
      refundStatus: parseString(json['refund_status']),
      captured: parseBool(json['captured']),
      description: parseString(json['description']),
      cardId: parseString(json['card_id']),
      bank: parseString(json['bank']),
      wallet: parseString(json['wallet']),
      vpa: parseString(json['vpa']),
      email: parseString(json['email']),
      contact: parseString(json['contact']),
      notes: json['notes'] != null ? Notes.fromJson(json['notes']) : null,
      fee: parseInt(json['fee']),
      tax: parseInt(json['tax']),
      errorCode: parseString(json['error_code']),
      errorDescription: parseString(json['error_description']),
      errorSource: parseString(json['error_source']),
      errorStep: parseString(json['error_step']),
      errorReason: parseString(json['error_reason']),
      acquirerData: json['acquirer_data'] != null
          ? AcquirerData.fromJson(json['acquirer_data'])
          : null,
      createdAt: parseInt(json['created_at']),
      reward: parseString(json['reward']),
      baseAmount: parseInt(json['base_amount']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'entity': entity,
    'amount': amount,
    'currency': currency,
    'status': status,
    'order_id': orderId,
    'invoice_id': invoiceId,
    'international': international,
    'method': method,
    'amount_refunded': amountRefunded,
    'refund_status': refundStatus,
    'captured': captured,
    'description': description,
    'card_id': cardId,
    'bank': bank,
    'wallet': wallet,
    'vpa': vpa,
    'email': email,
    'contact': contact,
    'notes': notes?.toJson(),
    'fee': fee,
    'tax': tax,
    'error_code': errorCode,
    'error_description': errorDescription,
    'error_source': errorSource,
    'error_step': errorStep,
    'error_reason': errorReason,
    'acquirer_data': acquirerData?.toJson(),
    'created_at': createdAt,
    'reward': reward,
    'base_amount': baseAmount,
  };
}

class Notes {
  final int? userId;
  final String? timeOfPayment;

  Notes({
    this.userId,
    this.timeOfPayment,
  });

  factory Notes.fromJson(Map<String, dynamic> json) {
    return Notes(
      userId: parseInt(json['user_id']),
      timeOfPayment: parseString(json['timeOfPayment']),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'timeOfPayment': timeOfPayment,
  };
}

class AcquirerData {
  final String? bankTransactionId;

  AcquirerData({this.bankTransactionId});

  factory AcquirerData.fromJson(Map<String, dynamic> json) {
    return AcquirerData(
      bankTransactionId: parseString(json['bank_transaction_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'bank_transaction_id': bankTransactionId,
  };
}
