import 'dart:io';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aasyou/config/global.dart';
import 'package:aasyou/firebase_options.dart';
import 'package:aasyou/model/recent_product_model/recent_product_model.dart';
import 'package:aasyou/model/user_cart_model/cart_addon.dart';
import 'package:aasyou/model/user_cart_model/cart_sync_action.dart';
import 'package:aasyou/model/user_cart_model/user_cart.dart';
import 'package:aasyou/services/address/selected_address_hive.dart';
import 'package:aasyou/services/location/user_location_hive.dart';
import 'package:aasyou/services/shopping_list_hive.dart';


class AppBootstrap {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // PERF Phase 1: the old bootstrap awaited ~10 inits SEQUENTIALLY, so the
    // first frame waited for the SUM of them. Firebase, the Hive chain, the
    // image-cache init and the orientation call are mutually independent —
    // run them in parallel; first frame now waits only for the SLOWEST one.
    await Future.wait([
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]),
      FastCachedImageConfig.init(),
      _initFirebase(),
      _initHive(),
    ]);

    // Crashlytics wiring needs Firebase.initializeApp done — hence after the
    // wait. Fatal Flutter errors + uncaught platform errors both reported.
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    if (kDebugMode) {
      HttpClient.enableTimelineLogging = true;
    }
  }

  static Future<void> _initFirebase() async {
    if (Platform.isAndroid) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp();
    }
  }

  /// Hive has its own internal order (initFlutter -> adapters -> boxes), but
  /// the box opens are independent FILES — open them all in parallel too.
  static Future<void> _initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CartSyncActionAdapter());
    Hive.registerAdapter(CartAddonAdapter());
    Hive.registerAdapter(UserCartAdapter());
    Hive.registerAdapter(RecentProductAdapter());

    await Future.wait([
      Hive.openBox<UserCart>('cartBox'),
      Hive.openBox('themebox'),
      HiveLocationHelper.init(),
      HiveSelectedAddressHelper.init(),
      ShoppingListHiveHelper.init(),
      // Global.initialize registers its own adapter before opening its box —
      // safe alongside the others (different typeId, different box files).
      Global.initialize(),
      Global.initializePrefs(),
    ]);
  }
}
