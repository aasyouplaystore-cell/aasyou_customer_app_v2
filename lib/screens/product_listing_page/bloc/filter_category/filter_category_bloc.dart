import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:aasyou/screens/home_page/model/category_model.dart';
import 'package:aasyou/screens/home_page/repo/category_repo.dart';
import '../../../../utils/widgets/cache_manager.dart';
import 'filter_category_event.dart';
import 'filter_category_state.dart';

class FilterCategoryBloc extends Bloc<FilterCategoryEvent, FilterCategoryState>{
  FilterCategoryBloc() : super(FilterCategoryInitial()){
    on<FetchFilterCategories>(_onFetchFilterCategories);
    on<FetchMoreFilterCategories>(_onFetchMoreFilterCategories);
  }
  int currentPage = 0;
  int perPage = 0;
  int? lastPage;
  bool loadMore = false;
  final CategoryRepository repository = CategoryRepository();
  final DefaultCacheManager cacheManager = DefaultCacheManager();

  Future<void> _onFetchFilterCategories(FetchFilterCategories event, Emitter<FilterCategoryState> emit) async {
    try{
      List<CategoryData> categoryData = [];
      perPage = 30;
      currentPage = 1;
      loadMore = false;
      final response = await repository.fetchFilterCategory(
          perPage: perPage,
          currentPage: currentPage,
          categoryIds: event.categoryIds
      );
      categoryData = List<CategoryData>.from(response['data']['data'].map((data) => CategoryData.fromJson(data)));
      for (var category in categoryData) {
        final urls = [
          category.backgroundImage,
          category.icon,
          category.banner,
          category.image,
        ];
        for (var url in urls) {
          if (url?.isNotEmpty == true) {
            customCacheManager.downloadFile(url!);
          }
        }
      }

      currentPage += 1;
      if(response['success'] != null){
        if(response['success'] == true){
          emit(FilterCategoryLoaded(
              message: response['message'],
              categoryData: categoryData
          ));
        } else if (response['success'] == false) {
          emit(FilterCategoryFailed(error: response['message']));
        }
      } else {
        emit(FilterCategoryFailed(error: response['message']));
      }
    } catch (e) {
      emit(FilterCategoryFailed(error: e.toString()));
    }
  }

  Future<void> _onFetchMoreFilterCategories(FetchMoreFilterCategories event, Emitter<FilterCategoryState> emit) async {
    try{

    }catch(e){
      emit(FilterCategoryFailed(error: e.toString()));
    }
  }


}