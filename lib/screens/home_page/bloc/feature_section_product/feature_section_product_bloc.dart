import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_event.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_state.dart';
import 'package:aasyou/screens/home_page/repo/feature_section_product_repo.dart';

import '../../model/featured_section_product_model.dart';

class FeatureSectionProductBloc extends Bloc<FeatureSectionProductEvent, FeatureSectionProductState> {
  FeatureSectionProductBloc() : super(FeatureSectionProductInitial()){
    on<FetchFeatureSectionProducts>(_onFetchFeatureSectionProducts);
    on<FetchMoreFeatureSectionProducts>(_onFetchMoreFeatureSectionProducts);
    on<ClearFeatureSectionProducts>(_onClearProducts);
    on<RefreshFeatureSectionProducts>(_onRefreshFeatureSectionProducts);
  }

  int currentPage = 0;
  int perPage = 0;
  int? lastPage;
  bool hasReachedMax = false;
  bool isLoadingMore = false;
  final repository = FeatureSectionProductRepository();
  bool isRefresh = false;
  String selectedCategory = '';

  // Bumped synchronously on add() to invalidate in-flight fetches when the user switches tab mid-request.
  int _requestGeneration = 0;

  @override
  void add(FeatureSectionProductEvent event) {
    if (event is FetchFeatureSectionProducts ||
        event is ClearFeatureSectionProducts ||
        event is RefreshFeatureSectionProducts) {
      _requestGeneration++;
    }
    super.add(event);
  }

  void _onClearProducts(ClearFeatureSectionProducts event, Emitter<FeatureSectionProductState> emit) {
    emit(FeatureSectionProductLoading());
  }

  Future<void> _onFetchFeatureSectionProducts(FetchFeatureSectionProducts event, Emitter<FeatureSectionProductState> emit) async {
    final int handlerGeneration = _requestGeneration;
    if(isRefresh) {
      emit(FeatureSectionProductLoading());
    }
    try{
      List<FeaturedSectionData> featureSectionProductData = [];
      perPage = 12;
      currentPage = 1;
      hasReachedMax = false;
      selectedCategory = event.slug;

      final response = await repository.fetchFeatureSectionProduct(
        slug: event.slug,
        perPage: perPage,
        page: currentPage
      );
      if (handlerGeneration != _requestGeneration) return;
      featureSectionProductData = List<FeaturedSectionData>.from(response['data']['data'].map((data) => FeaturedSectionData.fromJson(data)));
      final currentTotal = int.parse(response['data']['current_page'].toString());
      final lastPageNum = int.parse(response['data']['last_page'].toString());
      hasReachedMax = currentTotal >= lastPageNum || featureSectionProductData.length < perPage;
      // `success=true` means the API reached a delivery zone for the user.
      // The result list can still be empty (zone has no shops in this category).
      // We treat that as a LOADED state with empty data so the UI can show
      // the right "no stores in this category" message — not the
      // "we're not here yet" out-of-zone screen.
      if (response['success'] == true) {
        emit(FeatureSectionProductLoaded(
          featureSectionProductData: featureSectionProductData,
          message: response['message'] ?? '',
          hasReachedMax: hasReachedMax,
        ));
        isRefresh = true;
      } else {
        // success=false → genuine zone-unavailable response from /featured-sections.
        emit(FeatureSectionProductFailed(error: response['message'] ?? ''));
        isRefresh = true;
      }

    }catch(e){
      if (handlerGeneration != _requestGeneration) return;
      emit(FeatureSectionProductFailed(error: e.toString()));
      isRefresh = true;
    }
  }


  Future<void> _onFetchMoreFeatureSectionProducts(FetchMoreFeatureSectionProducts event, Emitter<FeatureSectionProductState> emit) async {
    if (hasReachedMax || isLoadingMore) return;

    final currentState = state;
    if (currentState is FeatureSectionProductLoaded) {
      final int handlerGeneration = _requestGeneration;
      isLoadingMore = true;
      try {
        currentPage += 1;

        final response = await repository.fetchFeatureSectionProduct(
            slug: event.slug,
            perPage: perPage,
            page: currentPage
        );
        if (handlerGeneration != _requestGeneration) return;
        final featureSectionProductData = List<FeaturedSectionData>.from(response['data']['data'].map((data) => FeaturedSectionData.fromJson(data)));

        final currentTotal = int.parse(response['data']['current_page'].toString());
        final lastPageNum = int.parse(response['data']['last_page'].toString());
        hasReachedMax = currentTotal >= lastPageNum || featureSectionProductData.length < perPage;

        final updatedFeatureSectionList = List<FeaturedSectionData>.from(currentState.featureSectionProductData);

        for (final newData in featureSectionProductData) {
          if (!updatedFeatureSectionList.any((existing) => existing.id == newData.id)) {
            updatedFeatureSectionList.add(newData);
          }
        }

        emit(FeatureSectionProductLoaded(
          featureSectionProductData: updatedFeatureSectionList,
          message: response['message'],
          hasReachedMax: hasReachedMax
        ));

      } catch (e) {
        currentPage -= 1;
        if (handlerGeneration != _requestGeneration) return;
        emit(FeatureSectionProductFailed(error: e.toString()));
      } finally {
        isLoadingMore = false;
      }
    }
  }

  Future<void> _onRefreshFeatureSectionProducts(RefreshFeatureSectionProducts event, Emitter<FeatureSectionProductState> emit) async {
    emit(FeatureSectionProductLoading());
    try{
      isRefresh = false;
      add(FetchFeatureSectionProducts(slug: selectedCategory));
    }catch(e){
      emit(FeatureSectionProductFailed(error: e.toString()));
    }
  }
}