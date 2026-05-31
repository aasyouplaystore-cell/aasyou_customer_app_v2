import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/wishlist_page/repo/wishlist_repo.dart';

import '../../../../model/sorting_model/sorting_model.dart';
import '../../model/wishlist_product_model.dart';

part 'wishlist_product_event.dart';
part 'wishlist_product_state.dart';

class WishlistProductBloc extends Bloc<WishlistProductEvent, WishlistProductState> {
  WishlistProductBloc() : super(WishlistProductInitial()) {
    on<FetchWishlistProductData>(_onFetchWishlistProductData);
    on<RemoveProductLocally>(_onRemoveProductLocally);
  }
  int currentPage = 1;
  int perPage = 80;
  int? lastPage;
  bool hasReachedMax = false;
  bool isLoadingMore = false;
  bool loadMore = false;
  final UserWishlistRepository repository = UserWishlistRepository();
  SortType currentSortType = SortType.relevance;
  int totalProducts = 0;
  String wishlistName = '';

  Future<void> _onFetchWishlistProductData(FetchWishlistProductData event, Emitter<WishlistProductState> emit) async {
    emit(WishlistProductLoading());
    try {
      currentPage = 1;
      hasReachedMax = false;
      isLoadingMore = false;

      final response = await repository.fetchWishlistProduct(
          wishlistId: event.wishlistId,
          currentPage: currentPage,
          perPage: perPage
      );

      // print('Response data check  ${response['data'] == []}');
      if(response['data'].isNotEmpty) {
        final products = List<WishlistProductItems>.from(
            response['data']['items'].map((data) => WishlistProductItems.fromJson(data))
        );

        totalProducts = int.parse(response['data']['items_count'].toString());
        wishlistName = response['data']['title'].toString();


        if (response['success'] == true) {
          emit(WishlistProductLoaded(
              message: response['message'],
              wishlistProductItems: products,
              hasReachedMax: hasReachedMax,
              isLoading: false,
              totalProducts: totalProducts,
              wishlistName: wishlistName
          ));
        }
        else {
          emit(WishlistProductFailed(error: response['message']));
        }
      }
      else {
        emit(WishlistProductFailed(error: response['message'] ?? 'No products found'));
      }
    } catch(e) {
      emit(WishlistProductFailed(error: e.toString()));
    }
  }

  void _onRemoveProductLocally(RemoveProductLocally event, Emitter<WishlistProductState> emit) {
     if(state is WishlistProductLoaded) {
       final wishlistProductItems = (state as WishlistProductLoaded).wishlistProductItems;

       final updatedItems = wishlistProductItems.where((item) => item.id != event.itemId).toList();

       emit(WishlistProductLoaded(
           message: 'Product removed from wishlist',
           wishlistProductItems: updatedItems,
           hasReachedMax: hasReachedMax,
           isLoading: false,
           totalProducts: totalProducts,
           wishlistName: wishlistName
       ));
     }
  }
}