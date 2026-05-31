import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../model/user_cart_model/cart_addon.dart';
import '../../model/user_cart_model/user_cart.dart';

abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final UserCart item;
  final BuildContext context;

  final int? addressId;
  final String? promoCode;
  final bool? rushDelivery;
  final bool? useWallet;
  final bool? isFromCartPage;
  final bool? replaceQty;

  AddToCart({
    this.addressId,
    this.promoCode,
    this.rushDelivery,
    this.useWallet,
    required this.item,
    required this.context,
    this.isFromCartPage = false,
    this.replaceQty = false
  });

  @override
  List<Object?> get props => [
        item,
        context,
        addressId,
        promoCode,
        rushDelivery,
        useWallet,
        isFromCartPage,
        replaceQty
      ];
}

class AddMultipleToCart extends CartEvent {
  final List<UserCart> items;
  final BuildContext context;

  final int? addressId;
  final String? promoCode;
  final bool? rushDelivery;
  final bool? useWallet;
  final bool? isFromCartPage;
  final bool? replaceQty;


  AddMultipleToCart({
    required this.items,
    required this.context,
    this.addressId,
    this.promoCode,
    this.rushDelivery,
    this.useWallet,
    this.isFromCartPage = false,
    this.replaceQty = false
  });

  @override
  List<Object?> get props => [
        items,
        context,
        addressId,
        promoCode,
        rushDelivery,
        useWallet,
        isFromCartPage,
        replaceQty
      ];
}

class UpdateCartQty extends CartEvent {
  final String cartKey;
  final int quantity;
  final int? cartItemId;
  final BuildContext context;
  final bool? isFromCartPage;

  final int? addressId;
  final String? promoCode;
  final bool? rushDelivery;
  final bool? useWallet;
  final bool? replaceQty;


  UpdateCartQty({
    required this.cartKey,
    required this.quantity,
    this.cartItemId,
    required this.context,
    this.addressId,
    this.promoCode,
    this.rushDelivery,
    this.useWallet,
    this.isFromCartPage = false,
    this.replaceQty = false
  });

  @override
  List<Object?> get props => [
        cartKey,
        quantity,
        cartItemId,
        context,
        addressId,
        promoCode,
        rushDelivery,
        useWallet,
        isFromCartPage,
        replaceQty
      ];
}

/// Replaces the addon set on an existing cart row.
class UpdateCartItemAddons extends CartEvent {
  final String cartKey;
  final List<CartAddon> addons;
  final BuildContext context;

  /// Optional quantity update that rides along with the addon change.
  final int? quantity;

  final int? addressId;
  final String? promoCode;
  final bool? rushDelivery;
  final bool? useWallet;
  final bool? isFromCartPage;
  final bool? replaceQty;

  UpdateCartItemAddons({
    required this.cartKey,
    required this.addons,
    required this.context,
    this.quantity,
    this.addressId,
    this.promoCode,
    this.rushDelivery,
    this.useWallet,
    this.isFromCartPage = false,
    this.replaceQty = false,
  });

  @override
  List<Object?> get props => [
        cartKey,
        addons,
        context,
        quantity,
        addressId,
        promoCode,
        rushDelivery,
        useWallet,
        isFromCartPage,
        replaceQty,
      ];
}

class RemoveFromCart extends CartEvent {
  final String cartKey;
  final BuildContext context;

  final int? addressId;
  final String? promoCode;
  final bool? rushDelivery;
  final bool? useWallet;
  final bool? isFromCartPage;
  final bool? replaceQty;


  RemoveFromCart({
    required this.cartKey,
    required this.context,
    this.addressId,
    this.promoCode,
    this.rushDelivery,
    this.useWallet,
    this.isFromCartPage = false,
    this.replaceQty = false
  });

  @override
  List<Object?> get props => [
        cartKey,
        context,
        addressId,
        promoCode,
        rushDelivery,
        useWallet,
        isFromCartPage,
        replaceQty
      ];
}

class RemoveLocally extends CartEvent {
  final String cartKey;
  final BuildContext context;
  RemoveLocally(this.cartKey, this.context);
}

class ClearCart extends CartEvent {
  final BuildContext context;
  ClearCart({required this.context});
}

class SyncLocalCart extends CartEvent {
  final BuildContext context;

  final int? addressId;
  final String? promoCode;
  final bool? rushDelivery;
  final bool? useWallet;
  final bool? isFromCartPage;
  final bool? replaceQty;

  SyncLocalCart({
    required this.context,
    this.addressId,
    this.promoCode,
    this.rushDelivery,
    this.useWallet,
    this.isFromCartPage = false,
    this.replaceQty = false
  });
  @override
  List<Object?> get props =>
      [context, addressId, promoCode, rushDelivery, useWallet, isFromCartPage, replaceQty];
}
