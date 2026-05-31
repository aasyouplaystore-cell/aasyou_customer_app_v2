import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/home_page/model/brands_model.dart';

import '../../../home_page/repo/brands_repo.dart';

part 'filter_brands_event.dart';
part 'filter_brands_state.dart';

class FilterBrandsBloc extends Bloc<FilterBrandsEvent, FilterBrandsState> {
  FilterBrandsBloc() : super(FilterBrandsInitial()) {
    on<FetchFilterBrands>(_onFetchFilterBrands);
  }

  int currentPage = 0;
  int perPage = 0;
  int? lastPage;
  bool loadMore = false;
  final BrandsRepository repository = BrandsRepository();

  Future<void> _onFetchFilterBrands(FetchFilterBrands event, Emitter<FilterBrandsState> emit) async {
    emit(FilterBrandsLoading());
    try{
      List<BrandData> brandsData = [];
      perPage = 18;
      currentPage = 1;
      loadMore = false;
      final response = await repository.fetchFilterBrands(
        categorySlug: event.categorySlug,
        brandIds: event.brandsIds ?? []
      );
      brandsData = List<BrandData>.from(response['data']['data'].map((data) => BrandData.fromJson(data)));
      currentPage += 1;
      if(response['success'] != null && brandsData.isNotEmpty){
        if(response['success'] == true){
          emit(FilterBrandsLoaded(
              message: response['message'],
              brandsData: brandsData
          ));
        } else if (response['success'] == false){
          emit(FilterBrandsFailed(error: response['message']));
        }
      } else {
        emit(FilterBrandsFailed(error: response['message']));
      }
    }catch(e){
      emit(FilterBrandsFailed(error: e.toString()));
    }
  }

}
