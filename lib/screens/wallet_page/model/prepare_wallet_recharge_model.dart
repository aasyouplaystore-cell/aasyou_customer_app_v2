
import 'package:aasyou/config/helper.dart';

class PrepareWalletRechargeModel {
  final bool? success;
  final String? message;
  final PrepareWalletRechargeData? data;

  PrepareWalletRechargeModel({
    this.success,
    this.message,
    this.data,
  });

  factory PrepareWalletRechargeModel.fromJson(Map<String, dynamic> json) {
    return PrepareWalletRechargeModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null
          ? PrepareWalletRechargeData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class PrepareWalletRechargeData {
  final Wallet? wallet;
  final Transaction? transaction;
  final PaymentResponse? paymentResponse;

  PrepareWalletRechargeData({
    this.wallet,
    this.transaction,
    this.paymentResponse,
  });

  factory PrepareWalletRechargeData.fromJson(Map<String, dynamic> json) {
    return PrepareWalletRechargeData(
      wallet: json['wallet'] != null ? Wallet.fromJson(json['wallet']) : null,
      transaction: json['transaction'] != null
          ? Transaction.fromJson(json['transaction'])
          : null,
      paymentResponse: json['payment_response'] != null
          ? PaymentResponse.fromJson(json['payment_response'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (wallet != null) 'wallet': wallet!.toJson(),
    if (transaction != null) 'transaction': transaction!.toJson(),
    if (paymentResponse != null) 'payment_response': paymentResponse!.toJson(),
  };
}

class Wallet {
  final int? id;
  final int? userId;
  final String? balance;
  final String? blockedBalance;
  final String? currencyCode;
  final String? createdAt;
  final String? updatedAt;

  Wallet({
    this.id,
    this.userId,
    this.balance,
    this.blockedBalance,
    this.currencyCode,
    this.createdAt,
    this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id']),
      balance: parseString(json['balance']),
      blockedBalance: parseString(json['blocked_balance']),
      currencyCode: parseString(json['currency_code']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'balance': balance,
    'blocked_balance': blockedBalance,
    'currency_code': currencyCode,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class Transaction {
  final int? id;
  final int? walletId;
  final int? userId;
  final int? orderId;
  final String? storeId;
  final String? transactionType;
  final String? paymentMethod;
  final String? amount;
  final String? currencyCode;
  final String? status;
  final String? transactionReference;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  Transaction({
    this.id,
    this.walletId,
    this.userId,
    this.orderId,
    this.storeId,
    this.transactionType,
    this.paymentMethod,
    this.amount,
    this.currencyCode,
    this.status,
    this.transactionReference,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: parseInt(json['id']),
      walletId: parseInt(json['wallet_id']),
      userId: parseInt(json['user_id']),
      orderId: parseInt(json['order_id']),
      storeId: parseString(json['store_id']),
      transactionType: parseString(json['transaction_type']),
      paymentMethod: parseString(json['payment_method']),
      amount: parseString(json['amount']),
      currencyCode: parseString(json['currency_code']),
      status: parseString(json['status']),
      transactionReference: parseString(json['transaction_reference']),
      description: parseString(json['description']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'wallet_id': walletId,
    'user_id': userId,
    'order_id': orderId,
    'store_id': storeId,
    'transaction_type': transactionType,
    'payment_method': paymentMethod,
    'amount': amount,
    'currency_code': currencyCode,
    'status': status,
    'transaction_reference': transactionReference,
    'description': description,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PaymentResponse {
  final int? amount;
  final int? amountDue;
  final int? amountPaid;
  final int? attempts;
  final int? createdAt;
  final String? currency;
  final String? entity;
  final String? id;
  final Notes? notes;
  final String? offerId;
  final String? receipt;
  final String? status;

  PaymentResponse({
    this.amount,
    this.amountDue,
    this.amountPaid,
    this.attempts,
    this.createdAt,
    this.currency,
    this.entity,
    this.id,
    this.notes,
    this.offerId,
    this.receipt,
    this.status,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      amount: parseInt(json['amount']),
      amountDue: parseInt(json['amount_due']),
      amountPaid: parseInt(json['amount_paid']),
      attempts: parseInt(json['attempts']),
      createdAt: parseInt(json['created_at']),
      currency: parseString(json['currency']),
      entity: parseString(json['entity']),
      id: parseString(json['id']),
      notes: json['notes'] != null ? Notes.fromJson(json['notes']) : null,
      offerId: parseString(json['offer_id']),
      receipt: parseString(json['receipt']),
      status: parseString(json['status']),
    );
  }

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'amount_due': amountDue,
    'amount_paid': amountPaid,
    'attempts': attempts,
    'created_at': createdAt,
    'currency': currency,
    'entity': entity,
    'id': id,
    if (notes != null) 'notes': notes!.toJson(),
    'offer_id': offerId,
    'receipt': receipt,
    'status': status,
  };
}

class Notes {
  final String? transactionId;
  final String? type;
  final int? userId;

  Notes({
    this.transactionId,
    this.type,
    this.userId,
  });

  factory Notes.fromJson(Map<String, dynamic> json) {
    return Notes(
      transactionId: parseString(json['transaction_id']),
      type: parseString(json['type']),
      userId: parseInt(json['user_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'transaction_id': transactionId,
    'type': type,
    'user_id': userId,
  };
}