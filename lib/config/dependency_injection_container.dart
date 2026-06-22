import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aasyou/screens/address_list_page/bloc/check_delivery_zone_bloc/check_delivery_zone_bloc.dart';
import 'package:aasyou/screens/cart_page/bloc/add_to_cart/add_to_cart_bloc.dart';
import 'package:aasyou/screens/cart_page/bloc/attachment/attachment_bloc.dart';
import 'package:aasyou/screens/cart_page/bloc/clear_cart/clear_cart_bloc.dart';
import 'package:aasyou/screens/cart_page/bloc/promo_code/promo_code_bloc.dart';
import 'package:aasyou/screens/cart_page/bloc/remove_item_from_cart/remove_item_from_cart_bloc.dart';
import 'package:aasyou/screens/cart_page/bloc/update_item_quantity/update_item_quantity_bloc.dart';
import 'package:aasyou/screens/cart_page/bloc/validate_promo_code/validate_promo_code_bloc.dart';
import 'package:aasyou/screens/email_verification/bloc/send_email_verification_bloc/send_email_verification_bloc.dart';
import 'package:aasyou/screens/my_orders/bloc/create_order/create_order_bloc.dart';
import 'package:aasyou/screens/my_orders/bloc/delivery_boy_feedback/delivery_boy_feedback_bloc.dart';
import 'package:aasyou/screens/my_orders/bloc/download_invoice/download_invoice_bloc.dart';
import 'package:aasyou/screens/my_orders/bloc/get_my_order/get_my_order_bloc.dart';
import 'package:aasyou/screens/my_orders/bloc/order_detail/order_detail_bloc.dart';
import 'package:aasyou/screens/my_orders/bloc/re_order/re_order_bloc.dart';
import 'package:aasyou/screens/my_orders/bloc/return_order_item/return_order_item_bloc.dart';
import 'package:aasyou/screens/near_by_stores/bloc/near_by_store/near_by_store_bloc.dart';
import 'package:aasyou/screens/near_by_stores/bloc/store_detail/store_detail_bloc.dart';
import 'package:aasyou/screens/payment_options/bloc/payment_bloc.dart';
import 'package:aasyou/screens/product_detail_page/bloc/product_detail_bloc/product_detail_bloc.dart';
import 'package:aasyou/screens/product_detail_page/bloc/product_faq_bloc/product_faq_bloc.dart';
import 'package:aasyou/screens/product_detail_page/bloc/product_feedback/product_feedback_bloc.dart';
import 'package:aasyou/screens/product_detail_page/bloc/product_review_bloc/product_review_bloc.dart';
import 'package:aasyou/screens/product_detail_page/bloc/similar_product_bloc/similar_product_bloc.dart';
import 'package:aasyou/screens/product_listing_page/bloc/filter/filter_bloc.dart';
import 'package:aasyou/screens/product_listing_page/bloc/filter_brands/filter_brands_bloc.dart';
import 'package:aasyou/screens/product_listing_page/bloc/filter_category/filter_category_bloc.dart';
import 'package:aasyou/screens/product_listing_page/bloc/filter_product/filter_product_bloc.dart';
import 'package:aasyou/screens/product_listing_page/bloc/nested_category/nested_category_bloc.dart';
import 'package:aasyou/screens/product_listing_page/bloc/product_listing/product_listing_bloc.dart';
import 'package:aasyou/screens/save_for_later_page/bloc/save_for_later_bloc/save_for_later_bloc.dart';
import 'package:aasyou/screens/seller_page/bloc/seller_feedback/seller_feedback_bloc.dart';
import 'package:aasyou/screens/shopping_list_page/bloc/shopping_list_bloc/shopping_list_bloc.dart';
import 'package:aasyou/screens/wallet_page/bloc/prepare_wallet_recharge/prepare_recharge_bloc.dart';
import 'package:aasyou/screens/wallet_page/bloc/user_wallet/user_wallet_bloc.dart';
import 'package:aasyou/screens/wishlist_page/bloc/wishlist_product_bloc/wishlist_product_bloc.dart';

