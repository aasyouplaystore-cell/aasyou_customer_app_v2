//






import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aasyou/model/user_cart_model/user_cart.dart';
import '../../model/user_cart_model/cart_addon.dart';
import '../../model/user_cart_model/cart_sync_action.dart';

class CartLocalRepository {
  final Box<UserCart> box;

  CartLocalRepository(this.box);

  List<UserCart> getAllItems() {
    log('[LOCAL] Fetching all cart items ${box.values.length}');
    final items = box.values.toList();

    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return items;
  }

  List<UserCart> getPendingSyncItems() {
    final pending = <UserCart>[];
    for (var key in box.keys) {
      final item = box.get(key, defaultValue: null);
      if (item != null && item.syncAction != CartSyncAction.none) {
        pending.add(item);
      }
    }
    return pending;
  }

  void addItem(UserCart item) {
    box.put(
      item.cartKey,
      item.copyWith(
        syncAction: CartSyncAction.add,
      ),
    );
  }

  void updateQuantity(String cartKey, int quantity) {
    final item = box.get(cartKey);
    if (item == null) {
      return;
    }


    // Update quantity AND mark for update in ONE operation
    final syncAction = item.serverCartItemId != null
        ? CartSyncAction.update
        : CartSyncAction.add;

    final updatedItem = item.copyWith(
      quantity: quantity,
      syncAction: syncAction,
      serverCartItemId: item
          .serverCartItemId, // CRITICAL: Explicitly preserve serverCartItemId
    );

    box.put(cartKey, updatedItem);

    // Verify the save
    final verify = box.get(cartKey);
  }

  void addItemGuest(UserCart item) {
    box.put(
      item.cartKey,
      item.copyWith(
        syncAction: CartSyncAction.none, // Important!
        isSynced: false, // optional flag
      ),
    );
  }

  void updateQuantityGuest(String cartKey, int quantity) {
    final item = box.get(cartKey);
    if (item == null) return;

    box.put(
      cartKey,
      item.copyWith(
        quantity: quantity,
        syncAction: CartSyncAction.none,
      ),
    );
  }

  /// Replaces the addon set on an existing cart row.
  void updateAddons(
    String oldCartKey,
    List<CartAddon> newAddons, {
    int? quantity,
  }) {
    final item = box.get(oldCartKey);
    if (item == null) {
      return;
    }

    final syncAction = item.serverCartItemId != null
        ? CartSyncAction.update
        : CartSyncAction.add;

    final updatedItem = item.copyWith(
      addons: newAddons,
      quantity: quantity ?? item.quantity,
      syncAction: syncAction,
    );

    final newCartKey = updatedItem.cartKey;

    if (newCartKey == oldCartKey) {
      // Same cartKey (addon-set unchanged, or the sorted-suffix happened
      box.put(oldCartKey, updatedItem);
      return;
    }

    // Move the row: delete at the old key, put at the new key.
    box.delete(oldCartKey);
    box.put(newCartKey, updatedItem);
  }

  /// Guest-mode mirror of [updateAddons] — no sync action queued.
  void updateAddonsGuest(
    String oldCartKey,
    List<CartAddon> newAddons, {
    int? quantity,
  }) {
    final item = box.get(oldCartKey);
    if (item == null) {
      return;
    }

    final updatedItem = item.copyWith(
      addons: newAddons,
      quantity: quantity ?? item.quantity,
      syncAction: CartSyncAction.none,
    );

    final newCartKey = updatedItem.cartKey;

    if (newCartKey == oldCartKey) {
      box.put(oldCartKey, updatedItem);
      return;
    }

    box.delete(oldCartKey);
    box.put(newCartKey, updatedItem);
  }

  void removeItemGuest(String cartKey) {
    box.delete(cartKey);
  }

  void markForUpdate(String cartKey) {
    printAllHiveData();
    final item = box.get(cartKey);
    if (item == null) {
      return;
    }

    // Only mark for update if it already has a server ID (i.e., already added before)
    if (item.serverCartItemId == null) {
      return;
    }

    box.put(
      cartKey,
      item.copyWith(syncAction: CartSyncAction.update),
    );
  }

