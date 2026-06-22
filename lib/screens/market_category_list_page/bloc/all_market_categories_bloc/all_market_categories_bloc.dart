import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home_page/model/market_category_model.dart';
import '../../../home_page/repo/market_category_repo.dart';
import 'all_market_categories_event.dart';
import 'all_market_categories_state.dart';

/// Paginated bloc for the full "All Market Categories" listing screen.
///
/// Mirrors [AllCategoriesBloc] (perPage = 80, dedup-by-id merge,
/// hasReachedMax via current_page vs last_page).
class AllMarketCategoriesBloc
    extends Bloc<AllMarketCategoriesEvent, AllMarketCategoriesState> {
  AllMarketCategoriesBloc() : super(AllMarketCategoriesInitial()) {
    on<FetchAllMarketCategories>(_onFetch);
    on<FetchMoreAllMarketCategories>(_onFetchMore);
  }

  int currentPage = 0;
  int perPage = 0;
  int? lastPage;
  bool _hasReachedMax = false;
  bool loadMore = false;
  final MarketCategoryRepository repository = MarketCategoryRepository();

  bool get hasReachedMax => _hasReachedMax;

  Future<void> _onFetch(
    FetchAllMarketCategories event,
    Emitter<AllMarketCategoriesState> emit,
  ) async {
    emit(AllMarketCategoriesLoading());
    try {
      perPage = 80;
      currentPage = 1;
      _hasReachedMax = false;
      loadMore = false;

      final response = await repository.fetchMarketCategories(
        perPage: perPage,
        currentPage: currentPage,
        includeNoProduct: false,
      );

      final categoryData = _parseList(response);
      _hasReachedMax = categoryData.length < perPage;

      if (response['success'] != null) {
        if (response['success'] == true) {
          emit(AllMarketCategoriesLoaded(
            message: (response['message'] ?? '').toString(),
            categoryData: categoryData,
            isLoadingMore: false,
          ));
        } else {
          emit(AllMarketCategoriesFailed(
            error: (response['message'] ?? 'Failed to load market categories')
                .toString(),
          ));
        }
      } else {
        emit(AllMarketCategoriesFailed(
          error: (response['message'] ?? 'Failed to load market categories')
              .toString(),
        ));
      }
    } catch (e) {
      emit(AllMarketCategoriesFailed(error: e.toString()));
    }
  }

  Future<void> _onFetchMore(
    FetchMoreAllMarketCategories event,
    Emitter<AllMarketCategoriesState> emit,
  ) async {
    if (_hasReachedMax || loadMore) return;

    final currentState = state;
    if (currentState is AllMarketCategoriesLoaded) {
      loadMore = true;
      try {
        emit(AllMarketCategoriesLoaded(
          message: currentState.message,
          categoryData: currentState.categoryData,
          isLoadingMore: true,
        ));

        currentPage += 1;

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
        _hasReachedMax =
            currentTotal >= lastPageNum || newData.length < perPage;

        final merged =
            List<MarketCategoryData>.from(currentState.categoryData);
        for (final n in newData) {
          if (!merged.any((existing) => existing.id == n.id)) {
            merged.add(n);
          }
        }

        if (response['success'] == true) {
          emit(AllMarketCategoriesLoaded(
            message: (response['message'] ?? '').toString(),
            categoryData: merged,
            isLoadingMore: false,
          ));
        } else {
          emit(AllMarketCategoriesFailed(
            error: (response['message'] ?? 'Failed to load market categories')
                .toString(),
          ));
        }
      } catch (e) {
        currentPage -= 1;
        emit(AllMarketCategoriesFailed(error: e.toString()));
      } finally {
        loadMore = false;
      }
    }
  }

  List<MarketCategoryData> _parseList(Map<String, dynamic> response) {
    final raw = response['data']?['data'];
    if (raw is! Iterable) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(MarketCategoryData.fromJson)
        .toList();
  }
}