import '../bloc/cart_state_bloc/cart_state_bloc.dart';
import '../bloc/device_sync_bloc/device_sync_bloc.dart';
import '../bloc/language_bloc/language_bloc.dart';
import '../bloc/settings_bloc/settings_bloc.dart';
import '../bloc/theme_bloc/theme_bloc.dart';
import '../bloc/user_cart_bloc/user_cart_bloc.dart';
import '../bloc/user_details_bloc/user_details_bloc.dart';
import '../model/user_cart_model/user_cart.dart';
import '../screens/ad_campaign/bloc/ad_click_bloc/ad_click_bloc.dart';
import '../screens/ad_campaign/bloc/ad_impression_bloc/ad_impression_bloc.dart';
import '../screens/ad_campaign/repo/ad_campaign_repo.dart';
import '../screens/address_list_page/bloc/get_address_list_bloc/get_address_list_bloc.dart';
import '../screens/auth/bloc/apply_referral/apply_referral_bloc.dart';
import '../screens/auth/bloc/auth/auth_bloc.dart';
import '../screens/auth/bloc/forgot_password/forgot_password_bloc.dart';
import '../screens/auth/bloc/user_verification/user_verification_bloc.dart';
import '../screens/cart_page/bloc/cart_ui_bloc/cart_ui_bloc.dart';
import '../screens/cart_page/bloc/get_user_cart/get_user_cart_bloc.dart';
import '../screens/category_list_page/bloc/all_category_bloc/all_category_bloc.dart';
import '../screens/delivery_zone_list/bloc/delivery_zone/delivery_zone_bloc.dart';
import '../screens/delivery_zone_list/bloc/delivery_zone_detail/delivery_zone_detail_bloc.dart';
import '../screens/home_page/bloc/banner/banner_bloc.dart';
import '../screens/home_page/bloc/brands/brands_bloc.dart';
import '../screens/home_page/bloc/category/category_bloc.dart';
import '../screens/home_page/bloc/feature_section_product/feature_section_product_bloc.dart';
import '../screens/home_page/bloc/market_category/market_category_bloc.dart';
import '../screens/home_page/bloc/sub_category/sub_category_bloc.dart';
import '../screens/my_orders/bloc/delivery_tracking/delivery_tracking_bloc.dart';
import '../screens/near_by_stores/bloc/find_stores/find_stores_bloc.dart';
import '../screens/notification_page/bloc/notification_bloc.dart';
import '../screens/order__transaction/bloc/order_transactions/order_transactions_bloc.dart';
import '../screens/payment_options/repo/payment_repository.dart';
import '../screens/refer_and_earn/bloc/refer_and_earn/refer_and_earn_bloc.dart';
import '../screens/settings/web_settings/bloc/web_settings_bloc.dart';
import '../screens/settings/web_settings/bloc/web_settings_event.dart';
import '../screens/user_profile/bloc/user_profile_bloc/user_profile_bloc.dart';
import '../screens/wallet_page/bloc/wallect_transactions/wallet_transactions_bloc.dart';
import '../screens/wishlist_page/bloc/get_user_wishlist_bloc/get_user_wishlist_bloc.dart';
import '../services/ad_tracking/ad_tracking_service.dart';
import '../services/ad_tracking/api_ad_tracking_service.dart';
import '../services/referral_attribution_service.dart';
import '../services/user_cart/user_cart_local.dart';
import '../services/user_cart/user_cart_remote.dart';
import '../utils/app_update/bloc/app_update_bloc.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // ── Services & Repos ──
  getIt.registerLazySingleton(() => ScrollController());
  getIt.registerLazySingleton(() => AdCampaignRepo());
  getIt.registerLazySingleton<AdTrackingService>(
    () => ApiAdTrackingService(repo: getIt<AdCampaignRepo>()),
  );
  getIt.registerLazySingleton(() => PaymentRepository());
  getIt.registerLazySingleton(() => ReferralAttributionService());

  // ── Core Blocs ──
  getIt.registerLazySingleton(() => UserDataBloc());
  getIt.registerLazySingleton(() => AuthBloc(getIt<UserDataBloc>()));
  getIt.registerLazySingleton(() => CartBloc(
        CartLocalRepository(Hive.box<UserCart>('cartBox')),
        CartRemoteRepository(),
      ));
  getIt.registerLazySingleton(() => ThemeBloc());
  getIt.registerLazySingleton(() => LanguageBloc()..add(const LoadLanguage()));
  getIt.registerLazySingleton(() => SettingsBloc());
  getIt.registerLazySingleton(
      () => WebSettingsBloc()..add(WebSettingsRequested()));
  getIt.registerLazySingleton(() => CartStateBloc());
  getIt.registerLazySingleton(() => DeviceSyncBloc());
  getIt.registerLazySingleton(() => CartUIBloc());
  getIt.registerLazySingleton(
      () => GetUserCartBloc(getIt<CartBloc>())..add(FetchUserCart()));
  getIt.registerLazySingleton(() => UserProfileBloc()..add(FetchUserProfile()));
  getIt.registerLazySingleton(() => GetAddressListBloc());

  // ── Home Blocs ──
  getIt.registerLazySingleton(() => CategoryBloc());
  getIt.registerLazySingleton(() => BannerBloc());
  getIt.registerLazySingleton(() => FeatureSectionProductBloc());
  getIt.registerLazySingleton(() => SubCategoryBloc());
  getIt.registerLazySingleton(() => BrandsBloc());
  getIt.registerLazySingleton(() => AllCategoriesBloc());
  getIt.registerLazySingleton(() => HomeMarketCategoriesBloc());

  // ── Feature Blocs (global scope) ──
  getIt.registerLazySingleton(() => DeliveryZoneBloc());
  getIt.registerLazySingleton(() => DeliveryZoneDetailBloc());
  getIt.registerLazySingleton(() => FindStoresBloc());
  getIt.registerLazySingleton(() => NotificationBloc());
  getIt.registerLazySingleton(() => AppUpdateBloc());
  getIt.registerLazySingleton(() => UserWishlistBloc());
  getIt.registerLazySingleton(
      () => AdImpressionBloc(trackingService: getIt<AdTrackingService>()));
  getIt.registerLazySingleton(
      () => AdClickBloc(trackingService: getIt<AdTrackingService>()));

  getIt.registerFactory(() => FilterCategoryBloc());
  getIt.registerFactory(() => FilterBrandsBloc());
  getIt.registerFactory(() => FilterProductBloc());
  getIt.registerFactory(() => ProductListingBloc());
  getIt.registerFactory(() => CheckDeliveryZoneBloc());
  getIt.registerFactory(() => SimilarProductBloc());
  getIt.registerFactory(() => AddToCartBloc());
  getIt.registerFactory(() => ProductFAQBloc());
  getIt.registerFactory(() => ReOrderBloc());
  getIt.registerFactory(() => GetMyOrderBloc());
  getIt.registerFactory(() => SaveForLaterBloc());
  getIt.registerFactory(() => ShoppingListBloc());
  getIt.registerFactory(() => UserWalletBloc());
  getIt.registerFactory(() => PrepareRechargeBloc());
  getIt.registerFactory(() => SellerFeedbackBloc());
  getIt.registerFactory(() => NearByStoreBloc());
  getIt.registerFactory(() => StoreDetailBloc());
  getIt.registerFactory(() => ProductDetailBloc());
  getIt.registerFactory(() => ProductReviewBloc());
  getIt.registerFactory(() => DeliveryTrackingBloc());
  getIt.registerFactory(() => WalletTransactionsBloc());
  getIt.registerFactory(() => ReferAndEarnBloc());
  getIt.registerFactory(() => OrderTransactionsBloc());

  // ── Wishlist & Category ──
  getIt.registerFactory(() => WishlistProductBloc());
  getIt.registerFactory(() => NestedCategoryBloc());

