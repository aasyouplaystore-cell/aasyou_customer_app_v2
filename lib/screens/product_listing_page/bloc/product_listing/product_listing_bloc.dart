import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
//
import '../../../../model/sorting_model/sorting_model.dart';
import '../../repo/category_product_repo.dart';
import '../../model/product_listing_type.dart';

part 'product_listing_event.dart';
part 'product_listing_state.dart';

class ProductListingBloc extends Bloc<ProductListingEvent, ProductListingState> {
  ProductListingBloc() : super(ProductListingInitial()) {
    on<FetchListingProducts>(_onFetchListingProducts);
    on<FetchMoreListingProducts>(_onFetchMoreListingProducts);
    on<FetchSortedListingProducts>(_onFetchSortedListingProducts);
    on<ResetSearchKeywords>(_onResetSearchKeywords);

    on<FetchFilteredListingProducts>(_onFetchFilteredListingProducts);
    on<ApplyFiltersAndSort>(_onApplyFiltersAndSort);
    on<ClearProductFilters>(_onClearProductFilters);
  }

  int currentPage = 1;
  int perPage = 30;
  int? lastPage;
  bool hasReachedMax = false;
  bool isLoadingMore = false;
  final CategoryProductRepository repository = CategoryProductRepository();
  SortType currentSortType = SortType.relevance;
  int totalProducts = 0;
  ProductListingType type = ProductListingType.search;
  String selectedSortingType = '';

  List<String> appliedCategorySlugs = [];
  List<String> appliedBrandSlugs = [];
  List<int> appliedAttributeIds = [];

  Future<void> _onFetchListingProducts(FetchListingProducts event, Emitter<ProductListingState> emit) async {
    emit(ProductListingLoading());
    try {
      appliedCategorySlugs.clear();
      appliedBrandSlugs.clear();
      appliedAttributeIds.clear();
      currentPage = 1;
      hasReachedMax = false;
      isLoadingMore = false;
      currentSortType = SortType.relevance;
      List<dynamic> keywords = [];
      List<int> categoryIds = [];
      List<int> brandIds = [];
      type = event.type;
      totalProducts = 0;
      selectedSortingType = event.sortType ?? 'default';

      final response = await repository.fetchProductsByType(
        type: event.type,
        identifier: event.identifier,
        sortType: selectedSortingType,
        currentPage: currentPage,
        perPage: perPage,
        isSearchInStore: event.isSearchInStore ?? false,
        storeSlug: event.storeSlug ?? '',
        includeChildCategories: event.includeChildCategories,
        categorySlugs: appliedCategorySlugs,
        brandSlugs: appliedBrandSlugs,
        attributeIds: appliedAttributeIds,
      );

      if(response['data'].isNotEmpty) {
        final products = List<ProductData>.from(
            response['data']['data'].map((data) => ProductData.fromJson(data))
        );

        totalProducts = int.parse(response['data']['total'].toString());
        final currentTotal = int.parse(response['data']['current_page'].toString());
        final lastPageNum = int.parse(response['data']['last_page'].toString());
        categoryIds = List<int>.from(response['data']['category_ids'] ?? []);
        brandIds = List<int>.from(response['data']['brand_ids'] ?? []);

        if(event.type == ProductListingType.search){
          keywords = response['data']['keywords'] as List<dynamic>;
        }

        hasReachedMax = currentTotal >= lastPageNum || products.length < perPage;

        log('Category and Brands Filter $categoryIds $brandIds');
        if (response['success'] == true) {
          emit(ProductListingLoaded(
            message: response['message'],
            productList: products,
            hasReachedMax: hasReachedMax,
            isFilterLoading: false,
            isLoading: false,
            currentSortType: currentSortType,
            totalProducts: totalProducts,
            keywords: keywords,
            categoryIds: categoryIds,
            brandIds: brandIds
          ));
        } else {
          emit(ProductListingFailed(error: response['message']));
        }
      }
      else {
        emit(ProductListingFailed(error: response['message'] ?? 'No products found'));
      }
    } catch (e, err) {
      log('Hello from Product list  ${err.toString()}');
      emit(ProductListingFailed(error: e.toString()));
    }
  }

