
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/banner/banner_event.dart';
import 'package:aasyou/screens/home_page/bloc/banner/banner_state.dart';
import 'package:aasyou/screens/home_page/repo/banner_repo.dart';

import '../../model/banner_model.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  BannerBloc() : super(BannerInitial()){
    on<FetchBanner>(_onFetchBanner);
  }

  int currentPage = 0;
  int perPage = 0;
  int? lastPage;
  bool _hasReachedMax = false;
  bool loadMore = false;
  final BannerRepository repository = BannerRepository();

  Future<void> _onFetchBanner(FetchBanner event, Emitter<BannerState> emit) async {
    emit(BannerLoading());
    try{
      List<BannerData> topBannerData = [];
      List<BannerData> middleBannerData = [];
      perPage = 18;
      currentPage = 1;
      _hasReachedMax = false;
      loadMore = false;
      final response = await repository.fetchBanners(categorySlug: event.categorySlug);
      topBannerData = List<BannerData>.from(response['data']['data']['top'].map((data) => BannerData.fromJson(data)));
      middleBannerData = List<BannerData>.from(response['data']['data']['carousel'].map((data) => BannerData.fromJson(data)));
      currentPage += 1;
      _hasReachedMax = topBannerData.length < perPage;
      if(response['success'] != null && topBannerData.isNotEmpty || middleBannerData.isNotEmpty){
        if(response['success'] == true){
          emit(BannerLoaded(
              message: response['message'],
              topBannerData: topBannerData,
              middleBannerData: middleBannerData,
              hasReachedMax: _hasReachedMax
          ));
        } else if (response['success'] == false){
          emit(BannerFailed(error: response['message']));
        }
      } else {
        emit(BannerFailed(error: response['message']));
      }
    }catch(e){
      emit(BannerFailed(error: e.toString()));
    }
  }
}