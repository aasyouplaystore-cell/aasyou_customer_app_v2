import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../router/app_routes.dart';
import '../../../services/location/location_service.dart';
import '../../home_page/widgets/sections/home_top_address_section.dart';
import '../../../utils/widgets/custom_circular_progress_indicator.dart';
import '../../../utils/widgets/custom_refresh_indicator.dart';
import '../../../utils/widgets/custom_scaffold/custom_scaffold.dart';
import '../../../utils/widgets/empty_states_page.dart';
import '../bloc/all_market_categories_bloc/all_market_categories_bloc.dart';
import '../bloc/all_market_categories_bloc/all_market_categories_event.dart';
import '../bloc/all_market_categories_bloc/all_market_categories_state.dart';
import '../widgets/market_category_grid_widget.dart';

/// Full-screen listing of all Market Categories.
///
/// Mirrors [CategoryListPage]:
///   * AppBar via [CustomScaffold] (back button, view-cart, search action).
///   * Pull-to-refresh ([CustomRefreshIndicator]).
///   * Infinite scroll via a [ScrollController] firing
///     [FetchMoreAllMarketCategories] when the user is within 200 px of the
///     bottom (same pattern as the Categories listing).
class MarketCategoryListPage extends StatelessWidget {
  const MarketCategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AllMarketCategoriesBloc()..add(FetchAllMarketCategories()),
      child: const _MarketCategoryListView(),
    );
  }
}

class _MarketCategoryListView extends StatefulWidget {
  const _MarketCategoryListView();

  @override
  State<_MarketCategoryListView> createState() =>
      _MarketCategoryListViewState();
}

class _MarketCategoryListViewState extends State<_MarketCategoryListView> {
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<BoxEvent>? _locationSub;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // The Change Location flow saves the new location from the map picker
    // AFTER the bottom sheet has already popped, so awaiting the sheet
    // refetches too early. Watching the Hive box catches the actual save.
    _locationSub =
        Hive.box<dynamic>('userLocationBox').watch().listen((_) {
      if (mounted) _onRefresh();
    });
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;

    if (current >= (maxScroll - 200)) {
      context
          .read<AllMarketCategoriesBloc>()
          .add(FetchMoreAllMarketCategories());
    }
  }

  Future<void> _onRefresh() async {
    context.read<AllMarketCategoriesBloc>().add(FetchAllMarketCategories());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CustomScaffold(
      showViewCart: true,
      onConnectivityRestored: (_) async {
        _onRefresh();
      },
      title: l10n?.marketCategories ?? 'Market Categories',
      appBarActions: [
        IconButton(
          onPressed: () {
            GoRouter.of(context).push(AppRoutes.search);
          },
          icon: const Icon(TablerIcons.search),
        ),
      ],
      showAppBar: true,
      body: BlocBuilder<AllMarketCategoriesBloc, AllMarketCategoriesState>(
        builder: (context, state) {
          // Loading + first-frame Initial → centered spinner.
          if (state is AllMarketCategoriesLoading ||
              state is AllMarketCategoriesInitial) {
            return const Center(
              child: CustomCircularProgressIndicator(),
            );
          }

          // Error → reuse NoCategoryPage with onRetry.
          if (state is AllMarketCategoriesFailed) {
            return Center(
              child: NoCategoryPage(onRetry: _onRefresh),
            );
          }

          if (state is AllMarketCategoriesLoaded) {
            final hasData = state.categoryData.isNotEmpty;

            return CustomRefreshIndicator(
              onRefresh: _onRefresh,
              child: hasData
                  ? ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
                      children: [
                        MarketCategoryGridWidget(
                          categories: state.categoryData,
                        ),
                        if (state.isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(
                                child: CustomCircularProgressIndicator()),
                          ),
                        const SizedBox(height: 70), // safe bottom inset
                      ],
                    )
                  : ListView(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25),
                        // Markets are zone-scoped: with a saved location an
                        // empty list means "no market serves your area", so
                        // offer Change Location instead of a bare retry.
                        Center(
                          child: LocationService.getStoredLocation() != null
                              ? EmptyStatePageOnLocation(
                                  title: l10n?.noMarketsInYourAreaYet ??
                                      'No markets in your area yet',
                                  description:
                                      l10n?.noMarketsInYourAreaYetDescription ??
                                          "We're not in your area yet — change your location to browse markets elsewhere.",
                                  imageAsset:
                                      'assets/images/empty-states/no-product-found.png',
                                  onRetry: () =>
                                      showHomeLocationBottomSheet(context),
                                )
                              : NoCategoryPage(onRetry: _onRefresh),
                        ),
                      ],
                    ),
            );
          }

          // Fallback — should never hit.
          return const Center(child: CustomCircularProgressIndicator());
        },
      ),
    );
  }
}
