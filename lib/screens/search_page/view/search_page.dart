import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/screens/product_listing_page/model/product_listing_type.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';
import 'package:aasyou/utils/widgets/hero_tags.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:aasyou/utils/widgets/custom_textfield.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../model/recent_product_model/recent_product_model.dart';
import '../../../services/recent_product/recent_product_service.dart';
import '../../ad_campaign/bloc/ad_click_bloc/ad_click_bloc.dart';
import '../../product_detail_page/model/product_detail_model.dart';
import '../../product_detail_page/view/product_detail_page.dart';
import '../../product_listing_page/bloc/product_listing/product_listing_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late SpeechToText _speechToText;
  bool _speechAvailable = false;
  bool _microphoneGranted = false;
  bool dialogShown = false;
  String _lastWords = '';
  Timer? _listeningStatusTimer;
  ValueNotifier<bool> isListening = ValueNotifier<bool>(false);
  String totalProducts = '0';
  Timer? _debounceTimer;

  // Simplified options for speech
  final options = SpeechListenOptions(
    onDevice: false,
    listenMode: ListenMode.confirmation,
    cancelOnError: true,
    partialResults: true,
    autoPunctuation: true,
    enableHapticFeedback: true,
  );

  @override
  void initState() {
    super.initState();

    _speechToText = SpeechToText();
    isListening = ValueNotifier<bool>(false);
    _focusNode.addListener(_handleFocusChange);
    _focusNode.requestFocus();
    _initializeSpeechToText();

    // Only reset if we have search results loaded, not if we have category/other listings
    final currentState = context.read<ProductListingBloc>().state;
    if (currentState is ProductListingLoaded) {
      // Check if current loaded state is from a search
      final currentType = context.read<ProductListingBloc>().type;
      if (currentType == ProductListingType.search) {
        context.read<ProductListingBloc>().add(ResetSearchKeywords());
      }
    } else if (currentState is ProductListingInitial) {
      // Already in initial state, no need to reset
    }
  }

  Future<void> _initializeSpeechToText() async {
    // iOS: Only request microphone manually.

    bool hasMicPermission = false;

    if (Platform.isAndroid) {
      final micStatus = await Permission.microphone.request();
      final speechStatus = await Permission.speech.request();
      hasMicPermission = micStatus == PermissionStatus.granted &&
          speechStatus == PermissionStatus.granted;
    } else if (Platform.isIOS) {
      final micStatus = await Permission.microphone.request();
      hasMicPermission = micStatus == PermissionStatus.granted;
    }

    _microphoneGranted = hasMicPermission;

    if (!_microphoneGranted) {
      debugPrint('Microphone permission not granted');
      return;
    }

    try {
      final available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );
      if (mounted) {
        setState(() {
          _speechAvailable = available;
        });
      }
    } catch (e) {
      debugPrint('Speech init error: $e');
    }
  }

  void _onSpeechStatus(String status) {
    log('Speech status: $status');
    if ((status == 'notListening' || status == 'done') && mounted) {
      isListening.value = false;

      // iOS might not send finalResult=true via _onSpeechResult, so we handle completion here
      if (_lastWords.isNotEmpty && dialogShown) {
        log('Auto-closing search dialog based on speech status: $status');
        _stopListening();
        if (Navigator.canPop(context)) Navigator.pop(context);
        
        _onQueryChanged(_lastWords);

        setState(() {
          dialogShown = false;
        });
      }
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    debugPrint('Speech error: ${error.errorMsg}');
    if (mounted) {
      setState(() {
        isListening.value = false;
      });
    }
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {}
  }

  void _startListening() async {
    if (_speechToText.isListening || dialogShown) return;

    if (!_microphoneGranted || !_speechAvailable) {
      await _initializeSpeechToText();
    }
    if (!_microphoneGranted || !_speechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.microphoneUnavailable)),
        );
      }
      return;
    }

    setState(() {
      dialogShown = true;
      isListening.value = true;
    });

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SearchPopUp(
          isListening: isListening,
          onRetry: () {
            if (_speechToText.isListening) _speechToText.stop();
            isListening.value = true;
            _startSpeechRecognition();
          },
          onClose: () {
            _stopListening();
            Navigator.of(context).pop();
          },
        ),
      ).then((_) => _onDialogDismissed());
    }
    // Start actual recognition
    _startSpeechRecognition();
  }

  void _startSpeechRecognition() async {
    setState(() {
      _lastWords = '';
      _searchController.clear();
    });

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3), // Reduced to 3 seconds for snappier submit
        localeId: 'en_US',
        listenOptions: options,
      );

      // Monitor listening status
      _startListeningStatusCheck();
    } catch (e) {
      debugPrint('Speech listen error: $e');
      isListening.value = false;
    }
  }

  void _startListeningStatusCheck() {
    _listeningStatusTimer?.cancel();
    _listeningStatusTimer =
        Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!_speechToText.isListening && mounted) {
        if (isListening.value) {
          isListening.value = false;
        }
        
        // Fallback for closing dialog if speech finished but dialog is still open
        if (_lastWords.isNotEmpty && dialogShown) {
          log('Auto-closing via timer check');
          _stopListening();
          if (Navigator.canPop(context)) Navigator.pop(context);
          _onQueryChanged(_lastWords);
          setState(() {
            dialogShown = false;
          });
        }
      }
      
      if (!dialogShown || !_speechToText.isListening) {
        timer.cancel();
      }
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _searchController.text = _lastWords;
    });

    if (result.finalResult && _lastWords.isNotEmpty && dialogShown) {
      log('Final Result');
      _stopListening();
      // Auto-close dialog on final result
      if (Navigator.canPop(context)) Navigator.pop(context);

      // Trigger search
      _onQueryChanged(_lastWords);

      setState(() {
        dialogShown = false;
        isListening.value = false;
      });
    }
  }

  void _stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    _listeningStatusTimer?.cancel();
    isListening.value = false;
  }

  void _onDialogDismissed() {
    _stopListening();
    dialogShown = false;
  }

  @override
  void dispose() {
    _stopListening();
    _listeningStatusTimer?.cancel();
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    isListening.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
  }

  void _onQueryChanged(String value) {
    _debounceTimer?.cancel();
    log('Query Changed');

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      // Optionally also clear keywords in bloc via a Clear event
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      context.read<ProductListingBloc>().add(
            FetchListingProducts(
              type: ProductListingType.search,
              identifier: trimmed,
            ),
          );
    });
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _focusNode.requestFocus();
    _onQueryChanged(suggestion);
    GoRouter.of(context).push(AppRoutes.productListing, extra: {
      'isTheirMoreCategory': false,
      'title': suggestion,
      'logo': '',
      'totalProduct': totalProducts,
      'type': ProductListingType.search,
      'identifier': suggestion,
    });
    // Optionally perform search here if needed, but per instruction, don't show search data
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      showViewCart: false,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          // Search Bar (adapted from reference)
          Padding(
            padding: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    _clearSearch();
                    GoRouter.of(context).pop();
                  },
                  child: SizedBox(
                    height: 30.h,
                    width: 35.h,
                    child: Center(
                      child: Icon(
                        Directionality.of(context) == TextDirection.ltr
                            ? TablerIcons.chevron_left
                            : TablerIcons.arrow_right,
                        size: isTablet(context) ? 18.r : 24.r,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: SizedBox(
                    height: 35.h,
                    child: CustomTextFormField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: _onQueryChanged,
                      hintText: l10n.searchProducts,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.primary,
                      onFieldSubmitted: (value) {
                        if (value.length < 2) {
                          ToastManager.show(
                              context: context,
                              message: AppLocalizations.of(context)!
                                  .pleaseEnterAtleast2Letters);
                        } else {
                          GoRouter.of(context)
                              .push(AppRoutes.productListing, extra: {
                            'isTheirMoreCategory': false,
                            'title': value,
                            'logo': '',
                            'totalProduct': totalProducts,
                            'type': ProductListingType.search,
                            'identifier': value,
                          });
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
                Container(
                  height: 30.h,
                  width: 30.h,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          width: 1.0,
                          color: Theme.of(context).colorScheme.outline)),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    onPressed: () {
                      if (!_speechToText.isListening) {
                        HapticFeedback.mediumImpact();
                        _startListening();
                      } else {
                        _stopListening();
                      }
                    },
                    icon: Icon(
                      HeroiconsOutline.microphone,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
              ],
            ),
          ),
          // Suggestions List (adapted from reference, no search data shown)
          Expanded(
            child: BlocBuilder<ProductListingBloc, ProductListingState>(
              builder: (context, state) {
                final query = _searchController.text.trim();

                return FutureBuilder<Box<RecentProduct>>(
                  future: Hive.openBox<RecentProduct>(
                      RecentlyViewedService.boxName),
                  builder: (context, recentSnapshot) {
                    Widget recentWidget;

                    if (!recentSnapshot.hasData ||
                        recentSnapshot.data!.isEmpty) {
                      recentWidget = const SizedBox.shrink();
                    } else {
                      final box = recentSnapshot.data!;
                      final recentItems = box.values
                          .toList()
                          .reversed
                          .groupListsBy((item) => item.id)
                          .values
                          .map((group) => group.first)
                          .toList();

                      recentWidget = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recently Viewed',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    await RecentlyViewedService.clear();
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    TablerIcons.trash,
                                    size: 18.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 120.h,
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              scrollDirection: Axis.horizontal,
                              itemCount: recentItems.length,
                              itemBuilder: (context, index) {
                                final item = recentItems[index];
                                log('Recently Viewed Items ${item.id}');
                                return InkWell(
                                  onTap: () {
                                    GoRouter.of(context).push(
                                      AppRoutes.productDetailPage,
                                      extra: {
                                        'productSlug': item.productSlug,
                                        'title': item.name,
                                        'mainImage': item.imageUrl,
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 100.w,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 4.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          child: CustomImageContainer(
                                            imagePath: item.imageUrl,
                                            height: 80.h,
                                            width: 100.w,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          item.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    // ────────────────────────────────────────────────

                    if (query.isEmpty) {
                      // Empty query → show recents OR classic empty state
                      if (recentWidget is SizedBox) {
                        // No recents → show centered prompt
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                TablerIcons.search,
                                size: isTablet(context) ? 40.r : 80.sp,
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                l10n.searchForProducts,
                                style: TextStyle(
                                  fontSize: isTablet(context) ? 30 : 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40.w),
                                child: Text(
                                  l10n.typeProductNameBrandOrCategory,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isTablet(context) ? 20 : 14.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Has recents → show only recents (with some top spacing)
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 20.h),
                              recentWidget,
                              SizedBox(height: 40.h),
                            ],
                          ),
                        );
                      }
                    }

                    // ────────────────────────────────────────────────

                    List<Widget> children = [];

                    if (recentWidget is! SizedBox) {
                      children.add(recentWidget);
                    }

                    // Add search-related content
                    if (state is ProductListingLoading) {
                      children.add(
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CustomCircularProgressIndicator(),
                                SizedBox(height: 20.h),
                                Text(
                                  l10n.searching,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else if (state is ProductListingLoaded) {
                      final keywords = state.keywords ?? [];
                      final products = state.productList;
                      totalProducts = state.totalProducts.toString();

                      final List<dynamic> combinedList = [];
                      combinedList.addAll(
                          keywords.map((k) => {'type': 'keyword', 'value': k}));
                      combinedList.addAll(
                          products.map((p) => {'type': 'product', 'value': p}));

                      if (combinedList.isEmpty) {
                        children.add(Expanded(child: _buildNoResultsWidget()));
                      } else {
                        children.add(
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.only(top: 10.h),
                              itemCount: combinedList.length,
                              itemBuilder: (context, index) {
                                final item = combinedList[index];
                                final isKeyword = item['type'] == 'keyword';
                                final data = item['value'];
                                if (isKeyword) {
                                  // Keyword suggestion tile
                                  final String suggestion = data as String;
                                  return InkWell(
                                    onTap: () => _onSuggestionTap(suggestion),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 4.0),
                                      child: Row(
                                        children: [
                                          // Leading icon
                                          const Icon(TablerIcons.zoom,
                                              size: 22, color: Colors.grey),

                                          // Gap between leading and title (default ListTile horizontalTitleGap is 16; adjust as needed)
                                          const SizedBox(width: 16),

                                          // Title text - takes remaining space
                                          Expanded(
                                            child: Text(
                                              suggestion,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                          ),

                                          // Trailing arrow-up icon (tappable separately)
                                          InkWell(
                                            onTap: () {
                                              _searchController.text =
                                                  suggestion;
                                              _searchController.selection =
                                                  TextSelection.fromPosition(
                                                TextPosition(
                                                    offset: suggestion.length),
                                              );
                                              _focusNode.requestFocus();
                                              _onQueryChanged(suggestion);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                  8.0), // Small hit area for tap
                                              child: Icon(
                                                Directionality.of(context) ==
                                                        TextDirection.ltr
                                                    ? HeroiconsOutline
                                                        .arrowUpLeft
                                                    : HeroiconsOutline
                                                        .arrowUpRight,
                                                size: 20,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  final ProductData product =
                                      data as ProductData;
                                  return OpenContainer(
                                    clipBehavior: Clip.antiAlias,
                                    transitionDuration:
                                        const Duration(milliseconds: 500),
                                    transitionType:
                                        ContainerTransitionType.fade,
                                    closedElevation: 0,
                                    openElevation: 0,
                                    closedShape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r)),
                                    openShape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero),
                                    closedColor: Colors.transparent,
                                    openColor: Colors.transparent,
                                    tappable: false,
                                    useRootNavigator: true,
                                    closedBuilder: (context, openContainer) {
                                      return GestureDetector(
                                        onTap: () {
                                          if (product.isSponsored &&
                                              product.campaignId > 0) {
                                            context
                                                .read<AdClickBloc>()
                                                .add(RecordClick(
                                                  campaignId:
                                                      product.campaignId,
                                                  visitorKey:
                                                      product.visitorKey,
                                                ));
                                          }
                                          openContainer();
                                        },
                                        child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0, vertical: 8.0),
                                        child: Row(
                                          children: [
                                            // Leading image (same as your ClipRRect + CustomImageContainer)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: product
                                                      .mainImage.isNotEmpty
                                                  ? Hero(
                                                      tag: productHeroTag(product.slug),
                                                      child:
                                                          CustomImageContainer(
                                                        imagePath:
                                                            product.mainImage,
                                                        width: 40,
                                                        height: 40,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.image_not_supported,
                                                      size: 40),
                                            ),

                                            // Space between image and title (default ListTile gap is ~16; tweak to your liking)
                                            const SizedBox(width: 12),

                                            // Title text - takes all remaining space
                                            Expanded(
                                              child: Text(
                                                product.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      );
                                    },
                                    openBuilder: (context, closeContainer) {
                                      return ProductDetailPage(
                                        productSlug: product.slug,
                                        initialData: ProductInitialData(
                                          title: product.title,
                                          mainImage: product.mainImage,
                                        ),
                                        closeContainer: closeContainer,
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      }
                    } else if (state is ProductListingFailed) {
                      children.add(
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  TablerIcons.mood_empty,
                                  size: isTablet(context) ? 40.r : 80.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.5),
                                ),
                                SizedBox(height: 24.h),
                                Text(
                                  l10n.noProductsFound,
                                  style: TextStyle(
                                    fontSize: isTablet(context) ? 30 : 20.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 40.w),
                                  child: Text(
                                    l10n.trySearchingWithDifferentKeywords,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isTablet(context) ? 20 : 14.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      children.add(const Expanded(child: SizedBox.shrink()));
                    }

                    return Column(
                      children: children,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsWidget({String? error}) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            TablerIcons.mood_empty,
            size: isTablet(context) ? 40.r : 80.sp,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          SizedBox(height: 24.h),
          Text(
            error ?? l10n.noProductsFound,
            style: TextStyle(
              fontSize: isTablet(context) ? 30 : 20.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              l10n.trySearchingWithDifferentKeywords,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet(context) ? 20 : 14.sp,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// SearchPopUp (adapted from reference)
class SearchPopUp extends StatelessWidget {
  final ValueNotifier<bool> isListening;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const SearchPopUp({
    super.key,
    required this.isListening,
    required this.onRetry,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Center(
        child: Text(
          l10n.speakNow,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/animations/speech_to_text_animation.json',
            height: 120.h,
            width: 120.h,
            animate: isListening.value,
            repeat: isListening.value,
          ),
          SizedBox(height: 16.h),
          ValueListenableBuilder<bool>(
            valueListenable: isListening,
            builder: (_, listening, __) {
              return Text(
                listening ? l10n.listening : l10n.noSpeechDetected,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: listening ? Colors.green : Colors.red,
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: isListening,
          builder: (_, listening, __) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!listening)
                  TextButton(onPressed: onRetry, child: Text(l10n.retry)),
                if (!listening) const SizedBox(width: 12),
                TextButton(onPressed: onClose, child: Text(l10n.close)),
              ],
            );
          },
        ),
      ],
    );
  }
}
