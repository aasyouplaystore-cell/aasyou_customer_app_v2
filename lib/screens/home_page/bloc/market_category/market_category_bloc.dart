import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:aasyou/screens/home_page/bloc/market_category/market_category_event.dart';
import 'package:aasyou/screens/home_page/bloc/market_category/market_category_state.dart';
import 'package:aasyou/screens/home_page/model/market_category_model.dart';
import 'package:aasyou/screens/home_page/repo/market_category_repo.dart';

import '../../../../utils/widgets/cache_manager.dart';

/// Bloc for the home "Market Categories" horizontal strip.
///
/// Mirrors [CategoryBloc] 1:1 (perPage = 30, single fetch, no UI pagination
/// — the home strip displays up to ~20 items). Pre-warms image URLs through
/// the shared [customCacheManager] so the cards render without flashing.
class HomeMarketCategoriesBloc
    extends Bloc<HomeMarketCategoriesEvent, HomeMarketCategoriesState> {
  HomeMarketCategoriesBloc() : super(HomeMarketCategoriesInitial()) {
    on<FetchHomeMarketCategories>(_onFetch);
    on<FetchMoreHomeMarketCategories>(_onFetchMore);
  }

  int currentPage = 0;
  int perPage = 0;
  int? lastPage;
  bool isLoadingMore = false;
  bool hasReachedMax = false;
  final MarketCategoryRepository repository = MarketCategoryRepository();
  final DefaultCacheManager cacheManager = DefaultCacheManager();

  Future<void> _onFetch(
    FetchHomeMarketCategories event,
    Emitter<HomeMarketCategoriesState> emit,
  ) async {
    try {
      perPage = 30;
      currentPage = 1;
      hasReachedMax = false;

      final response = await repository.fetchMarketCategories(
        perPage: perPage,
        currentPage: currentPage,
        includeNoProduct: false,
      );

      final List<MarketCategoryData> categoryData = _parseList(response);

      _prewarmImages(categoryData);

      final currentTotal =
          int.tryParse('${response['data']?['current_page']}') ?? currentPage;
      final lastPageNum =
          int.tryParse('${response['data']?['last_page']}') ?? currentPage;
      hasReachedMax =
          currentTotal >= lastPageNum || categoryData.length < perPage;

      currentPage += 1;

      if (response['success'] != null) {
        if (response['success'] == true) {
          emit(HomeMarketCategoriesLoaded(
            message: (response['message'] ?? '').toString(),
            categoryData: categoryData,
            hasReachedMax: hasReachedMax,
          ));
        } else {
          emit(HomeMarketCategoriesFailed(
            error: (response['message'] ?? 'Failed to load market categories')
                .toString(),
          ));
        }
      } else {
        emit(HomeMarketCategoriesFailed(
          error: (response['message'] ?? 'Failed to load market categories')
              .toString(),
        ));
      }
    } catch (e) {
      emit(HomeMarketCategoriesFailed(error: e.toString()));
    }
  }

  Future<void> _onFetchMore(
    FetchMoreHomeMarketCategories event,
    Emitter<HomeMarketCategoriesState> emit,
  ) async {
    if (hasReachedMax || isLoadingMore) return;

    final currentState = state;
    if (currentState is HomeMarketCategoriesLoaded) {
      isLoadingMore = true;
      try {
        final response = await repository.fetchMarketCategories(
          perPage: perPage,
          currentPage: currentPage,
          includeNoProduct: false,
        );
        final newData = _parseList(response);

        final currentTotal =
            int.tryParse('${response['data']?['current_page']}') ?? currentPage;
        final lastPageNum =
            int.tryParse('${response['data']?['last_page']}') ?? currentPage;
        hasReachedMax = currentTotal >= lastPageNum || newData.length < perPage;

        final merged = List<MarketCategoryData>.from(currentState.categoryData);
        for (final n in newData) {
          if (!merged.any((existing) => existing.id == n.id)) {
            merged.add(n);
          }
        }

        currentPage += 1;
        _prewarmImages(newData);

        emit(HomeMarketCategoriesLoaded(
          categoryData: merged,
          message: (response['message'] ?? '').toString(),
          hasReachedMax: hasReachedMax,
        ));
      } catch (e) {
        emit(HomeMarketCategoriesFailed(error: e.toString()));
      } finally {
        isLoadingMore = false;
      }
    }
  }

  // ----- helpers -----

  List<MarketCategoryData> _parseList(Map<String, dynamic> response) {
    final raw = response['data']?['data'];
    if (raw is! Iterable) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(MarketCategoryData.fromJson)
        .toList();
  }

  void _prewarmImages(List<MarketCategoryData> list) {
    for (final c in list) {
      final urls = <String?>[
        c.backgroundImage,
        c.icon,
        c.banner,
        c.image,
      ];
      for (final url in urls) {
        if (url != null && url.isNotEmpty) {
          // Fire-and-forget – mirrors CategoryBloc behavior.
          customCacheManager.downloadFile(url);
        }
      }
    }
  }
}
