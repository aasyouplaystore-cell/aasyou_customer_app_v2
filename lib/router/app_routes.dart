import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/global_keys.dart';
import 'package:aasyou/screens/auth/bloc/apply_referral/apply_referral_bloc.dart';
import 'package:aasyou/screens/auth/bloc/auth/auth_bloc.dart';
import 'package:aasyou/screens/auth/bloc/auth/auth_state.dart';
import 'package:aasyou/screens/auth/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:aasyou/screens/auth/view/forgot_password.dart';
import 'package:aasyou/screens/auth/view/login_page.dart';
import 'package:aasyou/screens/auth/view/otp_verification_page.dart';
import 'package:aasyou/screens/auth/view/referral_code_entry_page.dart';
import 'package:aasyou/screens/auth/view/register_page.dart';
import 'package:aasyou/screens/cart_page/view/cart_page.dart';
import 'package:aasyou/screens/cart_page/view/promo_code_page.dart';
import 'package:aasyou/screens/category_list_page/view/category_list_page.dart';
import 'package:aasyou/screens/market_category_detail_page/view/market_category_detail_page.dart';
import 'package:aasyou/screens/market_category_list_page/view/market_category_list_page.dart';
import 'package:aasyou/screens/home_page/view/home_page.dart';
import 'package:aasyou/screens/introduction_pages/view/introduction_page.dart';
import 'package:aasyou/screens/my_orders/view/order_detail_page.dart';
import 'package:aasyou/screens/my_orders/view/rate_your_exp_comments.dart';
import 'package:aasyou/screens/my_orders/view/rate_your_exp_page.dart';
import 'package:aasyou/screens/my_orders/widgets/order_delivered_page.dart';
import 'package:aasyou/screens/near_by_stores/view/nearby_store_details.dart';
import 'package:aasyou/screens/near_by_stores/view/nearyby_stores_page.dart';
import 'package:aasyou/screens/order__transaction/view/order_transaction_page.dart';
import 'package:aasyou/screens/product_detail_page/view/faq_list_page/faq_list_page.dart';
import 'package:aasyou/screens/product_detail_page/view/review_rating_list_page/review_rating_list_page.dart';
import 'package:aasyou/screens/shopping_list_page/view/shopping_list_result_page.dart';
import 'package:aasyou/screens/splash_screen/splash_screen.dart';
import 'package:aasyou/screens/sub_category_page/view/sub_category_page.dart';
import 'package:aasyou/screens/support_page/view/support_page.dart';
import 'package:aasyou/screens/email_verification/view/email_verification_page.dart';
import 'package:aasyou/screens/mobile_verification/view/mobile_verification_page.dart';
import 'package:aasyou/screens/user_profile/view/user_profile_page.dart';
import 'package:aasyou/screens/wallet_page/bloc/wallect_transactions/wallet_transactions_bloc.dart';
import 'package:aasyou/screens/wallet_page/view/transaction_page.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';
import 'package:aasyou/utils/widgets/empty_states_page.dart';
import 'package:aasyou/utils/widgets/no_internet_connection.dart';
import '../config/map_code.dart';
import '../screens/account_page/view/account_page.dart';
import '../screens/auth/view/mobile_otp_login.dart';
import '../screens/brand_list_page/view/brands_list_page.dart';
import '../screens/dashboard/view/dashboard.dart';
import '../screens/delivery_zone_list/view/delivery_zone_detail_page.dart';
import '../screens/delivery_zone_list/view/delivery_zone_listing_page.dart';
import '../screens/my_orders/view/delivery_tracking_page.dart';
import '../screens/my_orders/view/my_orders_page.dart';
import '../screens/my_orders/view/order_success_page.dart';
import '../screens/policies/view/app_policies_page.dart';
import '../screens/product_detail_page/view/product_detail_page.dart';
import '../screens/address_list_page/view/address_list_page.dart';
import '../screens/payment_options/view/payment_options_page.dart';
import '../screens/product_listing_page/model/product_listing_type.dart';
import '../screens/product_listing_page/view/product_listing_page.dart';
import '../screens/refer_and_earn/view/refer_and_earn_page.dart';
import '../screens/save_for_later_page/view/save_for_later_page.dart';
import '../screens/search_page/view/search_page.dart';
import '../screens/shopping_list_page/view/shopping_list_page.dart';
import '../screens/wallet_page/view/add_money_page.dart';
import '../screens/wallet_page/view/wallet_page.dart';
import '../screens/notification_page/view/notification_page.dart';
import '../screens/wishlist_page/view/wishlist_page.dart';
import '../screens/wishlist_page/view/wishlist_product_listing_page.dart';
import '../utils/widgets/page_animation.dart';

