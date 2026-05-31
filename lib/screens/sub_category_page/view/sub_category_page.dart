import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/home_page/bloc/sub_category/sub_category_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/sub_category/sub_category_event.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:aasyou/utils/widgets/empty_states_page.dart';
import '../../../router/app_routes.dart';
import '../../../utils/widgets/custom_refresh_indicator.dart';
import '../../category_list_page/widgets/category_grid_widget.dart';
import '../../home_page/bloc/sub_category/sub_category_state.dart';

class SubCategoryListPage extends StatelessWidget {
  final String? slug;
  final bool? isForAllCategory;

  const SubCategoryListPage({
    super.key,
    required this.slug,
    this.isForAllCategory,
  });

  @override
  Widget build(BuildContext context) {
    final bool forAll = isForAllCategory ?? ((slug?.isEmpty ?? true));
    return BlocProvider(
      create: (context) => SubCategoryBloc()..add(
        FetchSubCategory(slug: slug ?? '', isForAllCategory: forAll),
      ),
      child: _SubCategoryListView(
        slug: slug ?? '',
        isForAllCategory: forAll,
      ),
    );
  }
}

class _SubCategoryListView extends StatefulWidget {
  final String slug;
  final bool isForAllCategory;

  const _SubCategoryListView({
    required this.slug,
    required this.isForAllCategory,
  });

  @override
  State<_SubCategoryListView> createState() => _SubCategoryListViewState();
}

class _SubCategoryListViewState extends State<_SubCategoryListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;

    if (current >= (maxScroll - 200)) {
      context.read<SubCategoryBloc>().add(FetchMoreSubCategory());
    }
  }

  Future<void> _onRefresh() async {
    context.read<SubCategoryBloc>().add(
      FetchSubCategory(
        slug: widget.slug,
        isForAllCategory: widget.isForAllCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showViewCart: true,
      onConnectivityRestored: (_) async {
        _onRefresh();
      },
      title: AppLocalizations.of(context)!.subCategories,
      appBarActions: [
        IconButton(
          onPressed: () {
            GoRouter.of(context).push(AppRoutes.search);
          },
          icon: const Icon(TablerIcons.search),
        )
      ],
      showAppBar: true,
      body: BlocBuilder<SubCategoryBloc, SubCategoryState>(
        builder: (context, state) {
          // Loading States (Initial + Refresh)
          if (state is SubCategoryLoading || state is SubCategoryInitial) {
            return const Center(
              child: CustomCircularProgressIndicator(),
            );
          }

          // Error State
          if (state is SubCategoryFailed) {
            return Center(
              child: NoCategoryPage(onRetry: _onRefresh),
            );
          }

          // Loaded State
          if (state is SubCategoryLoaded) {
            final hasData = state.subCategoryData.isNotEmpty;

            return CustomRefreshIndicator(
              onRefresh: _onRefresh,
              child: hasData
                  ? ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
                children: [
                  CategoryGridWidget(categories: state.subCategoryData),
                  if (state.isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: CustomCircularProgressIndicator()),
                    ),

                  const SizedBox(height: 70),
                ],
              )
                  : ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(child: NoCategoryPage(onRetry: _onRefresh)),
                ],
              ),
            );
          }

          // Fallback (should never hit)
          return const Center(child: CustomCircularProgressIndicator());
        },
      ),
    );
  }
}