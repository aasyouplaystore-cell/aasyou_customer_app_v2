import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../bloc/user_cart_bloc/user_cart_bloc.dart';
import '../../../bloc/user_cart_bloc/user_cart_state.dart';
import '../connectivity_wrapper.dart';
import 'custom_scaffold_cart_button.dart';
import 'custom_scaffold_default_app_bar.dart';

class CustomScaffold extends StatefulWidget {
  final Widget body;
  final String? title;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool? showAppBar;
  final List<Widget>? appBarActions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final PreferredSizeWidget? appBar;
  final int itemCount;
  final String? itemText;
  final bool showViewCart;
  final FutureOr<void> Function(BuildContext context)? onConnectivityRestored;
  final FutureOr<void> Function(BuildContext context)? onConnectivityLost;
  final FutureOr<void> Function(bool isConnected, BuildContext context)?
      onConnectivityChanged;
  final bool notifyConnectivityStatusOnInit;

  const CustomScaffold({
    super.key,
    required this.body,
    this.title,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.showAppBar,
    this.appBarActions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.appBar,
    this.itemCount = 3,
    this.itemText,
    this.showViewCart = true,
    this.onConnectivityRestored,
    this.onConnectivityLost,
    this.onConnectivityChanged,
    this.notifyConnectivityStatusOnInit = false,
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _expandController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _widthAnimation;
  late Animation<double> _contentOpacityAnimation;
  late Animation<Offset> _imageSlideAnimation;

  bool _isCartVisible = false;
  bool _isCurrentlyConnected = true;
  static bool _hasAnimatedGlobally = false;
  static bool _hasShownFullCartAnimation = false;
  int _previousItemCount = 0;
  bool _hasInitializedCart = false;
  int _stableItemCount = 0;

  @override
  void initState() {
    super.initState();

    // Controller for slide up/down animation - made faster
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Controller for expand/collapse animation - made faster
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Slide animation with smoother curve
    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 25.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Scale animation with smoother pop
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Opacity for smoother fade
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Width animation for expand/collapse
    _widthAnimation = Tween<double>(
      begin: 40.0.w,
      end: 190.0.w,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    ));

    // Content opacity with better timing
    _contentOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    // Image slide animation
    _imageSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.8, 0.0),
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void didUpdateWidget(CustomScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget update logic removed - handled in build method
  }

  Future<void> _animateIn() async {
    if (_slideController.isAnimating || _expandController.isAnimating) {
      return;
    }

    await _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 80));
    await _expandController.forward();
    _hasShownFullCartAnimation = true;
  }

  Future<void> _animateOut() async {
    if (_slideController.isAnimating || _expandController.isAnimating) {
      return;
    }

    await _expandController.reverse();
    await Future.delayed(const Duration(milliseconds: 80));
    await _slideController.reverse();
    setState(() {
      _isCartVisible = false;
    });
    _hasShownFullCartAnimation = false;
  }

  void _showCartWithoutAnimation() {
    _slideController.value = 1.0;
    _expandController.value = 1.0;
    setState(() {
      _isCartVisible = true;
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      onStatusChange: _handleConnectivityStatus,
      notifyStatusChangeOnInit: widget.notifyConnectivityStatusOnInit,
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartBlocState) {
          final hasCartItems =
              cartBlocState is CartLoaded && cartBlocState.items.isNotEmpty;

          int currentItemCount = 0;
          bool isValidCart = false;

          if (cartBlocState is CartLoaded) {
            currentItemCount = cartBlocState.totalItems;
            // Valid only if items exist
            isValidCart = currentItemCount > 0;
          }

          if (isValidCart) {
            _stableItemCount = currentItemCount;
          } else {}

          // Only process animation logic when cart data is actually loaded
          final isCartDataLoaded = cartBlocState is CartLoaded;

          // Animation logic
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Skip processing if cart data hasn't loaded yet
            if (!isCartDataLoaded) {
              log('Cart data not loaded yet, skipping animation logic');
              return;
            }

            log('Has cart items: $hasCartItems, Is cart visible: $_isCartVisible, Item count: $currentItemCount');

            // Initialize cart state on first load
            if (!_hasInitializedCart) {
              _hasInitializedCart = true;
              _previousItemCount = currentItemCount;

              if (hasCartItems) {
                setState(() {
                  _isCartVisible = true;
                });

                // Show animation only on app startup with existing items
                if (!_hasAnimatedGlobally &&
                    !_hasShownFullCartAnimation &&
                    currentItemCount > 0) {
                  log('Initial load: Animating app startup with existing cart');
                  _hasAnimatedGlobally = true;
                  _animateIn();
                } else {
                  log('Initial load: Showing cart without animation');
                  _showCartWithoutAnimation();
                }
              }
              return;
            }
            if (hasCartItems && !_isCartVisible) {
              // Cart has items and is not visible
              setState(() {
                _isCartVisible = true;
              });

              // Check if we should show full cart animation
              bool shouldShowFullAnimation = false;

              // Condition 1: First product added (cart was empty, now has 1 item)
              if (_previousItemCount == 0 && currentItemCount == 1) {
                log('Animating: First product added to cart (full animation)');
                shouldShowFullAnimation = true;
              }

              // Show full animation or just display cart
              if (shouldShowFullAnimation) {
                _animateIn();
              } else if ((_slideController.value != 1.0 ||
                      _expandController.value != 1.0) &&
                  !_slideController.isAnimating &&
                  !_expandController.isAnimating) {
                log('Showing cart without full animation (page navigation or additional product)');
                _showCartWithoutAnimation();
              }
            } else if (!hasCartItems && _isCartVisible && _hasInitializedCart) {
              log('Animating out: Cart is now empty');
              _animateOut();
              _hasInitializedCart = false;
            }

            // Update previous count
            _previousItemCount = currentItemCount;
          });

          log('Building CustomScaffold: hasCartItems=$hasCartItems, itemCount=$currentItemCount, _isCartVisible=$_isCartVisible');

          return Scaffold(
            backgroundColor:
                widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
            appBar: widget.appBar ??
                (widget.showAppBar == true
                    ? CustomScaffoldDefaultAppBar(
                        title: widget.title,
                        actions: widget.appBarActions,
                      )
                    : null),
            body: Stack(
              children: [
                widget.body,

                /// Animated VIEW CART
                if (_isCartVisible &&
                    widget.showViewCart &&
                    _previousItemCount > 0)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: AnimatedBuilder(
                      animation: Listenable.merge(
                          [_slideController, _expandController]),
                      builder: (context, child) {
                        final bottomOffset = _isCurrentlyConnected ? 0.0 : 45.0;
                        return Positioned(
                          bottom: _slideAnimation.value + bottomOffset,
                          left: 0,
                          right: 0,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Opacity(
                              opacity: _opacityAnimation.value,
                              child: Center(
                                child: CustomScaffoldCartButton(
                                  widthAnimation: _widthAnimation,
                                  contentOpacityAnimation:
                                      _contentOpacityAnimation,
                                  imageSlideAnimation: _imageSlideAnimation,
                                  stableItemCount: _stableItemCount,
                                  cartState: cartBlocState,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: widget.bottomNavigationBar,
            floatingActionButton: widget.floatingActionButton,
            floatingActionButtonLocation: widget.floatingActionButtonLocation,
          );
        },
      ),
    );
  }

  void _handleConnectivityStatus(bool isConnected) {
    log('Handle Connectivity Status $isConnected');
    if (_isCurrentlyConnected == isConnected) {
      _invokeConnectivityChangedCallback(isConnected);
      return;
    }

    _isCurrentlyConnected = isConnected;
    _invokeConnectivityChangedCallback(isConnected);

    if (isConnected) {
      _invokeFutureOr(widget.onConnectivityRestored);
    } else {
      _invokeFutureOr(widget.onConnectivityLost);
    }
  }

  void _invokeConnectivityChangedCallback(bool isConnected) {
    final callback = widget.onConnectivityChanged;
    if (callback == null) return;

    final result = callback(isConnected, context);
    if (result is Future<void>) {
      unawaited(result);
    }
  }

  void _invokeFutureOr(
      FutureOr<void> Function(BuildContext context)? callback) {
    if (callback == null) return;

    final result = callback(context);
    if (result is Future<void>) {
      unawaited(result);
    }
  }
}