Page platformPage(Widget child, {BuildContext? context, GoRouterState? state}) {
  if (Platform.isIOS) {
    // iOS: Keep native Cupertino transition (or wrap with CustomTransitionPage if you want same animation on both platforms)
    return CupertinoPage(child: child);
  } else {
    // Android & others: Use custom animation
    if (context != null && state != null) {
      return buildAnimatedPage(context, state, child);
    }
    return MaterialPage(child: child);
  }
}



class AppRoutes {
  static const String splashScreen = '/';
  static const String introSlider = '/intro-slider';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String home = '/home';
  static const String orderAgain = '/order-again';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String locationPicker = '/location-picker';
  static const String account = '/account';
  static const String productListing = '/product-listing';
  static const String productDetailPage = '/product-detail';
  static const String reviewRatingPage = '/review-rating';
  static const String faqPage = '/faq';
  static const String addressList = '/address-list';
  static const String paymentOptions = '/payment-options';
  static const String orderSuccess = '/order-success';
  static const String userProfile = '/user-profile';
  static const String promoCode = '/promo-code';
  static const String myOrders = '/my-orders';
  static const String orderDetail = '/order-detail';
  static const String shoppingList = '/shopping-list';
  static const String wallet = '/wallet';
  static const String addMoney = '/add-money';
  static const String transactions = '/transactions';
  static const String deliveryTracking = '/delivery-tracking';
  static const String shoppingListResult = '/shopping-list-result';
  static const String wishlistPage = '/wishlist';
  static const String noInternet = '/no-internet';
  static const String search = '/search';
  static const String wishlistProduct = '/wishlist-product';
  static const String saveForLater = '/save-for-later';
  static const String policyPage = '/policy-page';
  static const String supportPage = '/support-page';
  static const String nearbyStores = '/near-by-store';
  static const String nearbyStoreDetails = '/near-by-store-details';
  static const String rateYourExp = '/rate-your-exp';
  static const String rateYourExpComments = '/rate-your-exp-comments';
  static const String forgotPassword = '/forgot-password';
  static const String maintenancePage = '/maintenance-page';
  static const String brandsListPage = '/brands-list-page';
  static const String mobileOtpLoginPage = '/mobile-otp-login-page';
  static const String orderDelivered = '/order-delivered';
  static const String deliveryZoneList = '/delivery-zones';
  static const String deliveryZoneDetail = '/delivery-zone-detail';
  static const String notifications = '/notifications';
  static const String forceUpdateWaitingScreen = '/force-update-waiting-screen';
  static const String referAndEarnPage = '/refer-and-earn-page';
  static const String subCategoryListPage = '/sub-category-list-page';
  static const String marketCategoryListPage = '/market-categories';
  static const String marketCategoryDetailPage = '/market-category-detail';
  static const String orderTransactionsPage = '/order-transaction-page';
  static const String emailVerification = '/email-verification';
  static const String mobileVerification = '/mobile-verification';
  static const String referralCodeEntry = '/referral-code-entry';
}