// ── Cart Operations ──
  getIt.registerFactory(() => RemoveItemFromCartBloc());
  getIt.registerFactory(() => ClearCartBloc());
  getIt.registerFactory(() => UpdateItemQuantityBloc());

// ── Promo & Filters ──
  getIt.registerFactory(() => PromoCodeBloc());
  getIt.registerFactory(() => ValidatePromoCodeBloc());
  getIt.registerFactory(() => FilterBloc());

// ── Attachments & Feedback ──
  getIt.registerFactory(() => AttachmentBloc());
  getIt.registerFactory(() => DeliveryBoyFeedbackBloc());
  getIt.registerFactory(() => ProductFeedbackBloc());

// ── Orders ──
  getIt.registerFactory(() => CreateOrderBloc());
  getIt.registerFactory(() => OrderDetailBloc());
  getIt.registerFactory(() => DownloadInvoiceBloc());
  getIt.registerFactory(() => ReturnOrderItemBloc());
  getIt.registerFactory(() => UserVerificationBloc());

// ── Auth / Verification ──
  getIt.registerFactory(() => SendEmailVerificationBloc());
  getIt.registerFactory(() => ForgotPasswordBloc());
  getIt.registerFactory(() => ApplyReferralBloc());

// ── Payment (with dependency) ──
  getIt.registerFactory(
        () => PaymentBloc(
      paymentRepository: getIt<PaymentRepository>(),
    ),
  );

}