  void markForDelete(String cartKey) {
    final item = box.get(cartKey);
    if (item == null) {
      return;
    }

    // If item has serverCartItemId, mark it for deletion (to sync with server)
    if (item.serverCartItemId != null) {
      box.put(
        cartKey,
        item.copyWith(syncAction: CartSyncAction.delete),
      );
    } else {
      // Item was never synced to server, safe to delete immediately
      box.delete(cartKey);
    }
  }

  void deleteLocally(String cartKey) {
    final item = box.get(cartKey);
    if (item == null) {
      return;
    }

    // Item was never synced to server, safe to delete immediately
    box.delete(cartKey);

  }

  void clearLocalCart() {
    box.clear();
    box.flush();
  }

  void markAllForDelete() {

    final allItems = box.values.toList();

    for (final item in allItems) {
      if (item.serverCartItemId != null) {
        // Mark for server deletion
        box.put(
          item.cartKey,
          item.copyWith(syncAction: CartSyncAction.delete),
        );
      } else {
        // Delete immediately if never synced to server
        box.delete(item.cartKey);
      }
    }

  }

  void markSynced(String cartKey, {int? serverCartItemId}) {
    log('Server Cart Item Id $serverCartItemId');
    final item = box.get(cartKey);
    if (item == null) {
      return;
    }

    final updatedItem = item.copyWith(
      serverCartItemId: serverCartItemId ?? item.serverCartItemId,
      syncAction: CartSyncAction.none,
    );

    box.put(cartKey, updatedItem);
    final verify = box.get(cartKey);
  }

  void removeLocal(String cartKey) {
    box.delete(cartKey);
  }

  /// Creates a payload list for server sync in the format.
  List<Map<String, dynamic>> createSyncPayload() {
    final items = box.values.toList();

    final payload = items.map((item) {
      final Map<String, dynamic> entry = {
        'store_id': int.tryParse(item.vendorId) ?? 0,
        'product_variant_id': int.tryParse(item.variantId) ?? 0,
        'quantity': item.quantity,
      };

      if (item.addons.isNotEmpty) {
        entry['addons'] =
            item.addons.map((a) => a.toPayloadJson()).toList();
      }

      return entry;
    }).toList();


    return payload;
  }

  UserCart? getItemByKey(String cartKey) {
    return box.get(cartKey);
  }

  void printAllHiveData() {
    if (box.isEmpty) {
    } else {
      for (final key in box.keys) {
        final item = box.get(key);
      }
    }
  }