  Future<void> _onFetchMoreListingProducts(FetchMoreListingProducts event, Emitter<ProductListingState> emit) async {
    if (hasReachedMax || isLoadingMore) return;

    final currentState = state;
    if (currentState is ProductListingLoaded) {
      isLoadingMore = true;
      try {
        currentPage += 1;
        List<dynamic> keywords = [];
        List<int> categoryIds = [];
        List<int> brandIds = [];

        final response = await repository.fetchProductsByType(
          type: type,
          identifier: event.identifier,
          sortType: selectedSortingType,
          currentPage: currentPage,
          perPage: perPage,
          isSearchInStore: event.isSearchInStore ?? false,
          storeSlug: event.storeSlug ?? '',
          categorySlugs: appliedCategorySlugs,
          brandSlugs: appliedBrandSlugs,
          attributeIds: appliedAttributeIds,
        );

        if(response['data'].isNotEmpty) {
          final newProducts = List<ProductData>.from(
              response['data']['data'].map((data) => ProductData.fromJson(data))
          );
          if(event.type == ProductListingType.search){
            keywords = response['data']['keywords'];
          }
          // ✅ Update hasReachedMax based on response
          final currentTotal = int.parse(response['data']['current_page'].toString());
          final lastPageNum = int.parse(response['data']['last_page'].toString());
          hasReachedMax = currentTotal >= lastPageNum || newProducts.length < perPage;
          categoryIds = List<int>.from(response['data']['category_ids'] ?? []);
          brandIds = List<int>.from(response['data']['brand_ids'] ?? []);

          // ✅ Remove duplicates when combining lists
          final updatedProductList = List<ProductData>.from(currentState.productList);

          // Add only unique products
          for (final newProduct in newProducts) {
            if (!updatedProductList.any((existing) => existing.id == newProduct.id)) {
              updatedProductList.add(newProduct);
            }
          }

          emit(ProductListingLoaded(
              message: response['message'],
              productList: updatedProductList,
              hasReachedMax: hasReachedMax,
              isFilterLoading: false,
              isLoading: false,
              currentSortType: currentSortType,
              totalProducts: totalProducts,
              keywords: keywords,
              categoryIds: categoryIds,
              brandIds: brandIds
          ));
        } else {
          emit(ProductListingFailed(error: response['message'] ?? 'No products found'));
        }

      } catch (e) {
        // ✅ Reset page on error
        currentPage -= 1;
        emit(ProductListingFailed(error: e.toString()));
      } finally {
        isLoadingMore = false;
      }
    }
  }

  Future<void> _onFetchSortedListingProducts(FetchSortedListingProducts event, Emitter<ProductListingState> emit) async {
    final currentState = state;
    if (currentState is ProductListingLoaded) {
      emit(ProductListingLoaded(
          message: currentState.message,
          productList: const [],
          hasReachedMax: false,
          isFilterLoading: true,
          isLoading: false,
          currentSortType: currentState.currentSortType,
          totalProducts: 0
      ));
    }

    try {
      // ✅ Reset pagination for sorting
      currentPage = 1;
      hasReachedMax = false;
      isLoadingMore = false;
      List<dynamic> keywords = [];
      List<int> categoryIds = [];
      List<int> brandIds = [];
      selectedSortingType = event.sortType;

      final response = await repository.fetchProductsByType(
        type: type,
        identifier: event.identifier,
        sortType: event.sortType,
        currentPage: currentPage,
        perPage: perPage,
        isSearchInStore: event.isSearchInStore ?? false,
        storeSlug: event.storeSlug ?? '',
        categorySlugs: appliedCategorySlugs,
        brandSlugs: appliedBrandSlugs,
        attributeIds: appliedAttributeIds,
      );

      final products = List<ProductData>.from(
          response['data']['data'].map((data) => ProductData.fromJson(data))
      );

      // ✅ Update pagination state
      final currentTotal = int.parse(response['data']['current_page'].toString());
      final lastPageNum = int.parse(response['data']['last_page'].toString());
      hasReachedMax = currentTotal >= lastPageNum || products.length < perPage;
      categoryIds = List<int>.from(response['data']['category_ids'] ?? []);
      brandIds = List<int>.from(response['data']['brand_ids'] ?? []);

      if(event.type == ProductListingType.search){
        keywords = response['data']['keywords'];
      }
      currentSortType = SortOption.getSortOptionByApiValue(event.sortType).type;

      if (response['success'] == true) {
        emit(ProductListingLoaded(
          message: response['message'],
          productList: products,
          hasReachedMax: hasReachedMax,
          isFilterLoading: false,
          isLoading: false,
          currentSortType: currentSortType,
          totalProducts: totalProducts,
          keywords: keywords,
          categoryIds: categoryIds,
          brandIds: brandIds
        ));
      } else {
        emit(ProductListingFailed(error: response['message']));
      }
    } catch (e) {
      emit(ProductListingFailed(error: e.toString()));
    }
  }

