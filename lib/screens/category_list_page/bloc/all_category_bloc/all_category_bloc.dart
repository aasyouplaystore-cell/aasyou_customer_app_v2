import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home_page/model/category_model.dart';
import '../../../home_page/repo/category_repo.dart';
import 'all_category_event.dart';
import 'all_category_state.dart';

class AllCategoriesBloc extends Bloc<AllCategoriesEvent, AllCategoriesState>{
  AllCategoriesBloc() : super(AllCategoriesInitial()){
    on<FetchAllCategories>(_onFetchAllCategories);
    on<FetchMoreAllCategories>(_onFetchMoreAllCategories);
  }
  int currentPage = 0;
  int perPage = 0;
  int? lastPage;
  bool _hasReachedMax = false;
  bool loadMore = false;
  String selectedSlug = '';
  bool selectedIsForAllCategory = false;
  final CategoryRepository repository = CategoryRepository();

  Future<void> _onFetchAllCategories(FetchAllCategories event, Emitter<AllCategoriesState> emit) async {
    emit(AllCategoriesLoading());
    try{
      List<CategoryData> categoryData = [];
      perPage = 80;
      currentPage = 1;
      _hasReachedMax = false;
      loadMore = false;
      final response = await repository.fetchCategory(
        perPage: perPage,
        currentPage: currentPage,
      );
      categoryData = List<CategoryData>.from(response['data']['data'].map((data) => CategoryData.fromJson(data)));
      _hasReachedMax = categoryData.length < perPage;
      if(response['success'] != null){
        if(response['success'] == true){
          emit(AllCategoriesLoaded(
              message: response['message'],
              categoryData: categoryData,
              isLoadingMore: false
          ));
        } else if (response['success'] == false){
          emit(AllCategoriesFailed(error: response['message']));
        }
      } else {
        emit(AllCategoriesFailed(error: response['message']));
      }

    }catch(e){
      emit(AllCategoriesFailed(error: e.toString()));
    }
  }

  Future<void> _onFetchMoreAllCategories(FetchMoreAllCategories event, Emitter<AllCategoriesState> emit) async {
    // Prevent multiple simultaneous calls
    if (_hasReachedMax || loadMore) return;

    final currentState = state;
    if (currentState is AllCategoriesLoaded) {
      // Set loading state
      loadMore = true;

      try {
        // Emit loading-more state for UI
        emit(AllCategoriesLoaded(
          message: currentState.message,
          categoryData: currentState.categoryData,
          isLoadingMore: true,
        ));

        // Increment page BEFORE API call
        currentPage += 1;
        final response = await repository.fetchCategory(
          currentPage: currentPage,
          perPage: perPage,
        );

        final newCategoryData = List<CategoryData>.from(
            response['data']['data'].map((data) => CategoryData.fromJson(data))
        );

        // Update hasReachedMax
        final currentTotal = int.parse(response['data']['current_page'].toString());
        final lastPageNum = int.parse(response['data']['last_page'].toString());
        _hasReachedMax = currentTotal >= lastPageNum || newCategoryData.length < perPage;

        // Remove duplicates when combining lists
        final updatedCategoryData = List<CategoryData>.from(currentState.categoryData);

        // Add only unique subcategories
        for (final newCategory in newCategoryData) {
          if (!updatedCategoryData.any((existing) => existing.id == newCategory.id)) {
            updatedCategoryData.add(newCategory);
          }
        }

        if (response['success'] == true) {
          emit(AllCategoriesLoaded(
            message: response['message'],
            categoryData: updatedCategoryData,
            isLoadingMore: false,
          ));
        } else {
          emit(AllCategoriesFailed(error: response['message']));
        }

      } catch (e) {
        currentPage -= 1;
        emit(AllCategoriesFailed(error: e.toString()));
      } finally {
        loadMore = false;
      }
    }
  }
}