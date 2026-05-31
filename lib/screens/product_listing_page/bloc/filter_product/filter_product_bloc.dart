import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/filter_product_model.dart';
import '../../repo/category_product_repo.dart';
import 'filter_product_event.dart';
import 'filter_product_state.dart';


class FilterProductBloc extends Bloc<FilterProductEvent, FilterProductState> {
  FilterProductBloc() : super(FilterProductInitial()) {
    on<FetchFilterData>(_onFetchFilterData);
  }
  final CategoryProductRepository repository = CategoryProductRepository();
  Future<void> _onFetchFilterData(FetchFilterData event, Emitter<FilterProductState> emit) async {
    emit(FilterProductLoading());
    try{
      final response = await repository.fetchFilterProduct(
        categorySlugs: event.categorySlugs,
        brandSlugs: event.brandSlugs,
        attributeValueIds: event.attributeIds,
        contextType: event.filterType,
        contextValue: event.value
      );
      // List<FilterProductData> categoryData = List<FilterProductData>.from(response['data'].map((data) => FilterProductData.fromJson(data)));


      final model = FilterProductModel.fromJson(response);

      if (model.success == true && model.data != null) {
        emit(FilterProductLoaded(
          filterCategories: model.data!.categories,
          filterBrands: model.data!.brands,
          filterAttributesValues: model.data!.attributes,
        ));
      } else {
        emit(FilterProductFailed(
          error: model.message ?? 'Failed to load filter options (success=false)',
        ));
      }
    }catch(e) {
      log('HELLon ffroor ${e.toString()}');
      emit(FilterProductFailed(error: e.toString()));
    }
  }
}
