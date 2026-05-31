import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/utils/widgets/bottom_variant_selector_with_addons.dart';
import '../../../bloc/user_cart_bloc/user_cart_bloc.dart';
import '../../../bloc/user_cart_bloc/user_cart_event.dart';
import '../../../model/user_cart_model/cart_sync_action.dart';
import '../../../model/user_cart_model/user_cart.dart';
import '../../../utils/widgets/custom_product_card.dart';
import '../../ad_campaign/bloc/ad_click_bloc/ad_click_bloc.dart';
import '../../ad_campaign/widgets/ad_visibility_observer.dart';

class SimilarProductWidget extends StatelessWidget {
  final List<ProductData> product;
  const SimilarProductWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    if(product.isEmpty){
      return const SizedBox.shrink();
    } else {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 15, right: 15, ),
                child: Text(
                  AppLocalizations.of(context)!.similarProducts,
                  style: TextStyle(
                    fontSize: isTablet(context) ? 20 : 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                // padding: EdgeInsets.only(left: 15.0, right: 15.0),
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.only(left: 15, right: 15,),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet(context) ? 4 : 3,
                  mainAxisSpacing: 8.0.w,
                  crossAxisSpacing: 8.0.h,
                  // Tightened slightly to leave room for the
                  // "Recommended" chip in the card.
                  childAspectRatio: isTablet(context) ? 0.55 : 0.42,
                ),
                itemCount: product.length > 12 ? 12 : product.length,
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
                    ratings: double.parse(productData.ratings.toString()),
                    ratingCount: productData.ratingCount,
                    isSponsored: productData.isSponsored,
                    onCardTap: productData.isSponsored
                        ? () => context.read<AdClickBloc>().add(RecordClick(
                              campaignId: productData.campaignId,
                              visitorKey: productData.visitorKey,
                            ))
                        : null,
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
                        context.read<CartBloc>().add(AddToCart(item: item, context: context));
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
                    isStoreOpen: productData.storeStatus?.isOpen ?? true,
                    isWishListed: productData.favorite.isNotEmpty,
                    productVariantId: defaultVariant.id,
                    storeId: defaultVariant.storeId,
                    wishlistItemId: productData.favorite.isNotEmpty ? productData.favorite.first.id ?? 0 : 0,
                    totalStocks: defaultVariant.stock,
                    imageFit: productData.imageFit,
                    quantityStepSize: productData.quantityStepSize,
                    minQty: productData.minimumOrderQuantity,
                    totalAllowedQuantity: productData.totalAllowedQuantity,
                    indicator: productData.indicator,
                  );

                  if (productData.isSponsored && productData.campaignId > 0) {
                    return AdVisibilityObserver(
                      campaignId: productData.campaignId,
                      visitorKey: productData.visitorKey,
                      child: card,
                    );
                  }

                  return card;
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}