  /// Syncs server cart items to local storage.
  void syncServerCartToLocal(List<dynamic> serverCartItems) {
    try {

      // Ensure box is ready
      if (!box.isOpen) {
        return;
      }

      final serverItemsMap = <String, dynamic>{};
      for (final serverItem in serverCartItems) {
        final variantId = serverItem['product_variant_id']?.toString() ?? '';
        final storeId = serverItem['store_id']?.toString() ?? '';
        final productId = serverItem['product_id']?.toString() ?? '';

        if (variantId.isNotEmpty && storeId.isNotEmpty && productId.isNotEmpty) {
          final cartKey = _buildServerCartKey(serverItem);
          serverItemsMap[cartKey] = serverItem;
        } else {
        }
      }


      // Get all local items
      final localItems = box.values.toList();

      // Track changes
      int updated = 0;
      int added = 0;
      int removed = 0;
      int skipped = 0;

      // Update or add items from server
      for (final entry in serverItemsMap.entries) {
        final cartKey = entry.key;
        final serverItem = entry.value;

        final serverCartItemId = serverItem['id'] as int?;
        final serverQuantity = serverItem['quantity'] as int? ?? 1;

        final localItem = box.get(cartKey);

        if (localItem != null) {
          // Item exists locally

          // Skip if item has pending changes
          if (localItem.syncAction != CartSyncAction.none) {

            continue;
          }

          // Update if needed
          if (localItem.serverCartItemId != serverCartItemId ||
              localItem.quantity != serverQuantity) {
            box.put(
              cartKey,
              localItem.copyWith(
                quantity: serverQuantity,
                serverCartItemId: serverCartItemId,
                syncAction: CartSyncAction.none,
              ),
            );
            updated++;
          } else {
          }
        } else {
          // Item doesn't exist locally - add it from server
          final newItem = _createUserCartFromServer(serverItem);
          if (newItem != null) {
            box.put(cartKey, newItem);
            added++;
          } else {
          }
        }
      }

      // Remove local items that don't exist on server
      for (final localItem in localItems) {
        if (!serverItemsMap.containsKey(localItem.cartKey)) {
          if (localItem.syncAction == CartSyncAction.add) {
            // Pending add hasn't reached the server yet — keep for next sync.

          } else if (localItem.syncAction == CartSyncAction.update) {

          } else if (localItem.syncAction == CartSyncAction.delete) {
            // Server already lacks this item — local delete intent is moot.
            box.delete(localItem.cartKey);

          } else if (localItem.serverCartItemId != null) {
            box.delete(localItem.cartKey);

          } else {
            box.delete(localItem.cartKey);

          }
        }
      }


      // Print all items for debugging
      printAllHiveData();

    } catch (e, stackTrace) {
      debugPrint('❌ CRITICAL ERROR in syncServerCartToLocal: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }


  /// Build a cart key that matches [UserCart.cartKey] format from a raw.
  String _buildServerCartKey(dynamic serverItem) {
    final productId = serverItem['product_id']?.toString() ?? '';
    final variantId = serverItem['product_variant_id']?.toString() ?? '';
    final dynamic addonsRaw = serverItem['addons'];
    if (addonsRaw is List && addonsRaw.isNotEmpty) {
      final ids = addonsRaw
          .whereType<Map>()
          .map((a) => (a['addon_item_id'] as num?)?.toInt() ?? 0)
          .where((id) => id > 0)
          .toList()
        ..sort();
      if (ids.isNotEmpty) {
        return '${productId}_${variantId}_${ids.join('-')}';
      }
    }
    return '${productId}_$variantId';
  }

  /// Parse addon snapshots from a server-item map into [CartAddon]s.
  List<CartAddon> _parseServerAddons(dynamic addonsRaw) {
    if (addonsRaw is! List) return const [];
    final List<CartAddon> result = [];
    for (final a in addonsRaw) {
      if (a is! Map) continue;
      final groupId = (a['addon_group_id'] as num?)?.toInt() ?? 0;
      final itemId = (a['addon_item_id'] as num?)?.toInt() ?? 0;
      if (groupId == 0 || itemId == 0) continue;
      result.add(CartAddon(
        addonGroupId: groupId,
        addonItemId: itemId,
        title: a['title']?.toString() ?? '',
        price: (a['price'] as num?)?.toDouble() ?? 0.0,
      ));
    }
    return result;
  }

  /// Helper method to create UserCart from server data.
  UserCart? _createUserCartFromServer(dynamic serverItem)   {
    try {
      return UserCart(
        productId: serverItem['product_id']?.toString() ?? '',
        variantId: serverItem['product_variant_id']?.toString() ?? '',
        variantName: serverItem['variant_name']?.toString() ?? '',
        vendorId: serverItem['store_id']?.toString() ?? '',
        name: serverItem['product_name']?.toString() ?? '',
        image: serverItem['image']?.toString() ?? '',
        price: (serverItem['special_price'] as num).toDouble(),
        originalPrice: (serverItem['price'] as num).toDouble(),
        quantity: serverItem['quantity'] as int? ?? 1,
        minQty: 1,
        maxQty: 25,
        isOutOfStock: int.parse(serverItem['stock'].toString()) <= 0,
        isSynced: true,
        serverCartItemId: serverItem['cart_item_id'] as int?,
        syncAction: CartSyncAction.none,
        addons: _parseServerAddons(serverItem['addons']),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ Error creating UserCart from server: $e');
      return null;
    }
  }

}
