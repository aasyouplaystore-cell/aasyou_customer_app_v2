import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home_page/repo/market_category_repo.dart';
import '../../../near_by_stores/model/near_by_store_model.dart';
import 'market_category_stores_event.dart';
import 'market_category_stores_state.dart';

/// Stores list bloc for the Market Category detail screen.
///
/// Mirrors `NearByStoreBloc` (pagination + dedup-by-id merge) but injects
/// `market_category_slug` into the `/delivery-zone/stores` query so the
/// list is scoped to the current market category. Uses the existing
/// [NearbyStoresPageData] + [StoreData] models so we don't fork the store
/// data structure.
class MarketCategoryStoresBloc
    extends Bloc<MarketCategoryStoresEvent, MarketCategoryStoresState> {
  MarketCategoryStoresBloc() : super(MarketCategoryStoresInitial()) {
    on<FetchMarketCategoryStores>(_onFetch);
    on<LoadMoreMarketCategoryStores>(_onLoadMore);
  }

  final MarketCategoryRepository repository = MarketCategoryRepository();

  int currentPage = 1;
  int perPage = 24;
  bool hasReachedMax = false;
  bool isLoadingMore = false;
  int totalStores = 0;

  Future<void> _onFetch(
    FetchMarketCategoryStores event,
    Emitter<MarketCategoryStoresState> emit,
  ) async {
    emit(MarketCategoryStoresLoading());
    try {
      currentPage = event.page;
      perPage = event.perPage;
      hasReachedMax = false;
      isLoadingMore = false;
      totalStores = 0;

      final response = await repository.fetchStoresByMarketCategorySlug(
        marketCategorySlug: event.marketCategorySlug,
        page: currentPage,
        perPage: perPage,
        searchQuery: event.searchQuery,
      );

      if (response == null) {
        emit(const MarketCategoryStoresFailed(
            error: 'Failed to fetch stores'));
        return;
      }

      final model = NearbyStoresModel.fromJson(response);
      if (model.success == true && model.data != null) {
        final stores = model.data!.stores;
        totalStores = model.data!.total ?? 0;
        final currentPageNum = model.data!.currentPage ?? 1;
        final lastPageNum = model.data!.lastPage ?? 1;
        hasReachedMax =
            currentPageNum >= lastPageNum || stores.length < perPage;

        emit(MarketCategoryStoresLoaded(
          message: model.message ?? '',
          stores: model.data!,
          hasReachedMax: hasReachedMax,
          totalStores: totalStores,
        ));
      } else {
        emit(MarketCategoryStoresFailed(
            error: model.message ?? 'Unknown error'));
      }
    } catch (e) {
      emit(MarketCategoryStoresFailed(error: e.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreMarketCategoryStores event,
    Emitter<MarketCategoryStoresState> emit,
  ) async {
    if (isLoadingMore) return;

    final currentState = state;
    if (currentState is MarketCategoryStoresLoaded &&
        !currentState.hasReachedMax) {
      isLoadingMore = true;
      try {
        // Flag UI: pagination row spinner
        emit(MarketCategoryStoresLoaded(
          message: currentState.message,
          stores: currentState.stores,
          hasReachedMax: currentState.hasReachedMax,
          totalStores: currentState.totalStores,
          isLoadingMore: true,
        ));

        currentPage += 1;

        final response = await repository.fetchStoresByMarketCategorySlug(
          marketCategorySlug: event.marketCategorySlug,
          page: currentPage,
          perPage: event.perPage,
          searchQuery: event.searchQuery,
        );

        if (response == null) {
          currentPage -= 1;
          emit(MarketCategoryStoresLoaded(
            message: currentState.message,
            stores: currentState.stores,
            hasReachedMax: currentState.hasReachedMax,
            totalStores: currentState.totalStores,
          ));
          return;
        }

        final model = NearbyStoresModel.fromJson(response);
        if (model.success == true && model.data != null) {
          final newStores = model.data!.stores;

          final merged = List<StoreData>.from(currentState.stores.stores);
          for (final s in newStores) {
            if (!merged.any((e) => e.id == s.id)) {
              merged.add(s);
            }
          }

          final currentPageNum = model.data!.currentPage ?? currentPage;
          final lastPageNum = model.data!.lastPage ?? 1;
          hasReachedMax = currentPageNum >= lastPageNum ||
              newStores.length < event.perPage;

          final updated = NearbyStoresPageData(
            currentPage: model.data!.currentPage,
            stores: merged,
            total: model.data!.total,
            nextPageUrl: model.data!.nextPageUrl,
            firstPageUrl: model.data!.firstPageUrl,
            from: model.data!.from,
            lastPage: model.data!.lastPage,
            lastPageUrl: model.data!.lastPageUrl,
            links: model.data!.links,
            path: model.data!.path,
            perPage: model.data!.perPage,
            prevPageUrl: model.data!.prevPageUrl,
            to: model.data!.to,
          );

          emit(MarketCategoryStoresLoaded(
            message: currentState.message,
            stores: updated,
            hasReachedMax: hasReachedMax,
            totalStores: model.data!.total ?? totalStores,
          ));
        } else {
          currentPage -= 1;
          emit(MarketCategoryStoresLoaded(
            message: currentState.message,
            stores: currentState.stores,
            hasReachedMax: currentState.hasReachedMax,
            totalStores: currentState.totalStores,
          ));
        }
      } catch (e) {
        currentPage -= 1;
        emit(MarketCategoryStoresLoaded(
          message: currentState.message,
          stores: currentState.stores,
          hasReachedMax: currentState.hasReachedMax,
          totalStores: currentState.totalStores,
        ));
      } finally {
        isLoadingMore = false;
      }
    }
  }
}
