import 'dart:core';

import 'package:aasyou/config/constant.dart';

class ApiRoutes {
  static String loginApi = '${AppConstant.baseUrl}login';
  static String registerApi = '${AppConstant.baseUrl}register';
  static String verifyUserApi = '${AppConstant.baseUrl}verify-user';
  static String forgotPasswordApi = '${AppConstant.baseUrl}forget-password';
  static String googleAuthApi = '${AppConstant.baseUrl}auth/google/callback';
  static String appleAuthApi = '${AppConstant.baseUrl}auth/apple/callback';
  static String mobileOtpAuthApi = '${AppConstant.baseUrl}auth/phone/callback';
  static String truecallerAuthApi = '${AppConstant.baseUrl}auth/truecaller/callback';
  static String logoutApi = '${AppConstant.baseUrl}logout';
  static String categoryApi = '${AppConstant.baseUrl}categories';
  static String filterCategoryApi = '${AppConstant.baseUrl}categories/sidebar';
  static String marketCategoryApi = '${AppConstant.baseUrl}market-categories';
  static String marketCategorySidebarApi =
      '${AppConstant.baseUrl}market-categories/sidebar';
  static String marketCategorySubCategoriesApi =
      '${AppConstant.baseUrl}market-categories/sub-categories';
  static String marketCategorySearchApi =
      '${AppConstant.baseUrl}market-categories/search';
  static String filterProductApi =
      '${AppConstant.baseUrl}products/sidebar-filters';
  static String bannerApi = '${AppConstant.baseUrl}banners';
  static String featureSectionProductApi =
      '${AppConstant.baseUrl}featured-sections';
  static String subCategoryApi = '${AppConstant.baseUrl}categories';
  static String allTabSubCategoryApi =
      '${AppConstant.baseUrl}categories/sub-categories';
  static String productDetailApi = '${AppConstant.baseUrl}products/';
  static String brandsApi = '${AppConstant.baseUrl}brands';
  static String filterBrandsApi = '${AppConstant.baseUrl}brands/sidebar';
  static String addToCartApi = '${AppConstant.baseUrl}user/cart/add';
  static String categoryProductApi =
      '${AppConstant.baseUrl}delivery-zone/products';
  static String storeProductApi =
      '${AppConstant.baseUrl}delivery-zone/products';
  static String getCartApi = '${AppConstant.baseUrl}user/cart';
  static String removeItemFromCartApi = '${AppConstant.baseUrl}user/cart/item/';
  static String clearCartApi = '${AppConstant.baseUrl}user/cart/clear-cart';
  static String getSimilarProductApi =
      '${AppConstant.baseUrl}delivery-zone/products';
  static String addAddressApi = '${AppConstant.baseUrl}user/addresses';
  static String getAddressesApi = '${AppConstant.baseUrl}user/addresses';
  static String removeAddressesApi = '${AppConstant.baseUrl}user/addresses/';
  static String updateAddressesApi = '${AppConstant.baseUrl}user/addresses/';
  static String checkDeliveryZoneApi =
      '${AppConstant.baseUrl}delivery-zone/check';
  static String settingsApi = '${AppConstant.baseUrl}settings';
  static String createOrderApi = '${AppConstant.baseUrl}user/orders';
  static String getMyOrderApi = '${AppConstant.baseUrl}user/orders';
  static String getUserProfileApi = '${AppConstant.baseUrl}user/profile';
  static String updateUserProfileApi = '${AppConstant.baseUrl}user/profile';
  static String deleteUserApi = '${AppConstant.baseUrl}user/delete-account';
  static String getPromoCodeApi = '${AppConstant.baseUrl}user/promos/available';
  static String validatePromoCodeApi =
      '${AppConstant.baseUrl}user/promos/validate';
  static String orderDetailApi = '${AppConstant.baseUrl}user/orders/';
  static String addDeliveryBoyFeedbackApi =
      '${AppConstant.baseUrl}delivery-boy/feedback';
  static String updateDeliveryBoyFeedbackApi =
      '${AppConstant.baseUrl}delivery-boy/feedback/';
  static String deleteDeliveryBoyFeedbackApi =
      '${AppConstant.baseUrl}delivery-boy/feedback/';
  static String razorpayApi = '${AppConstant.baseUrl}razorpay/create-order';
  static String stripeCreatePaymentIntentApi =
      '${AppConstant.baseUrl}stripe/create-order';
  static String paystackCreateOrderApi =
      '${AppConstant.baseUrl}paystack/create-order';
  static String prepareWalletRechargeApi =
      '${AppConstant.baseUrl}user/wallet/prepare-wallet-recharge';
  static String userWalletApi = '${AppConstant.baseUrl}user/wallet';
  static String walletTransactionsApi =
      '${AppConstant.baseUrl}user/wallet/transactions';
  static String addProductFeedbackApi = '${AppConstant.baseUrl}reviews';
  static String updateProductFeedbackApi = '${AppConstant.baseUrl}reviews/';
  static String deleteProductFeedbackApi = '${AppConstant.baseUrl}reviews/';
  static String addSellerFeedbackApi = '${AppConstant.baseUrl}seller-feedback';
  static String updateSellerFeedbackApi =
      '${AppConstant.baseUrl}seller-feedback/';
  static String deleteSellerFeedbackApi =
      '${AppConstant.baseUrl}seller-feedback/';
  static String shoppingListApi =
      '${AppConstant.baseUrl}products/search-by-keywords';
  static String getWishlistApi = '${AppConstant.baseUrl}user/wishlists';
  static String createWishlistApi =
      '${AppConstant.baseUrl}user/wishlists/create';
  static String addItemInWishlistApi = '${AppConstant.baseUrl}user/wishlists';
  static String updateWishlistApi = '${AppConstant.baseUrl}user/wishlists/';
  static String deleteWishlistApi = '${AppConstant.baseUrl}user/wishlists/';
  static String removeItemFromWishlistApi =
      '${AppConstant.baseUrl}user/wishlists/items/';
  static String moveItemToAnotherWishlistApi =
      '${AppConstant.baseUrl}user/wishlists/items/';
  static String searchApi = '${AppConstant.baseUrl}delivery-zone/products';
  static String wishlistProductApi = '${AppConstant.baseUrl}user/wishlists/';
  static String saveForLaterApi =
      '${AppConstant.baseUrl}user/cart/item/save-for-later';
  static String saveProductApi =
      '${AppConstant.baseUrl}user/cart/item/save-for-later/';
  static String specificFeatureSectionProductApi =
      '${AppConstant.baseUrl}featured-sections/';
  static String nearByStores = '${AppConstant.baseUrl}delivery-zone/stores';
  static String returnOrderItemApi = '${AppConstant.baseUrl}user/orders/items/';
  static String cancelReturnRequestApi =
      '${AppConstant.baseUrl}user/orders/items/';
  static String cancelOrderItemApi = '${AppConstant.baseUrl}user/orders/items/';
  static String storeDetailApi = '${AppConstant.baseUrl}stores/';
  static String flutterwaveApi =
      '${AppConstant.baseUrl}flutterwave/create-order';
  static String cartSyncApi = '${AppConstant.baseUrl}user/cart/sync';
  static String deliveryZonesApi = '${AppConstant.baseUrl}delivery-zone';
  static String deliveryZoneDetailApi = '${AppConstant.baseUrl}delivery-zone/';
  static String findStoresApi = '${AppConstant.baseUrl}stores/map';
  static String notificationsApi = '${AppConstant.baseUrl}user/notifications';
  static String markNotificationAsReadApi(String id) =>
      '${AppConstant.baseUrl}user/notifications/$id/read';
  static String markAllNotificationsAsReadApi =
      '${AppConstant.baseUrl}user/notifications/mark-all-read';
  static String reOrderApi = '${AppConstant.baseUrl}user/orders/';
  static String sendCustomOtpApi = '${AppConstant.baseUrl}auth/send-otp';
  static String verifyCustomOtpApi = '${AppConstant.baseUrl}auth/verify-otp';
  static String versionCheckApi = '${AppConstant.baseUrl}settings/check-version';
  static String getReferInfoApi = '${AppConstant.baseUrl}user/referral';
  static String orderTransactionsApi =
      '${AppConstant.baseUrl}user/order-transactions';
  static String sendEmailVerificationLinkApi =
      '${AppConstant.baseUrl}user/update-email';
  static String resendEmailVerificationLinkApi =
      '${AppConstant.baseUrl}user/email/verification-notification';
  static String adBulkImpressionsApi =
      '${AppConstant.baseUrl}ads/bulk-impressions';
  static String adBulkClicksApi = '${AppConstant.baseUrl}ads/bulk-clicks';
  static String syncDeviceApi = '${AppConstant.baseUrl}devices/sync';
  static String applyReferralApi = '${AppConstant.baseUrl}user/referral/submit';

  // Shop-Follow endpoints (sanctum-protected).
  //  - POST/DELETE /api/stores/{id}/follow  → toggle follow for current user
  //  - GET         /api/user/followed-stores → list current user's follows
  static String followStoreApi(int storeId) =>
      '${AppConstant.baseUrl}stores/$storeId/follow';
  static String followedStoresApi =
      '${AppConstant.baseUrl}user/followed-stores';
}
