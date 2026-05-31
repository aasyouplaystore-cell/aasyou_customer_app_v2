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
    debugPrint('[LOCAL] Pending sync items: ${pending.length}');
    return pending;
  }

  void addItem(UserCart item) {
    debugPrint(
        '[LOCAL] ADD → ${item.productId}-${item.variantId} qty:${item
            .quantity}');
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
      debugPrint('[LOCAL] updateQuantity → Item not found: $cartKey');
      return;
    }

    debugPrint(
        '[LOCAL] BEFORE UPDATE → serverCartItemId: ${item.serverCartItemId}');

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
    debugPrint(
        '[LOCAL] AFTER UPDATE → $cartKey → qty: $quantity, syncAction: $syncAction, serverCartItemId: ${verify
            ?.serverCartItemId}');
  }

  void addItemGuest(UserCart item) {
    debugPrint('[LOCAL] GUEST ADD → ${item.productId}-${item.variantId}');
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
      debugPrint('[LOCAL] updateAddons → Item not found: $oldCartKey');
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
      debugPrint(
          '[LOCAL] updateAddons (same key) → $oldCartKey (qty:${updatedItem.quantity}, syncAction: $syncAction)');
      return;
    }

    // Move the row: delete at the old key, put at the new key.
    box.delete(oldCartKey);
    box.put(newCartKey, updatedItem);
    debugPrint(
        '[LOCAL] updateAddons → $oldCartKey → $newCartKey (qty:${updatedItem.quantity}, syncAction: $syncAction)');
  }

  /// Guest-mode mirror of [updateAddons] — no sync action queued.
  void updateAddonsGuest(
    String oldCartKey,
    List<CartAddon> newAddons, {
    int? quantity,
  }) {
    final item = box.get(oldCartKey);
    if (item == null) {
      debugPrint('[LOCAL] updateAddonsGuest → Item not found: $oldCartKey');
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
      debugPrint('[LOCAL] markForUpdate → Item not found: $cartKey');
      return;
    }

    // Only mark for update if it already has a server ID (i.e., already added before)
    if (item.serverCartItemId == null) {
      debugPrint(
          '[LOCAL] markForUpdate → Skipping (not yet added to server): $cartKey');
      return;
    }

    box.put(
      cartKey,
      item.copyWith(syncAction: CartSyncAction.update),
    );
    debugPrint('[LOCAL] MARKED FOR UPDATE → $cartKey (qty: ${item
        .quantity}, serverCartItemId: ${item.serverCartItemId})');
  }

  void markForDelete(String cartKey) {
    final item = box.get(cartKey);
    if (item == null) {
      debugPrint('[LOCAL] markForDelete → Item not found: $cartKey');
      return;
    }

    // If item has serverCartItemId, mark it for deletion (to sync with server)
    if (item.serverCartItemId != null) {
      box.put(
        cartKey,
        item.copyWith(syncAction: CartSyncAction.delete),
      );
      debugPrint('🛒 LOCAL MARKED FOR DELETE → $cartKey (serverCartItemId: ${item
          .serverCartItemId})');
    } else {
      // Item was never synced to server, safe to delete immediately
      box.delete(cartKey);
      debugPrint('🛒 LOCAL DELETE (no server sync needed) → $cartKey');
    }
  }

  void deleteLocally(String cartKey) {
    final item = box.get(cartKey);
    if (item == null) {
      debugPrint('[LOCAL] markForDelete → Item not found: $cartKey');
      return;
    }

    // Item was never synced to server, safe to delete immediately
    box.delete(cartKey);
    debugPrint('🛒 LOCAL DELETE (no server sync needed) → $cartKey');

  }

  void clearLocalCart() {
    debugPrint('🧹 LOCAL CLEAR CART → before: ${box.length} items');
    box.clear();
    box.flush();
    debugPrint('🧹 LOCAL CLEAR CART → after: ${box.length} items');
  }

  void markAllForDelete() {
    debugPrint('🧹 LOCAL MARK ALL FOR DELETE');

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

    debugPrint('🧹 Marked ${allItems
        .where((i) => i.serverCartItemId != null)
        .length} items for server deletion');
    debugPrint('🧹 Deleted ${allItems
        .where((i) => i.serverCartItemId == null)
        .length} local-only items');
  }

  void markSynced(String cartKey, {int? serverCartItemId}) {
    log('Server Cart Item Id $serverCartItemId');
    final item = box.get(cartKey);
    if (item == null) {
      debugPrint('[LOCAL] markSynced → Item not found: $cartKey');
      return;
    }

    final updatedItem = item.copyWith(
      serverCartItemId: serverCartItemId ?? item.serverCartItemId,
      syncAction: CartSyncAction.none,
    );

    box.put(cartKey, updatedItem);
    final verify = box.get(cartKey);
    debugPrint('[VERIFY SAVE] serverCartItemId after put: ${verify
        ?.serverCartItemId}');
  }

  void removeLocal(String cartKey) {
    debugPrint('[LOCAL] REMOVED → $cartKey');
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

    debugPrint('[LOCAL] Created sync payload with ${payload.length} items');

    return payload;
  }

  UserCart? getItemByKey(String cartKey) {
    return box.get(cartKey);
  }

  void printAllHiveData() {
    debugPrint('=== HIVE CART DATA START ===');
    if (box.isEmpty) {
      debugPrint('Box is EMPTY');
    } else {
      for (final key in box.keys) {
        final item = box.get(key);
        debugPrint('Key: $key');
        debugPrint('Value: ${item?.serverCartItemId}');
        debugPrint('---');
      }
    }
    debugPrint('Total items: ${box.length}');
    debugPrint('=== HIVE CART DATA END ===');
  }


  /// Syncs server cart items to local storage.
  void syncServerCartToLocal(List<dynamic> serverCartItems) {
    try {
      debugPrint('🔄 SYNCING SERVER CART TO LOCAL');
      debugPrint('📦 Server items count: ${serverCartItems.length}');
      debugPrint('📦 Local items count BEFORE sync: ${box.length}');

      // Ensure box is ready
      if (!box.isOpen) {
        debugPrint('❌ Hive box is not open! Cannot sync.');
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
          debugPrint('🔑 Server item mapped: $cartKey');
        } else {
          debugPrint('⚠️ Skipping server item with missing IDs: productId=$productId, variantId=$variantId, storeId=$storeId');
        }
      }

      debugPrint('📊 Server items mapped: ${serverItemsMap.length}');

      // Get all local items
      final localItems = box.values.toList();
      debugPrint('📊 Local items found: ${localItems.length}');

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
          debugPrint('📍 Found local item: $cartKey (serverCartItemId: ${localItem.serverCartItemId}, qty: ${localItem.quantity}, syncAction: ${localItem.syncAction})');

          // Skip if item has pending changes
          if (localItem.syncAction != CartSyncAction.none) {
            debugPrint('⏭️ SKIPPED: $cartKey (has pending sync action: ${localItem.syncAction})');
            skipped++;
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
            debugPrint('✏️ UPDATED: $cartKey → qty: $serverQuantity, serverId: $serverCartItemId');
          } else {
            debugPrint('✓ NO CHANGE: $cartKey (already in sync)');
          }
        } else {
          // Item doesn't exist locally - add it from server
          debugPrint('🆕 Creating new local item: $cartKey');
          final newItem = _createUserCartFromServer(serverItem);
          if (newItem != null) {
            box.put(cartKey, newItem);
            added++;
            debugPrint('➕ ADDED: $cartKey → qty: $serverQuantity, serverId: $serverCartItemId');
          } else {
            debugPrint('❌ Failed to create item: $cartKey');
          }
        }
      }

      // Remove local items that don't exist on server
      for (final localItem in localItems) {
        if (!serverItemsMap.containsKey(localItem.cartKey)) {
          if (localItem.syncAction == CartSyncAction.add) {
            // Pending add hasn't reached the server yet — keep for next sync.
            debugPrint('⏭️ KEEPING pending add (not yet on server): ${localItem.cartKey}');
            skipped++;
          } else if (localItem.syncAction == CartSyncAction.update) {
            debugPrint('⏭️ KEEPING: ${localItem.cartKey} (has pending action: ${localItem.syncAction})');
            skipped++;
          } else if (localItem.syncAction == CartSyncAction.delete) {
            // Server already lacks this item — local delete intent is moot.
            box.delete(localItem.cartKey);
            removed++;
            debugPrint('🗑️ REMOVED pending delete (already absent on server): ${localItem.cartKey}');
          } else if (localItem.serverCartItemId != null) {
            box.delete(localItem.cartKey);
            removed++;
            debugPrint('🗑️ REMOVED: ${localItem.cartKey} (not on server, serverCartItemId: ${localItem.serverCartItemId})');
          } else {
            box.delete(localItem.cartKey);
            removed++;
            debugPrint('🗑️ REMOVED unsynced invalid item (no serverCartItemId, no pending action): ${localItem.cartKey}');
          }
        }
      }

      debugPrint('✅ SYNC COMPLETE → Added: $added, Updated: $updated, Removed: $removed, Skipped: $skipped');
      debugPrint('📊 Total local items AFTER sync: ${box.length}');

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
