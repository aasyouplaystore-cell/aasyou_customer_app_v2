import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:aasyou/screens/home_page/bloc/category/category_event.dart';
import 'package:aasyou/screens/home_page/bloc/category/category_state.dart';
import 'package:aasyou/screens/home_page/model/category_model.dart';
import 'package:aasyou/screens/home_page/repo/category_repo.dart';
import '../../../../utils/widgets/cache_manager.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState>{
  CategoryBloc() : super(CategoryInitial()){
    on<FetchCategory>(_onFetchCategory);
    on<FetchMoreCategory>(_onFetchMoreCategory);
  }
  int currentPage = 0;
  int perPage = 0;
  int? lastPage;
  bool isLoadingMore = false;
  bool hasReachedMax = false;
  final CategoryRepository repository = CategoryRepository();
  final DefaultCacheManager cacheManager = DefaultCacheManager();

  Future<void> _onFetchCategory(FetchCategory event, Emitter<CategoryState> emit) async {
    try{
      List<CategoryData> categoryData = [];
      perPage = 30;
      currentPage = 1;
      final response = await repository.fetchCategory(
          perPage: perPage,
          currentPage: currentPage
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
          emit(CategoryLoaded(
              message: response['message'],
              categoryData: categoryData,
              hasReachedMax: hasReachedMax
          ));
        } else if (response['success'] == false) {
          emit(CategoryFailed(error: response['message']));
        }
      } else {
        emit(CategoryFailed(error: response['message']));
      }
    } catch (e) {
      emit(CategoryFailed(error: e.toString()));
    }
  }

  Future<void> _onFetchMoreCategory(FetchMoreCategory event, Emitter<CategoryState> emit) async {
    if (hasReachedMax || isLoadingMore) return;

    final currentState = state;
    if (currentState is CategoryLoaded) {
      isLoadingMore = true;
      try {
        currentPage += 1;

        final response = await repository.fetchCategory(
            perPage: perPage,
            currentPage: currentPage
        );
        final categoryData = List<CategoryData>.from(response['data']['data'].map((data) => CategoryData.fromJson(data)));

        final currentTotal = int.parse(response['data']['current_page'].toString());
        final lastPageNum = int.parse(response['data']['last_page'].toString());
        hasReachedMax = currentTotal >= lastPageNum || categoryData.length < perPage;

        final updatedCategoryData = List<CategoryData>.from(currentState.categoryData);

        for (final newData in categoryData) {
          if (!updatedCategoryData.any((existing) => existing.id == newData.id)) {
            updatedCategoryData.add(newData);
          }
        }

        emit(CategoryLoaded(
            categoryData: updatedCategoryData,
            message: response['message'],
            hasReachedMax: hasReachedMax
        ));

      } catch (e) {
        currentPage -= 1;
        emit(CategoryFailed(error: e.toString()));
      } finally {
        isLoadingMore = false;
      }
    }
  }


}