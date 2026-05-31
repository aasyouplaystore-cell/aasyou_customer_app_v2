import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/global.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/utils/widgets/animated_button.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';

import '../../../bloc/user_cart_bloc/user_cart_state.dart';
import '../../../config/theme.dart';

class CustomScaffoldCartButton extends StatelessWidget {
  final Animation<double> widthAnimation;
  final Animation<double> contentOpacityAnimation;
  final Animation<Offset> imageSlideAnimation;
  final int stableItemCount;
  final CartState cartState;

  const CustomScaffoldCartButton({
    super.key,
    required this.widthAnimation,
    required this.contentOpacityAnimation,
    required this.imageSlideAnimation,
    required this.stableItemCount,
    required this.cartState,
  });

  List<String> _getCartItems() {
    if (cartState is CartLoaded) {
      return (cartState as CartLoaded)
          .items
          .map((item) => item.image)
          .where((image) => image.isNotEmpty)
          .take(3)
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _getCartItems();

    return AnimatedButton(
      animationType: TapAnimationType.scale,
      onTap: () {
        if (Global.userData != null) {
          GoRouter.of(context).push(AppRoutes.cart);
        } else {
          GoRouter.of(context).push(AppRoutes.login);
        }
      },
      child: Container(
        width: widthAnimation.value,
        height: 40.h,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 5,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (cartItems.isNotEmpty)
              Positioned(
                left: widthAnimation.value < 48.0.w ? 5.2.w : 22.w,
                top: 5.h,
                bottom: 5.h,
                child: Center(
                  child: Transform.translate(
                    offset: widthAnimation.value < 48.0.w
                        ? Offset.zero
                        : imageSlideAnimation.value * 20.w,
                    child: widthAnimation.value < 48.0.w
                        ? SingleProductImage(imageUrl: cartItems.first)
                        : AnimatedFacePile(cartItems: cartItems),
                  ),
                ),
              ),
            if (widthAnimation.value > 48.0.w)
              Center(
                child: Opacity(
                  opacity: contentOpacityAnimation.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 53.w),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$stableItemCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              stableItemCount > 1 ? 'items' : 'item',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SingleProductImage extends StatefulWidget {
  final String imageUrl;

  const SingleProductImage({
    super.key,
    required this.imageUrl,
  });

  @override
  State<SingleProductImage> createState() => _SingleProductImageState();
}

class _SingleProductImageState extends State<SingleProductImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              height: 30.h,
              width: 30.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 1.6,
                  color: Colors.white,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CustomImageContainer(
                  imagePath: widget.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedFacePile extends StatefulWidget {
  final List<String> cartItems;

  const AnimatedFacePile({
    super.key,
    required this.cartItems,
  });

  @override
  State<AnimatedFacePile> createState() => _AnimatedFacePileState();
}

class _AnimatedFacePileState extends State<AnimatedFacePile>
    with TickerProviderStateMixin {
  late AnimationController _pileController;
  late AnimationController _newItemController;
  late List<Animation<double>> _slideAnimations;
  late Animation<double> _newItemScaleAnimation;
  late Animation<double> _newItemOpacityAnimation;
  int _lastAvatarCount = 0;
  bool _isNewItemAnimating = false;

  List<String> get avatars => widget.cartItems.reversed.take(3).toList();

  @override
  void initState() {
    super.initState();
    _pileController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _newItemController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _newItemScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _newItemController,
      curve: Curves.elasticOut,
    ));

    _newItemOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _newItemController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _buildAnimationsForCount(avatars.length);
    _lastAvatarCount = avatars.length;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pileController.forward();
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedFacePile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentCount = avatars.length;

    if (currentCount > _lastAvatarCount) {
      _isNewItemAnimating = true;
      _newItemController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _isNewItemAnimating = false;
          });
        }
      });
      _buildAnimationsForCount(currentCount);
      _pileController.forward(from: 1.0);
    } else if (currentCount != _lastAvatarCount) {
      _buildAnimationsForCount(currentCount);
      _pileController
        ..reset()
        ..forward();
    }

    _lastAvatarCount = currentCount;
  }

  @override
  void dispose() {
    _pileController.dispose();
    _newItemController.dispose();
    super.dispose();
  }

  void _buildAnimationsForCount(int count) {
    _slideAnimations = List.generate(count, (index) {
      return Tween<double>(
        begin: 0.0,
        end: index * 15.0,
      ).animate(CurvedAnimation(
        parent: _pileController,
        curve: Interval(
          (index * 0.15).clamp(0.0, 1.0),
          (0.7 + (index * 0.1)).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pileController, _newItemController]),
      builder: (context, child) {
        final count = avatars.length;
        if (_slideAnimations.length != count) {
          _buildAnimationsForCount(count);
        }

        return SizedBox(
          height: 38.h,
          width: 75.w,
          child: Stack(
            children: List.generate(
              count,
              (index) {
                final slide = index < _slideAnimations.length
                    ? _slideAnimations[index]
                    : AlwaysStoppedAnimation<double>(index * 10.0);

                final isNewestItem = index == 0;
                final scale = (_isNewItemAnimating && isNewestItem)
                    ? _newItemScaleAnimation.value
                    : 1.0;
                final opacity = (_isNewItemAnimating && isNewestItem)
                    ? _newItemOpacityAnimation.value
                    : 1.0;

                return Positioned(
                  left: slide.value,
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        height: 30.h,
                        width: 30.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: isTablet(context) ? 1.0 : 1.4.sp,
                            color: Colors.white,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CustomImageContainer(
                            imagePath: avatars[index],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