class MyAppRoute {
  static GoRouter router = GoRouter(
      navigatorKey: GlobalKeys.navigatorKey,
      initialLocation: AppRoutes.splashScreen,
      routes: [
        GoRoute(
          name: '/',
          path: AppRoutes.splashScreen,
          pageBuilder: (context, state) => platformPage(const SplashScreen()),
        ),
        GoRoute(
          name: '/intro-slider',
          path: AppRoutes.introSlider,
          pageBuilder: (context, state) => platformPage(const IntroductionPage()),
        ),
        GoRoute(
          path: '/link',
          name: 'firebase-link',
          redirect: (context, state) {
            final authBloc = BlocProvider.of<AuthBloc>(
                GlobalKeys.navigatorKey.currentContext!);
            final authState = authBloc.state;

            // If we have pending registration data → go to OTP
            if (authState is LoginPhoneCodeSentState) {
              final pendingData = authBloc.getPendingRegistrationData();
              if (pendingData != null) {
                // Don't redirect here — let the pageBuilder push to OTP
                return null; // stay on /link temporarily
              } else {
                // No pending data → redirect to register
                return AppRoutes.register;
              }
            }

            // If auth failed → go to register
            if (authState is AuthFailed) {
              return AppRoutes.register;
            }

            // Otherwise stay on /link to show loading
            return null;
          },
          pageBuilder: (context, state) {
            return platformPage(
              BlocListener<AuthBloc, AuthState>(
                listener: (context, authState) async {
                  if (authState is LoginPhoneCodeSentState) {
                    final bloc = context.read<AuthBloc>();
                    final pendingData = bloc.getPendingRegistrationData();

                    if (pendingData != null && context.mounted) {
                      context.pushReplacement(
                        // ← Use pushReplacement!
                        AppRoutes.otpVerification,
                        extra: {
                          'phoneNumber': bloc.getPendingPhoneNumber(),
                          'registrationData': pendingData,
                          'verificationId': authState.verificationId,
                          'userNumber': bloc.getPendingPhoneNumber(),
                          'countryCode': bloc.getPendingCountryCode(),
                          'isoCode': bloc.getPendingIsoCode(),
                        },
                      );
                    }
                  }
                  if (authState is AuthFailed && context.mounted) {
                    ToastManager.show(
                      context: context,
                      message: authState.error,
                      type: ToastType.error,
                    );

                    // This will now work reliably because redirect handles fallback
                    context.go(AppRoutes.register);
                  }
                },
                child: const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomCircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        GoRoute(
            name: 'otp-verification',
            path: AppRoutes.otpVerification,
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return platformPage(OTPVerificationPage(
                phoneNumber: extra['phoneNumber'] ?? '',
                registrationData: extra['registrationData'] ?? {},
                verificationId: extra['verificationId'] ?? '',
                number: extra['userNumber'] ?? '',
                countryCode: extra['countryCode'] ?? '',
                isoCode: extra['isoCode'] ?? '',
                isLogin: extra['isLogin'] ?? false,
                userName: extra['userName'] ?? '',
                referralCode: extra['referralCode'] ?? '',
                isUpdate: extra['isUpdate'] ?? false,
                popOnSuccess: extra['popOnSuccess'] ?? false,
              ));
            }),
        GoRoute(
          name: 'login',
          path: AppRoutes.login,
          pageBuilder: (context, state) => platformPage(
            const LoginPage(),
            context: context,
            state: state
          ),
        ),
        GoRoute(
          name: 'forgot-password',
          path: AppRoutes.forgotPassword,
          pageBuilder: (context, state) => platformPage(
            BlocProvider(
              create: (_) => ForgotPasswordBloc(),
              child: const ForgotPassword(),
            ),
            context: context,
            state: state
          ),
        ),
        GoRoute(
          name: 'referral-code-entry',
          path: AppRoutes.referralCodeEntry,
          pageBuilder: (context, state) => platformPage(
            BlocProvider(
              create: (_) => ApplyReferralBloc(),
              child: const ReferralCodeEntryPage(),
            ),
            context: context,
            state: state,
          ),
        ),
        GoRoute(
          name: 'no-internet',
          path: AppRoutes.noInternet,
          pageBuilder: (context, state) =>
              platformPage(
                const NoInternetConnection(),
                context: context,
                state: state
              ),
        ),
        GoRoute(
          name: 'register',
          path: AppRoutes.register,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return platformPage(
              RegisterPage(
                userName: extra['name'] ?? '',
                userEmail: extra['email'] ?? '',
              ),
            );
          },
        ),

        StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return Dashboard(
                index: navigationShell.currentIndex,
                navigationShell: navigationShell,
              );
            },
            branches: [
              StatefulShellBranch(routes: [
                GoRoute(
                  name: 'home',
                  path: AppRoutes.home,
                  pageBuilder: (context, state) => platformPage(
                    const HomePage(),
                  ),
                ),
              ]),
              // Bottom-nav slot #2: "Markets" — was the dedicated Categories
              // list page; per UX update Categories has been moved into the
              // Account section, and this slot now opens the Market
              // Categories list (one tap closer to the marketplace concept).
              StatefulShellBranch(routes: [
                GoRoute(
                  name: 'market-category-list-page-shell',
                  path: AppRoutes.marketCategoryListPage,
                  pageBuilder: (context, state) => platformPage(
                    const MarketCategoryListPage(),
                  ),
                ),
              ]),

              StatefulShellBranch(routes: [
                GoRoute(
                  name: 'near-by-store',
                  path: AppRoutes.nearbyStores,
                  pageBuilder: (context, state) =>
                      platformPage(
                          const NearbyStoresPage(),
                          context: context,
                          state: state
                      ),
                ),
              ]),

              StatefulShellBranch(routes: [
                GoRoute(
                  name: 'account',
                  path: AppRoutes.account,
                  pageBuilder: (context, state) => platformPage(
                      const AccountPage(),
                      context: context,
                      state: state
                  ),
                ),
              ]),

              // if(AppHelpers.systemVendorTypeIsSingle == true)
              StatefulShellBranch(routes: [
                GoRoute(
                  name: 'my-orders',
                  path: AppRoutes.myOrders,
                  pageBuilder: (context, state) => platformPage(
                      const MyOrdersPage(),
                      context: context,
                      state: state
                  ),
                ),
              ])
            ]),

        GoRoute(
          name: 'cart',
          path: AppRoutes.cart,
          pageBuilder: (context, state) => platformPage(
              const CartPage(),
              context: context,
              state: state
          ),
        ),
        GoRoute(
          name: 'location-picker',
          path: AppRoutes.locationPicker,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            return LocationPickerWidget(
              initialLatitude: args?['lat'],
              initialLongitude: args?['lng'],
              initialAddress: args?['address'],
              isFromAddressPage: args?['isFromAddressPage'],
              isEdit: args?['isEdit'],
              addressId: args?['addressId'],
              addressType: args?['addressType'],
              isFromCartPage: args?['isFromCartPage'],
              deliveryZoneId: args?['deliveryZoneId'],
            );
          },
        ),
        GoRoute(
          name: 'product-listing',
          path: AppRoutes.productListing,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final isTheirMoreCategory = extra['isTheirMoreCategory'] as bool? ??
                false; // Default to false if null
            final dynamic rawType = extra['type'];
            final ProductListingType listingType = rawType is ProductListingType
                ? rawType
                : rawType is String
                ? ProductListingType.values.firstWhere(
                  (e) => e.name == rawType,
              orElse: () => ProductListingType.category,
            )
                : ProductListingType.category;
            final String identifier = (extra['identifier']?.toString() ??
                extra['categorySlug']?.toString() ??
                state.uri.queryParameters['identifier'] ??
                state.uri.queryParameters['category-slug'] ??
                '');
            return platformPage(
              ProductListingPage(
                key: ValueKey('product-listing-$identifier-${state.pageKey}'),
                isTheirMoreCategory: isTheirMoreCategory,
                title: extra['title']?.toString() ?? '',
                logo: extra['logo']?.toString() ?? '',
                totalProduct: extra['totalProduct']?.toString() ?? '',
                type: listingType,
                identifier: identifier,
              ),
            );
          },
        ),
        GoRoute(
            name: 'product-detail',
            path: AppRoutes.productDetailPage,
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              final productSlug = extra['productSlug']?.toString() ??
                  state.uri.queryParameters['productSlug'] ?? '';
              final title = extra['title']?.toString() ?? '';
              final mainImage = extra['mainImage']?.toString() ?? '';

              return platformPage(
                ProductDetailPage(
                  key: ValueKey('product-detail-$productSlug'),
                  productSlug: productSlug,
                  initialData:
                  ProductInitialData(title: title, mainImage: mainImage),
                ),

              );
            }),
        GoRoute(
            name: 'review-rating',
            path: AppRoutes.reviewRatingPage,
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, String>;
              return platformPage(
                  ReviewRatingListPage(
                    productSlug: extra['productSlug']!,
                  ),
                  context: context,
                  state: state
              );
            }),
        GoRoute(
            name: 'faq',
            path: AppRoutes.faqPage,
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, String>;
              return platformPage(
                  FaqListPage(
                    productSlug: extra['productSlug']!,
                  ),
                  context: context,
                  state: state
              );
            }),
        GoRoute(
          name: 'address-list',
          path: AppRoutes.addressList,
          pageBuilder: (context, state) => platformPage(
              const AddressListPage(),
              context: context,
              state: state
          ),
        ),
        GoRoute(
          name: 'payment-options',
          path: AppRoutes.paymentOptions,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return platformPage(
                PaymentOptionsPage(
                  totalAmount: extra['totalAmount']?.toDouble() ?? 0.0,
                  isFromAddMoney: extra['isFromAddMoney'] as bool? ?? false,
                ),
                context: context,
                state: state
            );
          },
        ),
        GoRoute(
            name: 'order-success',
            path: AppRoutes.orderSuccess,
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return platformPage(
                  OrderSuccessPage(
                    address: extra['address'].toString(),
                    addressType: extra['addressType'].toString(),
                    orderSlug: extra['orderSlug'].toString(),
                  ),
                  context: context,
                  state: state
              );
            }),
        GoRoute(
          name: 'user-profile',
          path: AppRoutes.userProfile,
          pageBuilder: (context, state) => platformPage(
              const UserProfilePage(),
              context: context,
              state: state
          ),
        ),
        GoRoute(
          name: 'email-verification',
          path: AppRoutes.emailVerification,
          pageBuilder: (context, state) => platformPage(
            const EmailVerificationPage(),
            context: context,
            state: state,
          ),
        ),
        GoRoute(
          name: 'mobile-verification',
          path: AppRoutes.mobileVerification,
          pageBuilder: (context, state) => platformPage(
            const MobileVerificationPage(),
            context: context,
            state: state,
          ),
        ),
        GoRoute(
          name: 'promo-code',
          path: AppRoutes.promoCode,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return platformPage(
                PromoCodePage(
                  cartAmount: extra['cartAmount']?.toDouble(),
                  deliveryCharges: extra['deliveryCharges']?.toDouble(),
                ),
                context: context,
                state: state
            );
          },
        ),
        GoRoute(
          name: 'order-detail',
          path: AppRoutes.orderDetail,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final orderSlug = extra['order-slug'] ??
                state.uri.queryParameters['order-slug'];
            return platformPage(
                OrderDetailPage(
                  orderSlug: orderSlug,
                ),
                context: context,
                state: state
            );
          },
        ),
        GoRoute(
          name: 'shopping-list',
          path: AppRoutes.shoppingList,
          pageBuilder: (context, state) => platformPage(
              const ShoppingListPage(),
              context: context,
              state: state
          ),
        ),
        GoRoute(
          name: 'wallet',
          path: AppRoutes.wallet,
          pageBuilder: (context, state) => platformPage(
              const WalletPage(),
              context: context,
              state: state
          ),
        ),
        GoRoute(
          name: 'add-money',
          path: AppRoutes.addMoney,
          pageBuilder: (context, state) => platformPage(
              const AddMoneyPage(),
              context: context,
              state: state
          ),
        ),
        GoRoute(
          name: 'transactions',
          path: AppRoutes.transactions,
          pageBuilder: (context, state) => platformPage(
              BlocProvider(
                create: (_) => WalletTransactionsBloc(),
                child: const TransactionPage(),
              ),
              context: context,
              state: state
          ),
        ),
        GoRoute(
          name: 'delivery-tracking',
          path: AppRoutes.deliveryTracking,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return platformPage(
                DeliveryTrackingPage(
                  orderSlug: extra['order-slug'],
                ),
                context: context,
                state: state
            );
          },
        ),
        GoRoute(
          name: 'shopping-list-result',
          path: AppRoutes.shoppingListResult,
          pageBuilder: (context, state) =>
              platformPage(
                  const ShoppingListResultPage(),
                  context: context,
                  state: state
              ),
        ),
        GoRoute(
          name: 'wishlist',
          path: AppRoutes.wishlistPage,
          pageBuilder: (context, state) => platformPage(
              const WishlistPage(),
              context: context,
              state: state
          ),
        ),
        GoRoute(
          name: 'search',
          path: AppRoutes.search,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final startVoice = extra['startVoice'] as bool? ?? false;
            return platformPage(
                SearchPage(startVoice: startVoice),
                context: context,
                state: state
            );
          },
        ),
        GoRoute(
          name: 'wishlist-product',
          path: AppRoutes.wishlistProduct,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final wishlistId = extra['wishlist-id'] ??
                state.uri.queryParameters['wishlist-id'];
            return platformPage(
                WishlistProductListingPage(
                  wishlistId: wishlistId,
                ),
                context: context,
                state: state
            );
          },
        ),
        GoRoute(
          name: 'save-for-later',
          path: AppRoutes.saveForLater,
          pageBuilder: (context, state) => platformPage(
              const SaveForLaterPage(),
              context: context,
              state: state
          ),
        ),
        GoRoute(
            name: 'policy-page',
            path: AppRoutes.policyPage,
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return platformPage(PolicyPage(
                policyType: extra['policy-type'] ?? PolicyType.aboutUs,
              ),
                  context: context,
                  state: state
              );
            }),
        GoRoute(
          name: 'support-page',
          path: AppRoutes.supportPage,
          pageBuilder: (context, state) => platformPage(
              const SupportPage(),
              context: context,
              state: state
          ),
        ),
        GoRoute(
          name: 'near-by-store-details',
          path: AppRoutes.nearbyStoreDetails,
          pageBuilder: (context, state) {
            final map = state.extra as Map<String, dynamic>? ?? {};
            final storeSlug = map['store-slug'] ??
                state.uri.queryParameters['store-slug'] ?? '';
            final storeName = map['store-name'] ?? '';
            return platformPage(
                NearbyStoreDetails(
                  storeSlug: storeSlug,
                  storeName: storeName,
                ),
                context: context,
                state: state
            );
          },
        ),
        GoRoute(
          name: 'rate-your-exp',
          path: AppRoutes.rateYourExp,
          pageBuilder: (context, state) {
            final map = state.extra as Map<String, dynamic>;
            final orderSlug = map["orderSlug"];
            final orderId = map["orderId"];
            return platformPage(
                RateYourExpPage(
                  orderSlug: orderSlug,
                  orderId: orderId,
                ),
                context: context,
                state: state
            );
          },
        ),
        GoRoute(
          name: 'rate-your-exp-comments',
          path: AppRoutes.rateYourExpComments,
          pageBuilder: (context, state) {
            final map = state.extra as Map<String, dynamic>;
            final orderSlug = map["orderSlug"];
            final items = map["items"];
            return platformPage(
                RateYourExpComments(orderSlug: orderSlug, items: items),
                context: context,
                state: state
            );
          },
        ),
        GoRoute(
          name: 'maintenance-page',
          path: AppRoutes.maintenancePage,
          pageBuilder: (context, state) {
            final map = state.extra as Map<String, dynamic>;
            final message = map["message"];
            return platformPage(
                MaintenancePage(description: message),
                context: context,
                state: state
            );
          },
        ),
        GoRoute(
          name: 'brands-list-page',
          path: AppRoutes.brandsListPage,
          pageBuilder: (context, state) {
            final map = state.extra as Map<String, dynamic>;
            final categorySlug = map["category-slug"];
            return platformPage(
                BrandsListPage(categorySlug: categorySlug),
                context: context,
                state: state
            );
          },
        ),
        GoRoute(
          name: 'mobile-otp-login-page',
          path: AppRoutes.mobileOtpLoginPage,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return platformPage(
                MobileOtpLoginPage(
                  isDirectLogin: extra['isDirectLogin'],
                  isUpdate: extra['isUpdate'] ?? false,
                ),
                context: context,
                state: state
            );
          } ,
        ),
        GoRoute(
            name: 'order-delivered',
            path: AppRoutes.orderDelivered,
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return platformPage(
                  OrderDeliveredPage(
                    address: extra['address'].toString(),
                    addressType: extra['addressType'].toString(),
                    orderSlug: extra['orderSlug'].toString(),
                  ),
                  context: context,
                  state: state
              );
            }),
        GoRoute(
          name: 'delivery-zone',
          path: AppRoutes.deliveryZoneList,
          pageBuilder: (context, state) => platformPage(
              const DeliveryZoneListingPage(),
              context: context,
              state: state
          ),
        ),
        GoRoute(
          name: 'delivery-zone-detail',
          path: AppRoutes.deliveryZoneDetail,
          pageBuilder: (context, state) {
            final map = state.extra as Map<String, dynamic>? ?? {};
            final zoneId = map["zoneId"] ??
                int.tryParse(state.uri.queryParameters['zoneId'] ?? '');
            return platformPage(
                DeliveryZoneDetailPage(
                  zoneId: zoneId,
                ),
                context: context,
                state: state
            );
          },
        ),
        GoRoute(
          name: 'notifications',
          path: AppRoutes.notifications,
          pageBuilder: (context, state) =>
              platformPage(
                  const NotificationPage(),
                  context: context,
                  state: state
              ),
        ),
        GoRoute(
          name: 'refer-and-earn-page',
          path: AppRoutes.referAndEarnPage,
          pageBuilder: (context, state) {
            return platformPage(
                const ReferAndEarnPage(),
                context: context,
                state: state
            );
          },
        ),
        GoRoute(
          name: 'sub-category-list-page',
          path: AppRoutes.subCategoryListPage,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return platformPage(
                SubCategoryListPage(
                  slug: extra['slug'] ?? '',
                  isForAllCategory: extra['isForAllCategory'] as bool?,
                ),
                context: context,
                state: state
            );
          },
        ),
        // Top-level Categories route — pushable from the Account page after
        // Categories was removed from the bottom nav.
        GoRoute(
          name: 'category-list-page',
          path: AppRoutes.categories,
          pageBuilder: (context, state) => platformPage(
            const CategoryListPage(),
            context: context,
            state: state,
          ),
        ),
        GoRoute(
          name: 'market-category-detail-page',
          path: AppRoutes.marketCategoryDetailPage,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return platformPage(
                MarketCategoryDetailPage(
                  slug: (extra['slug'] as String?) ?? '',
                ),
                context: context,
                state: state,
            );
          },
        ),
        GoRoute(
          name: 'order-transactions-page',
          path: AppRoutes.orderTransactionsPage,
          pageBuilder: (context, state) {
            return platformPage(
                const OrderTransactionPage(),
                context: context,
                state: state
            );
          },
        ),

      ]);
}
