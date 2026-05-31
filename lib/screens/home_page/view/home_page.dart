import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:aasyou/bloc/settings_bloc/settings_bloc.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_bloc.dart';
import 'package:aasyou/config/settings_data_instance.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/address_list_page/bloc/get_address_list_bloc/get_address_list_bloc.dart';
import 'package:aasyou/screens/cart_page/bloc/get_user_cart/get_user_cart_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/banner/banner_event.dart';
import 'package:aasyou/screens/home_page/bloc/category/category_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/category/category_event.dart';
import 'package:aasyou/screens/home_page/bloc/market_category/market_category_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/market_category/market_category_event.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_event.dart';
import 'package:aasyou/screens/home_page/bloc/feature_section_product/feature_section_product_state.dart';
import 'package:aasyou/screens/home_page/bloc/sub_category/sub_category_bloc.dart';
import 'package:aasyou/screens/home_page/bloc/sub_category/sub_category_event.dart';
import 'package:aasyou/screens/near_by_stores/bloc/near_by_store/near_by_store_bloc.dart';
import 'package:aasyou/screens/user_profile/bloc/user_profile_bloc/user_profile_bloc.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';
import '../../../bloc/user_cart_bloc/user_cart_event.dart';
import '../../../config/global.dart';
import '../../../config/helper.dart';
import '../../../config/notification_service.dart';
import '../../../deep_link.dart';
import '../../../router/app_routes.dart';
import '../../../utils/widgets/custom_circular_progress_indicator.dart';
import '../../../utils/widgets/custom_refresh_indicator.dart';
import '../../../utils/widgets/custom_scaffold/custom_scaffold.dart';
import '../bloc/banner/banner_bloc.dart';
import '../bloc/brands/brands_bloc.dart';
import '../model/category_model.dart';
import '../widgets/animated_text_field.dart';
import '../bloc/category/category_state.dart';
import '../widgets/home_helpers.dart';
import '../widgets/home_featured_placeholder.dart';
import '../widgets/product_feature_section_widget.dart';
import '../../../utils/widgets/empty_states_page.dart';
import '../../notification_page/bloc/notification_bloc.dart';
import '../widgets/home_tab_item.dart';
import '../widgets/sections/home_app_bar_section.dart';
import '../widgets/sections/home_tab_content_section.dart';
import '../widgets/sections/home_top_address_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final AppLinksDeepLink _appLinksDeepLink = AppLinksDeepLink.instance;
  late TabController _tabController;
  final ScrollController nestedScrollController = ScrollController();
  late String backgroundImagePath = '';
  String? backgroundColor;
  bool _isImageEmpty = false;
  Color? textColor;
  List<CategoryData> _categories = [];
  bool _isTabControllerInitialized = false;
  bool _isFlexibleSpaceHidden = false;
  bool _isRecreatingTabController = false;
  Color? _originalTextColor;
  Color? _collapsedTextColor;
  String? _lastLocationIdentifier;
  final Map<int, bool> _isLoadingMoreForTab = {};
  int localCategoryLength = 0;
  String _tabBarViewKey = 'initial';
  int _previousCategoryLength = 0;
  bool _isRedirecting = false;
  double _appBarOpacity = 1.0;
  bool isRetry = false;
  List<String>? searchHintList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        NotificationService.handleNotificationNavigation(message.data);
      }
    });
    _appLinksDeepLink.initDeepLinks(context);

    final cachedSettings = SettingsData.instance.homeGeneralSettings;
    if (cachedSettings != null && isValidHomeGeneralSettings(cachedSettings)) {
      backgroundImagePath = cachedSettings.backgroundImage.isNotEmpty
          ? cachedSettings.backgroundImage
          : '';
      backgroundColor = cachedSettings.backgroundColor.isNotEmpty
          ? cachedSettings.backgroundColor
          : null;
    }
    _isImageEmpty = backgroundImagePath.isEmpty;
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(_onTabChanged);
    _isTabControllerInitialized = true;
    nestedScrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (AppLinksDeepLink.instance.hasPendingLink) {
          log('HomePage: Deep link pending, skipping initial API calls');
          return;
        }
        _applyHomeGeneralSettingsToAppBar();
        context.read<UserProfileBloc>().add(FetchUserProfile());
        final box = Hive.box<dynamic>('userLocationBox');
        final storedLocation = box.get('user_location');
        if (storedLocation != null) {
          // Location exists, refresh will handle in build
        } else {
          context.read<CategoryBloc>().add(FetchCategory(context: context));
          context
              .read<HomeMarketCategoriesBloc>()
              .add(FetchHomeMarketCategories());
          apiCalls('');
        }
      }
    });
    searchHintList = removeUnderscoresFromStringList(SettingsData.instance.homeGeneralSettings?.searchLabels ?? []);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initialiseColors();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _tabController.index == 0) {
        _applyHomeGeneralSettingsToAppBar();
      }
      if (!_isImageEmpty && backgroundImagePath.isNotEmpty) {
        precacheImage(NetworkImage(backgroundImagePath), context);
      }
    });
  }

  void initialiseColors() {
    _originalTextColor = Theme.of(context).brightness == Brightness.light
        ? AppTheme.lightFontColor
        : AppTheme.darkFontColor;
    _collapsedTextColor = Theme.of(context).brightness == Brightness.light
        ? AppTheme.lightFontColor
        : AppTheme.darkFontColor;
    textColor = _originalTextColor;
  }

  void updateAppBarBackground(
      {String? image,
      String? bgColor,
        Color? fontColor,
        List<String>? searchHintTextList
      }) {
    setState(() {
      backgroundImagePath = image ?? '';
      backgroundColor = bgColor;
      _isImageEmpty = backgroundImagePath.isEmpty;
      _originalTextColor = fontColor ??
          (Theme.of(context).brightness == Brightness.light
              ? AppTheme.lightFontColor
              : AppTheme.darkFontColor);
      // Use `this.` to assign to the instance field — the parameter
      // shadows the field and `searchHintTextList = searchHintTextList`
      // would otherwise be a no-op.
      searchHintList = searchHintTextList;
      if (_isFlexibleSpaceHidden) {
        textColor = _collapsedTextColor;
      } else {
        textColor = _originalTextColor;
      }
    });
  }

  void _onTabChanged() {
    if (!_canUseTabController || _isRedirecting) return;

    final int index = _tabController.index;
    final int totalTabs = _categories.length + 1;

    if (index >= totalTabs) {
      _ensureValidTabIndex();
      return;
    }

    context
        .read<FeatureSectionProductBloc>()
        .add(ClearFeatureSectionProducts());

    if (index == 0) {
      apiCalls('');
      _applyHomeGeneralSettingsToAppBar();
    } else if (index > 0 && index - 1 < _categories.length) {
      final category = _categories[index - 1];
      apiCalls(category.slug ?? '');
      _applyCategoryAppBar(category);
    }
    scrollToTop(animated: true);
  }

  void _ensureValidTabIndex() {
    log('Ensure Valid Tab Index ${(!mounted || !_canUseTabController || _isRedirecting)}');
    if (!mounted || !_canUseTabController || _isRedirecting) return;

    final int totalTabs = _categories.length + 1;
    final int currentIndex = _tabController.index;
    if (currentIndex >= totalTabs || currentIndex < 0) {
      _isRedirecting = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_canUseTabController) {
          _isRedirecting = false;
          return;
        }

        // 1. First, switch to "All" tab
        _tabController.animateTo(0);

        // 2. Apply "All" tab settings IMMEDIATELY
        _applyHomeGeneralSettingsToAppBar();

        // 3. Clear feature section products to prevent showing old data
        context
            .read<FeatureSectionProductBloc>()
            .add(ClearFeatureSectionProducts());

        // 4. Make API calls with empty slug (for "All" tab)
        apiCalls('');

        // 5. Force TabBarView rebuild to reset scroll
        setState(() {
          _tabBarViewKey = 'reset_${DateTime.now().millisecondsSinceEpoch}';
        });

        // 6. Scroll NestedScrollView to top
        if (nestedScrollController.hasClients) {
          nestedScrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }

        // Reset flag after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _isRedirecting = false;
          }
        });
      });
    }
  }

  bool get _canUseTabController =>
      _isTabControllerInitialized && !_isRecreatingTabController && mounted;

  void _initializeTabController(int categoriesLength) {
    if (_tabController.length != categoriesLength + 1 &&
        !_isRecreatingTabController) {
      _isRecreatingTabController = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          _isRecreatingTabController = false;
          return;
        }

        try {
          // Existing: Remove listener and dispose
          _tabController.removeListener(_onTabChanged);
          _tabController.dispose();

          _tabController = TabController(
            length: categoriesLength + 1,
            vsync: this,
          );

          _tabController.addListener(_onTabChanged);
          _isTabControllerInitialized = true;
          _isRecreatingTabController = false;

          if (mounted) {
            setState(() {});
          }
        } catch (e) {
          _isRecreatingTabController = false;
          log('Error recreating TabController: $e');
        }
      });
    }
  }

  void apiCalls(String slug) async {
    // Don't use controller if it's being recreated
    if (!_canUseTabController) {
      return;
    }

    final updatedSlug = _tabController.index == 0 ? '' : slug;
    final isForAllCategory = _tabController.index == 0 ? true : false;

    context.read<FeatureSectionProductBloc>().add(FetchFeatureSectionProducts(slug: updatedSlug));
    context.read<SubCategoryBloc>().add(FetchSubCategory(slug: updatedSlug, isForAllCategory: isForAllCategory));
    context.read<BrandsBloc>().add(FetchBrands(categorySlug: updatedSlug));
    context.read<BannerBloc>().add(FetchBanner(categorySlug: updatedSlug));
    context.read<GetUserCartBloc>().add(FetchUserCart());
    context.read<GetAddressListBloc>().add(FetchUserAddressList());
    context.read<NotificationBloc>().add(FetchNotifications());

    // Market Categories + Browse Stores home strips are global (not
    // per-category-tab) — only refetch when the user is on the All / first
    // tab. Mirrors the web app where these sections sit below the banner
    // regardless of tab.
    if (_tabController.index == 0) {
      context
          .read<HomeMarketCategoriesBloc>()
          .add(FetchHomeMarketCategories());
      if (!AppHelpers.systemVendorTypeIsSingle) {
        context
            .read<NearByStoreBloc>()
            .add(const FetchNearByStores(perPage: 15, searchQuery: ''));
      }
    }

    /*if (context.read<SettingsBloc>().state is! SettingsLoaded) {
      await Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.read<SettingsBloc>().add(FetchSettingsData(context: context));
        }
      });
    }*/
    await Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.read<SettingsBloc>().add(FetchSettingsData(context: context));
      }
    });
  }

  void _refreshDataForCurrentTab() {
    if (_tabController.index == 0) {
      apiCalls('');
    } else if (_categories.isNotEmpty &&
        (_tabController.index - 1) < _categories.length) {
      final selectedCategory = _categories[_tabController.index - 1];
      apiCalls(selectedCategory.slug ?? '');
    } else {
      apiCalls('');
    }
  }

  void _refreshApiOnLocationChange() {
    context.read<CategoryBloc>().add(FetchCategory(context: context));
    // Also re-run the full home-tab fetch so zone-dependent blocs (Banner /
    // SubCategory / FeatureSection / Brands) refresh too. Without this the
    // old "Delivery not available" state from the previous zone persists
    // and the home keeps showing "We're not here yet" even after the user
    // picks a covered zone.
    apiCalls('');
  }

  void _scrollListener() {
    double expandedHeight = 100.0.h;
    const double toolbarHeight = kToolbarHeight;
    final double flexibleSpaceHeight = expandedHeight - toolbarHeight;
    final double currentOffset = nestedScrollController.offset;
    final bool isHidden = currentOffset >= (flexibleSpaceHeight - 10);
    _appBarOpacity = (1 - (currentOffset / expandedHeight)).clamp(0.0, 1.0);

    if (_isFlexibleSpaceHidden != isHidden) {
      setState(() {
        _isFlexibleSpaceHidden = isHidden;
        if (_isFlexibleSpaceHidden) {
          textColor = _collapsedTextColor ??
              (Theme.of(context).brightness == Brightness.light
                  ? AppTheme.lightFontColor
                  : AppTheme.darkFontColor);
        } else {
          textColor = _originalTextColor ??
              (Theme.of(context).brightness == Brightness.light
                  ? AppTheme.lightFontColor
                  : AppTheme.darkFontColor);
        }
      });
    }
  }

  @override
  void dispose() {
    nestedScrollController.removeListener(_scrollListener);
    nestedScrollController.dispose();
    if (_isTabControllerInitialized) {
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
    }
    super.dispose();
  }

  Widget _buildFlexibleSpaceBackground() {
    if (!_isImageEmpty && backgroundImagePath.isNotEmpty) {
      return CustomImageContainer(
        imagePath: backgroundImagePath,
        fit: BoxFit.cover,
        placeholder: _buildGradientBackground(),
      );
    } else {
      return _buildGradientBackground();
    }
  }

  Widget _buildGradientBackground() {
    Color primaryColor = AppTheme.primaryColor;
    if (backgroundColor != null) {
      Color? categoryColor = hexStringToColor(backgroundColor);
      if (categoryColor != null) {
        primaryColor = categoryColor;
      }
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
    );
  }

  void _applyHomeGeneralSettingsToAppBar() {
    final settings = SettingsData.instance.homeGeneralSettings;
    final bgType = settings?.backgroundType ?? 'color';
    // Always recompute home search labels from the latest settings so the
    // hint refreshes when switching back from a category tab to "All".
    final List<String> homeSearchLabels = removeUnderscoresFromStringList(
      settings?.searchLabels ?? [],
    );

    if (settings == null || !isValidHomeGeneralSettings(settings)) {
      _collapsedTextColor = Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightFontColor
          : AppTheme.darkFontColor;
      updateAppBarBackground(
        image: '',
        bgColor: null,
        fontColor: Theme.of(context).brightness == Brightness.light
            ? AppTheme.lightFontColor
            : AppTheme.darkFontColor,
        searchHintTextList: homeSearchLabels,
      );
      return;
    }

    final String image =
        settings.backgroundImage.isNotEmpty ? settings.backgroundImage : '';
    final String? bgColor =
        settings.backgroundColor.isNotEmpty ? settings.backgroundColor : null;
    final Color? fontColor = settings.fontColor.isNotEmpty
        ? hexStringToColor(settings.fontColor)
        : null;

    updateAppBarBackground(
      image:  bgType == 'image' ? image : null,
      bgColor: bgColor,
      fontColor: fontColor,
      searchHintTextList: homeSearchLabels,
    );
  }

  void _handleLocationChange(String? locationIdentifier) {
    if (_lastLocationIdentifier == locationIdentifier) return;
    _lastLocationIdentifier = locationIdentifier;
    _refreshApiOnLocationChange();
    _refreshDataForCurrentTab();
  }

  void _applyCategoryAppBar(CategoryData category) {
    updateAppBarBackground(
      image: category.banner,
      bgColor: category.backgroundColor,
      fontColor: hexStringToColor(category.fontColor),
      // Mirror the home tab's transformation so category labels render
      // without underscores.
      searchHintTextList:
          removeUnderscoresFromStringList(category.searchLabels ?? []),
    );
  }

  Widget _buildHomeTabContent({required String categorySlug}) {
    return CustomRefreshIndicator(
      onRefresh: () async {
        apiCalls(categorySlug);
        if (categorySlug.isEmpty) {
          _applyHomeGeneralSettingsToAppBar();
        } else {
          final category = _categories.firstWhere(
            (item) => item.slug == categorySlug,
            orElse: () => CategoryData(),
          );
          _applyCategoryAppBar(category);
        }
        context.read<CategoryBloc>().add(FetchCategory(context: context));
      },
      child: HomeTabContentSection(
        brandsSectionTitle:
            AppLocalizations.of(context)?.topBrands ?? 'Top Brands',
        categorySlug: categorySlug,
        loadingPlaceholder: const HomeFeaturedPlaceholder(),
        buildFeatureSection: buildFeatureSection,
        onRetry: () => showHomeLocationBottomSheet(context),
      ),
    );
  }

  Widget _buildNotificationAction() {
    return IconButton(
      onPressed: () {
        GoRouter.of(context).push(AppRoutes.notifications);
      },
      icon: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          int unreadCount = 0;
          if (state is NotificationLoaded) {
            unreadCount = state.unreadCount;
          }
          return Badge(
            isLabelVisible: unreadCount > 0,
            label: Text(
              unreadCount > 9 ? '9+' : '$unreadCount',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            child: Icon(HeroiconsSolid.bell, color: textColor),
          );
        },
      ),
    );
  }

  Widget _buildHomeTabBar(List<Widget> tabBarTabs) {
    if (!_canUseTabController) {
      return const SizedBox(height: 50);
    }
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      enableFeedback: true,
      labelColor: textColor,
      automaticIndicatorColorAdjustment: true,
      unselectedLabelColor: textColor,
      labelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      indicatorColor: textColor,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      tabs: tabBarTabs,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<GetUserCartBloc, GetUserCartState>(
          listener: (context, state) {},
        ),
        BlocListener<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsLoaded && mounted) {
              if (!_canUseTabController || _tabController.index == 0) {
                _applyHomeGeneralSettingsToAppBar();
              }
            }
          },
        ),
      ],
      child: CustomScaffold(
        showViewCart: true,
        onConnectivityRestored: (context) async {
          context.read<CartBloc>().add(SyncLocalCart(context: context));
          _refreshDataForCurrentTab();
        },
        body: Stack(
          children: [
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (BuildContext context, CategoryState state) {
                final homeGeneralSettings =
                    SettingsData.instance.homeGeneralSettings;
                List<Widget> tabBarTabs = [
                  if (homeGeneralSettings != null &&
                      isValidHomeGeneralSettings(homeGeneralSettings))
                    HomeAllTabDynamic(
                      controller: _tabController,
                      settings: homeGeneralSettings,
                    )
                  else
                    const HomeAllTabStatic(),
                ];
                List<Widget> tabBarViewChildren = [
                  _buildHomeTabContent(categorySlug: ''),
                ];

                if (state is CategoryLoaded) {
                  // Pre-cache banner images so the first switch to any category
                  // tab is instant rather than waiting for the network.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    for (final category in state.categoryData) {
                      final banner = category.banner ?? '';
                      if (banner.startsWith('http')) {
                        precacheImage(NetworkImage(banner), context);
                      }
                    }
                  });

                  if (isRetry) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Future.delayed(const Duration(seconds: 1), () {
                        if (mounted) {
                          setState(() {
                            isRetry = false;
                          });
                        }
                      });
                    });
                  }
                  final newCategories = state.categoryData;
                  final int totalTabs = newCategories.length + 1;
                  final bool categoriesChanged =
                      _previousCategoryLength != newCategories.length;
                  final int oldLength = _previousCategoryLength;
                  _previousCategoryLength = newCategories.length;

                  _categories = newCategories;

                  if (_tabController.length != totalTabs) {
                    _initializeTabController(newCategories.length);

                    if (oldLength == 0) {
                      apiCalls('');
                    }
                  }

                  // Critical: Handle invalid tab index when category is removed
                  if (_tabController.index >= totalTabs) {
                    _ensureValidTabIndex();
                  } else if (categoriesChanged &&
                      _tabController.index > 0 &&
                      !_isRedirecting) {
                    // Verify current category still exists by slug
                    final currentIndex = _tabController.index - 1;
                    if (currentIndex >= 0 &&
                        currentIndex <
                            oldLength - (oldLength - newCategories.length)) {
                      // Check if we need to redirect
                      if (currentIndex >= newCategories.length) {
                        _ensureValidTabIndex();
                      } else {
                        Future.delayed(const Duration(milliseconds: 600), () {
                          apiCalls('');
                          _applyHomeGeneralSettingsToAppBar();
                        });
                      }
                    }
                  }

                  tabBarTabs.addAll(_categories.asMap().entries.map((entry) {
                    return HomeCategoryTab(
                      controller: _tabController,
                      category: entry.value,
                      index: entry.key,
                    );
                  }).toList());

                  // Build TabBarView children for categories
                  tabBarViewChildren
                      .addAll(_categories.asMap().entries.map((entry) {
                    final category = entry.value;
                    return _buildHomeTabContent(
                      categorySlug: category.slug ?? '',
                    );
                  }).toList());
                }

                if (state is CategoryFailed && isRetry) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Future.delayed(const Duration(seconds: 1), () {
                      if (mounted) {
                        setState(() {
                          isRetry = false;
                        });
                      }
                    });
                  });
                }

                return NestedScrollView(
                  controller: nestedScrollController,
                  physics: _canUseTabController
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      HomeAppBarSection(
                        canUseTabController: _canUseTabController,
                        appBarOpacity: _appBarOpacity,
                        textColor: textColor,
                        title: HomeTopAddressSection(
                          textColor: textColor,
                          onLocationChanged: _handleLocationChange,
                        ),
                        flexibleSpaceBackground:
                            _buildFlexibleSpaceBackground(),
                        searchField: CustomAnimatedTextField(
                          key: ValueKey(
                            searchHintList?.join('|') ?? '',
                          ),
                          searchHintTextList: searchHintList,
                        ),
                        tabBar: _buildHomeTabBar(tabBarTabs),
                        notificationsAction: Global.userData != null
                            ? _buildNotificationAction()
                            : null,
                        isDarkMode: isDarkMode(context),
                        darkBackgroundColor: AppTheme.darkProductCardColor,
                      ),
                      if (isRetry) const SliverToBoxAdapter()
                    ];
                  },
                  body: _canUseTabController
                      ? NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification notification) {
                            if (notification is ScrollUpdateNotification) {
                              final metrics = notification.metrics;
                              // Ignore horizontal strips (e.g. featured-section product rows) so reaching the last card doesn't trigger pagination.
                              if (metrics.axis == Axis.vertical &&
                                  metrics.pixels >=
                                      metrics.maxScrollExtent * 0.85) {
                                _loadMoreForCurrentTab(_tabController.index);
                              }
                            }
                            return false;
                          },
                          child: TabBarView(
                            key: ValueKey(_tabBarViewKey),
                            physics: const NeverScrollableScrollPhysics(),
                            controller: _tabController,
                            children: tabBarViewChildren,
                          ),
                        )
                      : !isRetry
                          ? NoDeliveryLocationPage(
                              onRetry: () => showHomeLocationBottomSheet(
                                context,
                              ),
                            )
                          : const SizedBox.shrink(),
                );
              },
            ),
            if (isRetry)
              const Positioned.fill(
                top: 120,
                child: Center(
                  child: CustomCircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _loadMoreForCurrentTab(int tabIndex) {
    if (_isLoadingMoreForTab[tabIndex] == true) return;

    final featureSectionState = context.read<FeatureSectionProductBloc>().state;
    if (featureSectionState is FeatureSectionProductLoaded &&
        !featureSectionState.hasReachedMax) {
      final slug = tabIndex == 0
          ? ''
          : (tabIndex - 1 < _categories.length)
              ? _categories[tabIndex - 1].slug ?? ''
              : '';

      _isLoadingMoreForTab[tabIndex] = true;
      context
          .read<FeatureSectionProductBloc>()
          .add(FetchMoreFeatureSectionProducts(slug: slug));

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _isLoadingMoreForTab[tabIndex] = false;
        }
      });
    }
  }

  void scrollToTop({bool animated = true}) {
    if (!nestedScrollController.hasClients) return;

    if (animated) {
      nestedScrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      nestedScrollController.jumpTo(0.0);
    }
  }
}
