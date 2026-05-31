import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/screens/cart_page/bloc/get_user_cart/get_user_cart_bloc.dart';
import 'package:aasyou/screens/save_for_later_page/bloc/save_for_later_bloc/save_for_later_bloc.dart';
import 'package:aasyou/screens/save_for_later_page/bloc/save_for_later_bloc/save_for_later_event.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_refresh_indicator.dart';
import 'package:aasyou/utils/widgets/custom_shimmer.dart';
import 'package:aasyou/utils/widgets/empty_states_page.dart';
import '../../../bloc/user_cart_bloc/user_cart_bloc.dart';
import '../../../bloc/user_cart_bloc/user_cart_event.dart';
import '../../../model/user_cart_model/cart_sync_action.dart';
import '../../../model/user_cart_model/user_cart.dart';
import '../../../utils/widgets/custom_product_card.dart';
import '../../../utils/widgets/custom_scaffold/custom_scaffold.dart';
import '../bloc/save_for_later_bloc/save_for_later_state.dart';
import '../model/save_for_later_model.dart';

class SaveForLaterPage extends StatefulWidget {
  const SaveForLaterPage({
    super.key,
  });

  @override
  State<SaveForLaterPage> createState() => _SaveForLaterPageState();
}

class _SaveForLaterPageState extends State<SaveForLaterPage> {

  @override
  void initState() {
    super.initState();

    context.read<SaveForLaterBloc>().add(
      FetchSavedProducts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetUserCartBloc, GetUserCartState>(
      listener: (BuildContext context, state) {
        if(state is GetUserCartLoading) {
          context.read<SaveForLaterBloc>().add(FetchSavedProducts());
        }
      },
      child: CustomScaffold(
        showViewCart: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: 'Saved for later',
        showAppBar: true,
        body: CustomRefreshIndicator(
          onRefresh: () async {
            context.read<SaveForLaterBloc>().add(
              FetchSavedProducts(),
            );
          },
          child: BlocConsumer<SaveForLaterBloc, SaveForLaterState>(
            listener: (BuildContext context, SaveForLaterState state) {
              if(state is ProductSavedSuccess) {
                context.read<SaveForLaterBloc>().add(
                  FetchSavedProducts(),
                );
              }
            },
            builder: (BuildContext context, SaveForLaterState state) {
              if (state is SaveForLaterLoaded) {
                return Container(
                  color: Theme.of(context).colorScheme.primary,
                  child: Column(
                    children: [
                      productList(
                        productData: state.savedItems,
                        hasReachedMax: state.hasReachedMax,
                      ),
                    ],
                  ),
                );
              }
              if (state is SaveForLaterLoading) {
                return const CustomCircularProgressIndicator();
              } else if (state is SaveForLaterFailed) {
                return NoDeliveryLocationPage(
                  onRetry: (){
                    context.read<SaveForLaterBloc>().add(
                      FetchSavedProducts(),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget productList({required List<SavedItem> productData, required bool hasReachedMax,}) {
    return Expanded(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildContent(productData, hasReachedMax),
      ),
    );
  }

  Widget _buildContent(List<SavedItem> productData, bool hasReachedMax,) {

    if (productData.isEmpty) {
      return NoProductPage(
        onRetry: (){
          context.read<SaveForLaterBloc >().add(FetchSavedProducts());
        },
      );
    }

    return _buildProductGrid(productData, hasReachedMax);
  }

  Widget _buildProductGrid(List<SavedItem> productData, bool hasReachedMax) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet(context) ? 4 : 3,
          crossAxisSpacing: 14.w,
          mainAxisSpacing: 10.h,
          // +22.h to leave room for the "Recommended" chip in the card.
          mainAxisExtent: 222.h,
        ),
        itemCount: productData.length,
        itemBuilder: (context, index) => _buildGridItem(productData, index),
      ),
    );
  }

  Widget _buildGridItem(List<SavedItem> productData, int index) {
    final product = productData[index];

    return CustomProductCard(
      productId: product.product!.id!,
      productImage: product.product!.image!,
      productSlug: product.product!.slug!,
      productName: product.product!.name!,
      productPrice: product.variant!.price.toString(),
      specialPrice: product.variant!.specialPrice.toString(),
      productTags: const [],
      estimatedDeliveryTime: product.product!.estimatedDeliveryTime.toString(),
      assetImage: '',
      ratings: double.parse(product.product!.ratings.toString()),
      ratingCount: product.product!.ratingCount!,
      onAddToCart: (){
        final item = UserCart(
            productId: product.id.toString(),
            variantId: product.productVariantId.toString(),
            variantName: product.variant!.title.toString(),
            vendorId: product.storeId.toString(),
            name: product.product!.name.toString(),
            image: product.product!.image.toString(),
            price: product.variant!.specialPrice!.toDouble(),
            originalPrice: product.variant!.price!.toDouble(),
            quantity: product.product!.quantityStepSize!,
            serverCartItemId: null,
            syncAction: CartSyncAction.add,
            updatedAt: DateTime.now(),
            minQty: product.product!.minimumOrderQuantity!,
            maxQty: product.product!.totalAllowedQuantity!,
            isOutOfStock: product.variant!.stock! <= 0,
            isSynced: false
        );
        context.read<CartBloc>().add(AddToCart(
          item: item,
          context:  context,
          replaceQty: true
        ));
        // context.read<AddToCartBloc>().add(
      },
      isStoreOpen: product.product!.storeStatus!.isOpen ?? true,
      isWishListed: false,
      productVariantId: product.variant!.id!,
      storeId: product.storeId!,
      totalStocks: product.variant!.stock!,
      showWishlist: false,
      wishlistItemId: 0,
      imageFit: product.product!.imageFit ?? 'contain',
      quantityStepSize: product.product!.quantityStepSize!,
      minQty: product.product!.minimumOrderQuantity!,
      totalAllowedQuantity: product.product!.totalAllowedQuantity!,
      // TODO: wire to product.product!.isRecommended once the
      // SavedItem.product model exposes is_recommended from the backend.
      isRecommended: false,
    );

  }

  Widget productShimmer() {
    return Column(
      children: [
        ShimmerWidget.rectangular(
          isBorder: true,
          height: 130,
          width: 130,
          borderRadius: 15,
        ),
        const SizedBox(height: 10.0),
        ShimmerWidget.rectangular(
          isBorder: true,
          height: 15,
          width: 130,
          borderRadius: 15,
        ),
      ],
    );
  }
}