import 'dart:io';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
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
    //

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await FastCachedImageConfig.init();
    if(Platform.isAndroid) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform
      );
    } else {
      await Firebase.initializeApp();
    }

    await Hive.initFlutter();
    Hive.registerAdapter(CartSyncActionAdapter());
    Hive.registerAdapter(CartAddonAdapter());
    Hive.registerAdapter(UserCartAdapter());
    Hive.registerAdapter(RecentProductAdapter());

    await Hive.openBox<UserCart>('cartBox');
    await Hive.openBox('themebox');

    await HiveLocationHelper.init();
    await HiveSelectedAddressHelper.init();
    await ShoppingListHiveHelper.init();

    await Global.initialize();
    await Global.initializePrefs();
    if (kDebugMode) {
      HttpClient.enableTimelineLogging = true;
    }
  }
}
