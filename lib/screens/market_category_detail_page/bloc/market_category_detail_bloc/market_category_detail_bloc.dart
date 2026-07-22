import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/widgets/cache_manager.dart';
import '../../../home_page/model/market_category_model.dart';
import '../../../home_page/repo/market_category_repo.dart';
import 'market_category_detail_event.dart';
import 'market_category_detail_state.dart';

/// Bloc for the Market Category detail screen.
///
/// Hits `GET /market-categories?slug=<slug>&include_no_product=false` which
/// returns the parent inside `main_category_data` and the children inside
/// `data.data`. Pre-warms banner/icon/background image URLs through the
/// shared [customCacheManager] (mirrors [CategoryBloc] behaviour) so the
/// hero header and grid feel snappy on first paint.
class MarketCategoryDetailBloc
    extends Bloc<MarketCategoryDetailEvent, MarketCategoryDetailState> {
  MarketCategoryDetailBloc() : super(MarketCategoryDetailInitial()) {
    on<FetchMarketCategoryDetail>(_onFetch);
  }

  final MarketCategoryRepository repository = MarketCategoryRepository();

  Future<void> _onFetch(
    FetchMarketCategoryDetail event,
    Emitter<MarketCategoryDetailState> emit,
  ) async {
    emit(MarketCategoryDetailLoading());
    try {
      final response = await repository.fetchMarketCategoryDetail(
        slug: event.slug,
      );

      final parsed = MarketCategoriesResponse.fromJson(response);
      final main = parsed.mainCategoryData;
      final subs = parsed.data?.categories ?? const <MarketCategoryData>[];

      // Pre-cache imagery so the hero + grid don't pop in.
      final urls = <String?>[
        main?.banner,
        main?.image,
        main?.icon,
        main?.backgroundImage,
        for (final s in subs) ...[
          s.image,
          s.icon,
          s.backgroundImage,
          s.banner,
        ],
      ];
      for (final url in urls) {
        if (url != null && url.isNotEmpty) {
          // ignore: discarded_futures
          customCacheManager.downloadFile(url);
        }
      }

      if (parsed.success == true) {
        emit(MarketCategoryDetailLoaded(
          mainCategory: main,
          subcategories: subs,
          message: parsed.message ?? '',
        ));
      } else {
        emit(MarketCategoryDetailFailed(
          error: parsed.message ?? 'Failed to load market category',
        ));
      }
    } catch (e) {
      emit(MarketCategoryDetailFailed(error: e.toString()));
    }
  }
}
