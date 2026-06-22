import 'dart:async';

import 'package:flutter/foundation.dart';

import '../repo/store_follow_repo.dart';

/// Per-store follow state held by [StoreFollowController].
///
/// Plain data class (no `equatable`) — we control rebuilds via the parent
/// [ChangeNotifier] notifying listeners explicitly when an entry changes.
@immutable
class StoreFollowState {
  /// Most recent server-confirmed (or optimistically-set) follow flag.
  final bool isFollowed;

  /// Most recent server-confirmed (or optimistically-set) followers count.
  final int followersCount;

  /// True while a POST/DELETE is in-flight for this store. Cards show a
  /// non-blocking visual hint (e.g. dim or spinner) while this is true.
  final bool isPending;

  const StoreFollowState({
    required this.isFollowed,
    required this.followersCount,
    this.isPending = false,
  });

  StoreFollowState copyWith({
    bool? isFollowed,
    int? followersCount,
    bool? isPending,
  }) {
    return StoreFollowState(
      isFollowed: isFollowed ?? this.isFollowed,
      followersCount: followersCount ?? this.followersCount,
      isPending: isPending ?? this.isPending,
    );
  }
}

/// App-wide controller for the Shop-Follow feature.
///
/// Why a [ChangeNotifier] (and not a full BLoC):
///   * The UI surface for follow is tiny — one heart icon per card. We want
///     every card showing the same store (home strip + listing + store
///     detail) to flip together the instant the user taps any of them.
///   * A keyed map (`Map<int, StoreFollowState>`) lets every card subscribe
///     to ONE store-id without paying the cost of a global bloc rebuilding
///     every listener on each tap.
///   * No event/state hierarchy is needed; toggle + initialize-from-server
///     covers the whole flow.
///
/// Usage from a widget:
///   final c = StoreFollowController.instance;
///   c.seedFromStore(store); // call when card builds with server data
///   ListenableBuilder(
///     listenable: c.listenableFor(storeId),
///     builder: (_, __) { final s = c.stateOf(storeId); ... },
///   );
///   await c.toggle(storeId); // optimistic + persisted
class StoreFollowController extends ChangeNotifier {
  StoreFollowController._();

  /// Process-wide singleton. Registered as `StoreFollowController.instance`
  /// rather than via `getIt` to keep this feature self-contained and avoid
  /// touching the dependency_injection_container wiring.
  static final StoreFollowController instance = StoreFollowController._();

  final StoreFollowRepository _repo = StoreFollowRepository();

  /// Backing store keyed by store-id. A `null` entry means "unknown" — the
  /// caller should seed from the StoreData payload they already have.
  final Map<int, StoreFollowState> _byStoreId = <int, StoreFollowState>{};

  /// Per-store listenable so widgets can rebuild for *their* store only
  /// without the entire app being notified.
  final Map<int, _StoreFollowNotifier> _notifiers = <int, _StoreFollowNotifier>{};

  /// Read-only snapshot for a store. Returns `null` if we have not been
  /// seeded yet (caller should fall back to the StoreData payload).
  StoreFollowState? stateOf(int storeId) => _byStoreId[storeId];

  /// Listenable scoped to a single store-id. Safe to call repeatedly —
  /// the same notifier instance is returned each time.
  Listenable listenableFor(int storeId) {
    return _notifiers.putIfAbsent(storeId, _StoreFollowNotifier.new);
  }

  /// Seed local state from a freshly-fetched StoreData payload. This is
  /// the standard entry point: every PopularShopCard build() pipes the
  /// server `is_followed` / `followers_count` here so the controller
  /// reflects the latest list-endpoint truth.
  ///
  /// If we already have a *pending* operation for the store, we keep the
  /// in-flight optimistic value to avoid the server snapshot stomping on
  /// the user's most recent tap.
  void seedFromStore({
    required int storeId,
    bool? isFollowed,
    int? followersCount,
  }) {
    final existing = _byStoreId[storeId];
    if (existing != null && existing.isPending) return;

    final next = StoreFollowState(
      isFollowed: isFollowed ?? existing?.isFollowed ?? false,
      followersCount: followersCount ?? existing?.followersCount ?? 0,
    );

    if (existing != null &&
        existing.isFollowed == next.isFollowed &&
        existing.followersCount == next.followersCount &&
        !existing.isPending) {
      return; // no-op: avoid spurious rebuilds.
    }

    _byStoreId[storeId] = next;
    _notify(storeId);
  }

  /// Toggle follow / unfollow for a store. Performs an optimistic update
  /// first so the heart flips instantly, then reconciles with the server
  /// response. If the network call fails the optimistic update is reverted
  /// and the original error is rethrown so callers can show a toast.
  Future<void> toggle(int storeId) async {
    final current = _byStoreId[storeId] ??
        const StoreFollowState(isFollowed: false, followersCount: 0);

    // Optimistic flip.
    final optimistic = current.copyWith(
      isFollowed: !current.isFollowed,
      followersCount: current.isFollowed
          ? (current.followersCount > 0 ? current.followersCount - 1 : 0)
          : current.followersCount + 1,
      isPending: true,
    );
    _byStoreId[storeId] = optimistic;
    _notify(storeId);

    try {
      final Map<String, dynamic> data = current.isFollowed
          ? await _repo.unfollowStore(storeId: storeId)
          : await _repo.followStore(storeId: storeId);

      // Reconcile with whatever the server said (preferred path) — falls
      // back to the optimistic values if the response is unexpectedly bare.
      final confirmed = StoreFollowState(
        isFollowed: data['is_followed'] is bool
            ? data['is_followed'] as bool
            : optimistic.isFollowed,
        followersCount: data['followers_count'] is int
            ? data['followers_count'] as int
            : optimistic.followersCount,
      );
      _byStoreId[storeId] = confirmed;
      _notify(storeId);
    } catch (e) {
      // Revert optimistic update.
      _byStoreId[storeId] = current;
      _notify(storeId);
      rethrow;
    }
  }

  void _notify(int storeId) {
    _notifiers[storeId]?.bump();
    // Also notify global listeners (e.g. a dedicated "followed shops" page
    // that wants to react to any toggle).
    notifyListeners();
  }

  @override
  void dispose() {
    for (final n in _notifiers.values) {
      n.dispose();
    }
    _notifiers.clear();
    super.dispose();
  }
}

/// Internal — bumps via [ChangeNotifier.notifyListeners] when its bucket
/// changes. Kept private so consumers go through
/// [StoreFollowController.listenableFor].
class _StoreFollowNotifier extends ChangeNotifier {
  void bump() => notifyListeners();
}
