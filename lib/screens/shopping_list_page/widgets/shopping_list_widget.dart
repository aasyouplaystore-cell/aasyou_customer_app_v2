import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/utils/widgets/bottom_variant_selector_with_addons.dart';
import '../../../bloc/user_cart_bloc/user_cart_bloc.dart';
import '../../../bloc/user_cart_bloc/user_cart_event.dart';
import '../../../model/user_cart_model/cart_sync_action.dart';
import '../../../model/user_cart_model/user_cart.dart';
import '../../../utils/widgets/custom_product_card.dart';
import '../../ad_campaign/bloc/ad_click_bloc/ad_click_bloc.dart';
import '../../ad_campaign/widgets/ad_visibility_observer.dart';

class ShoppingListWidget extends StatelessWidget {
  final List<ProductData> product;
  final String title;
  final int totalProducts;
  const ShoppingListWidget({
    super.key,
    required this.product,
    required this.title,
    required this.totalProducts
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // +22.h to leave room for the "Recommended" chip in the card below.
      height: 257.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              'Result for "$title"',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          SizedBox(height: 10.h,),
          SizedBox(
            // +22.h to leave room for the "Recommended" chip in the card.
            height: 222.h,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 12.w),
              itemCount: totalProducts > 30 ? 30 : totalProducts,
              itemBuilder: (context, index) {
                final productData = product[index];
                final defaultVariant = productData.variants.firstWhere(
                      (v) => v.isDefault,
                  orElse: () {
                    if (productData.variants.isNotEmpty) return productData.variants.first;
                    throw Exception('No variants available for product ${productData.id}');
                  },
                );
                final card = CustomProductCard(
                      productId: productData.id,
                      productImage: productData.mainImage,
                      productSlug: productData.slug,
                      productName: productData.title,
                      productPrice: defaultVariant.price.toString(),
                      specialPrice: defaultVariant.specialPrice.toString(),
                      productTags: const [],
                      estimatedDeliveryTime: productData.estimatedDeliveryTime.toString(),
                      assetImage: '',
                      ratings: double.parse(productData.ratings.toString()),
                      ratingCount: productData.ratingCount,
                      onAddToCart: () {
                        if (productData.variants.length > 1 || productData.variants.any((v) => v.addonGroups.isNotEmpty == true)) {
                          showVariantBottomSheetWithAddons(
                            variantsList: productData.variants,
                            productData: productData,
                            productImage: productData.mainImage,
                            quantityStepSize: productData.quantityStepSize,
                            context: context,
                          );
                        } else {
                          final item = UserCart(
                              productId: productData.id.toString(),
                              variantId: defaultVariant.id.toString(),
                              variantName: defaultVariant.title.toString(),
                              vendorId: defaultVariant.storeId.toString(),
                              name: productData.title,
                              image: productData.mainImage,
                              price: defaultVariant.specialPrice.toDouble(),
                              originalPrice: defaultVariant.price.toDouble(),
                              quantity: productData.quantityStepSize,
                              serverCartItemId: null,
                              syncAction: CartSyncAction.add,
                              updatedAt: DateTime.now(),
                              minQty: productData.minimumOrderQuantity,
                              maxQty: productData.totalAllowedQuantity,
                              isOutOfStock: defaultVariant.stock <= 0,
                              isSynced: false
                          );

                          context.read<CartBloc>().add(AddToCart(item: item, context:  context));
                        }
                      },
                      variantCount: productData.variants.length,
                      onVariantSelectorRequested: productData.variants.length > 1
                          ? () => showVariantBottomSheetWithAddons(
                        variantsList: productData.variants,
                        productData: productData,
                        productImage: productData.mainImage,
                        quantityStepSize: productData.quantityStepSize,
                        context: context,
                      )
                          : null,
                      isStoreOpen: true,
                      isWishListed: productData.favorite.isNotEmpty,
                      productVariantId: defaultVariant.id,
                      storeId: defaultVariant.storeId,
                      wishlistItemId: productData.favorite.isNotEmpty ? productData.favorite.first.id ?? 0 : 0,
                      totalStocks: defaultVariant.stock,
                      imageFit: productData.imageFit,
                      quantityStepSize: productData.quantityStepSize,
                      minQty: productData.minimumOrderQuantity,
                      totalAllowedQuantity: productData.totalAllowedQuantity,
                      isSponsored: productData.isSponsored,
                      onCardTap: productData.isSponsored
                          ? () => context.read<AdClickBloc>().add(RecordClick(
                                campaignId: productData.campaignId,
                                visitorKey: productData.visitorKey,
                              ))
                          : null,
                    );

                final Widget cardWidget =
                    productData.isSponsored && productData.campaignId > 0
                        ? AdVisibilityObserver(
                            campaignId: productData.campaignId,
                            visitorKey: productData.visitorKey,
                            child: card,
                          )
                        : card;

                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: SizedBox(
                    width: 140,
                    child: cardWidget,
                  ),
                );
              }
            ),
          )
        ],
      ),
    );
  }
}