  Future<void> _onResetSearchKeywords (ResetSearchKeywords event, Emitter<ProductListingState> emit) async {
    emit(ProductListingInitial());
  }

  Future<void> _onFetchFilteredListingProducts(
      FetchFilteredListingProducts event,
      Emitter<ProductListingState> emit,
      ) async {
    final currentState = state;

    // Show loading state while keeping existing products visible
    if (currentState is ProductListingLoaded) {
      emit(ProductListingLoaded(
        message: currentState.message,
        productList: currentState.productList,
        hasReachedMax: false,
        isFilterLoading: true,
        isLoading: false,
        currentSortType: currentState.currentSortType,
        totalProducts: currentState.totalProducts,
        keywords: currentState.keywords,
        categoryIds: currentState.categoryIds,
        brandIds: currentState.brandIds
      ));
    } else {
      emit(ProductListingLoading());
    }

    try {
      currentPage = 1;
      hasReachedMax = false;
      isLoadingMore = false;
      type = event.type;
      selectedSortingType = selectedSortingType;
      appliedCategorySlugs = event.categorySlugs;
      appliedBrandSlugs = event.brandSlugs;
      appliedAttributeIds = event.attributeIds;
      List<dynamic> keywords = [];
      List<int> categoryIds = [];
      List<int> brandIds = [];

      final response = await repository.fetchProductsByType(
        type: event.type,
        identifier: event.identifier,
        sortType: selectedSortingType,
        currentPage: currentPage,
        perPage: perPage,
        isSearchInStore: event.isSearchInStore ?? false,
        storeSlug: event.storeSlug ?? '',
        categorySlugs: appliedCategorySlugs,
        brandSlugs: appliedBrandSlugs,
        attributeIds: appliedAttributeIds,
      );

      if (response['data'].isNotEmpty) {
        final products = List<ProductData>.from(
            response['data']['data'].map((data) => ProductData.fromJson(data))
        );

        totalProducts = int.parse(response['data']['total'].toString());
        final currentTotal = int.parse(response['data']['current_page'].toString());
        final lastPageNum = int.parse(response['data']['last_page'].toString());
        categoryIds = List<int>.from(response['data']['category_ids'] ?? []);
        brandIds = List<int>.from(response['data']['brand_ids'] ?? []);

        if (event.type == ProductListingType.search) {
          keywords = response['data']['keywords'] as List<dynamic>;
        }

        hasReachedMax = currentTotal >= lastPageNum || products.length < perPage;
        currentSortType = SortOption.getSortOptionByApiValue(selectedSortingType).type;

        if (response['success'] == true) {
          emit(ProductListingLoaded(
            message: response['message'],
            productList: products,
            hasReachedMax: hasReachedMax,
            isFilterLoading: false,
            isLoading: false,
            currentSortType: currentSortType,
            totalProducts: totalProducts,
            keywords: keywords,
            categoryIds: categoryIds,
            brandIds: brandIds
          ));
        } else {
          emit(ProductListingFailed(error: response['message']));
        }
      } else {
        emit(ProductListingFailed(
            error: response['message'] ?? 'No products found with applied filters'
        ));
      }
    } catch (e) {
      emit(ProductListingFailed(error: e.toString()));
    }
  }

  /// Handler for applying both filters and sorting
  Future<void> _onApplyFiltersAndSort(
      ApplyFiltersAndSort event,
      Emitter<ProductListingState> emit,
      ) async {
    // Reuse the filtered products handler
    add(FetchFilteredListingProducts(
      type: event.type,
      identifier: event.identifier,
      storeSlug: event.storeSlug,
      isSearchInStore: event.isSearchInStore,
      categorySlugs: event.categorySlugs,
      brandSlugs: event.brandSlugs,
      attributeIds: event.attributeIds,
    ));
  }

  /// Handler for clearing filters
  Future<void> _onClearProductFilters(
      ClearProductFilters event,
      Emitter<ProductListingState> emit,
      ) async {
    appliedCategorySlugs.clear();
    appliedBrandSlugs.clear();
    appliedAttributeIds.clear();

    // Fetch products without filters
    add(FetchListingProducts(
      type: event.type,
      identifier: event.identifier,
      storeSlug: event.storeSlug,
      sortType: selectedSortingType,
      isSearchInStore: event.isSearchInStore,
    ));
  }
}