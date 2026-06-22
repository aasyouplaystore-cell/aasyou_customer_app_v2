import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:http/http.dart' as http;
import 'package:aasyou/config/settings_data_instance.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/cart_page/bloc/get_user_cart/get_user_cart_bloc.dart';
import '../screens/my_orders/model/order_detail_model.dart';
import 'api_base_helper.dart';

class AppHelpers {
  static String localUserLocationHiveBoxName = 'userLocationBox';
  static String localUserLocationHiveBoxKey = 'user_location';
  static String selectedAddressHiveBoxName = 'selectedAddressBox';
  static String selectedAddressHiveBoxKey = 'selected_address';
  static String userHiveBoxName = 'UserDataBox';
  static ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  static String systemVersion = '2.0.0';
  static double bottomNavBarHeight = Platform.isAndroid ? 68.h : 75.h;

  static String notificationSound = 'notification_sound';
  static bool get systemVendorTypeIsSingle => SettingsData.instance.system?.systemVendorType == 'single';
  static bool get smsGatewayIsFirebase => SettingsData.instance.authentication?.smsGateway == 'firebase';
  static int get unreadNotificationCount => SettingsData.instance.notification?.notificationUnreadCount ?? 0;
  static String get countryCode => 'IN';
  static bool get countryValidationEnable => SettingsData.instance.web?.enableCountryValidation ?? false;
  static List<String> get allowedCountries => SettingsData.instance.web?.allowedCountries ?? ['IN'];

  static bool get isDemo => SettingsData.instance.system?.demoMode ?? false;
  static String get demoModeMessage => SettingsData.instance.system?.customerDemoModeMessage ?? 'This is operation is allowed in Demo Mode.';
  static String get demoModeLocationMessage => SettingsData.instance.system?.customerLocationDemoModeMessage ?? 'Demo mode is enabled. Location will default automatically.';

  static String get defaultLat {
    final lat = SettingsData.instance.web?.defaultLatitude;
    if (lat == null || lat.isEmpty) return '23.2420';
    return lat.toString();
  }

  static String get defaultLng {
    final lng = SettingsData.instance.web?.defaultLongitude;
    if (lng == null || lng.isEmpty) return '69.6669';
    return lng.toString();
  }

  static String get currency => SettingsData.instance.system?.currencySymbol ?? '₹';

  static IconData wishListedIcon = TablerIcons.bookmark_filled;
  static IconData notWishListedIcon = TablerIcons.bookmark;
  static String authMessage = 'Please log in to continue. This helps us save your preferences and keep your shopping journey seamless.';

  static String defaultLocalCurrency = 'en_In';

  static Map<String, dynamic> defaultFullAddress = {
    "address_line1": "Bhuj",
    "address_line2": "",
    "city": "Bhuj",
    "landmark": "Hospital road",
    "state": "Gujarat",
    "zipcode": "370001",
    "mobile": "9000000000",
    "address_type": "home",
    "country": "India",
    "country_code": "IN",
    "latitude": 23.2420,
    "longitude": 69.6669
  };

}

class MediaQueryHelper {
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
}

bool isTablet(BuildContext context) {
  final shortestSide = MediaQuery.of(context).size.shortestSide;
  return shortestSide >= 600;
}

bool isCartItemReachedMaxLimit(BuildContext context) {
  final int totalCartItems = context.read<GetUserCartBloc>().totalCartItems;
  final maxCartItemLimit = SettingsData.instance.system?.maximumItemsAllowedInCart ?? 0;
  final bool isCartItemReachedMax = totalCartItems >= maxCartItemLimit;
  return isCartItemReachedMax;
}

double getMaxCrossAxisExtent(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth > 500) {
    return 200.w; // Large screens (e.g., desktops)
  } else if (screenWidth > 300) {
    return 150.w; // Tablets
  } else {
    return 120.w; // Phones
  }
}

String formatIsoDateToCustomFormat(String isoDate) {
  DateTime dateTime = DateTime.parse(isoDate);
  final formatter = DateFormat('dd MMM yyyy', 'en_US');
  return formatter.format(dateTime);
}

String capitalizeFirstLetter(String s) {
  if (s.isEmpty) return s; // Handle empty string

  int firstLetterIndex = 0;
  while (firstLetterIndex < s.length && !RegExp(r'[a-zA-Z]').hasMatch(s[firstLetterIndex])) {
    firstLetterIndex++;
  }

  if (firstLetterIndex >= s.length) return s;

  return s.substring(0, firstLetterIndex) +
      s[firstLetterIndex].toUpperCase() +
      s.substring(firstLetterIndex + 1);
}

String formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return 'N/A';

  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  final day = dateTime.day;
  final month = months[dateTime.month - 1];
  final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'pm' : 'am';

  return '$day $month, $hour:$minute $period';
}

String normalize(String input) {
  return input
      .trim()
      .replaceAll(RegExp(r'\s+'), '')
      .toLowerCase();
}

String formatPrice(num value, {String locale = 'en_IN'}) {
  final formatter = NumberFormat.decimalPattern(locale);
  return formatter.format(value);
}

List<String> removeUnderscoresFromStringList(List<String> labels) {
  return labels.map((label) => label.replaceAll('_', ' ')).toList();
}

String removeUnderscores(String label) {
  return label.replaceAll('_', ' ').trim();
}

// 1) Add a hex parser (utility or extension)
Color? hexStringToColor(String? hex) {
  if (hex == null) return null;
  var value = hex.trim();
  if (value.isEmpty) return null;

  // Remove leading '#'
  if (value.startsWith('#')) value = value.substring(1);

  // Support shorthand 3/4-digit? If needed, expand here; otherwise only 6/8.
  if (value.length == 6) {
    // RRGGBB -> AARRGGBB with alpha FF
    value = 'FF$value';
  } else if (value.length == 8) {
    // already AARRGGBB
  } else {
    return null; // invalid length
  }

  try {
    final intColor = int.parse(value, radix: 16);
    return Color(intColor);
  } catch (_) {
    return null;
  }
}

Future<FormData> formDataWithImages({
  required Map<String, dynamic> fields,
  required List<XFile> images,
  required String imageFieldLabel,
}) async {
  final data = FormData.fromMap(fields);
  for (int i = 0; i < images.length; i++) {
    final xfile = images[i];

    // This is the MOST important part
    final multipartFile = await MultipartFile.fromFile(
      xfile.path,
      filename: xfile.name.isNotEmpty ? xfile.name : 'image_$i.jpg',
    );

    // Correct key: 'images[]' → tells PHP/Laravel to treat as array
    data.files.add(MapEntry('$imageFieldLabel[]', multipartFile));
  }
  return data;
}

class ItemStatus {
  final String? message;
  final Color color;
  final IconData icon;

  ItemStatus({this.message, required this.color, required this.icon});
}

ItemStatus getItemStatus(OrderItems item) {
  // No return → no banner needed (pill handles item-level status)
  if (item.returns.isEmpty) {
    return ItemStatus(color: Colors.transparent, icon: Icons.info);
  }

  final returnData = item.returns.first;
  final returnStatus = returnData.returnStatus;
  final pickupStatus = returnData.pickupStatus ?? 'pending';
  final refundAmount = returnData.refundAmount ?? 0;

  switch (returnStatus) {
    case 'requested':
      return ItemStatus(
        message: 'Return request submitted successfully',
        color: Colors.orange.shade700,
        icon: Icons.access_time,
      );

    case 'seller_approved':
      switch (pickupStatus) {
        case 'scheduled':
          return ItemStatus(
            message: 'Pickup scheduled! Delivery partner will contact you soon',
            color: Colors.blue.shade600,
            icon: Icons.schedule,
          );
        case 'in_transit':
          return ItemStatus(
            message: 'Delivery partner is on the way to collect your return',
            color: Colors.blue.shade700,
            icon: Icons.local_shipping_outlined,
          );
        case 'picked_up':
          return ItemStatus(
            message: 'Return picked up successfully',
            color: AppTheme.successColor,
            icon: Icons.check_circle_outline,
          );
        case 'failed':
          return ItemStatus(
            message: 'Pickup failed. Will be rescheduled soon',
            color: AppTheme.errorColor,
            icon: Icons.error_outline,
          );
        default: // pending
          return ItemStatus(
            message: 'Return approved! Waiting for pickup to be scheduled',
            color: Colors.orange.shade700,
            icon: Icons.pending_actions,
          );
      }

    case 'picked_up':
      return ItemStatus(
        message: 'Return collected & on the way to warehouse',
        color: AppTheme.successColor,
        icon: Icons.inventory_2_outlined,
      );

    case 'received':
      return ItemStatus(
        message: 'Return received at warehouse. Processing your refund...',
        color: AppTheme.successColor,
        icon: Icons.warehouse_outlined,
      );

    case 'refund_processed':
      return ItemStatus(
        message: '₹$refundAmount refunded successfully!',
        color: AppTheme.successColor,
        icon: Icons.check_circle,
      );

    case 'rejected':
      return ItemStatus(
        message: 'Return request rejected by seller',
        color: AppTheme.errorColor,
        icon: Icons.block,
      );

    case 'cancelled':
      return ItemStatus(
        message: 'Return request has been cancelled.',
        color: AppTheme.successColor,
        icon: Icons.check_circle,
      );

    case 'received_by_seller':
      return ItemStatus(
        message: 'Received by seller',
        color: AppTheme.successColor,
        icon: Icons.check_circle,
      );

    case 'completed':
      return ItemStatus(
        message: 'Completed',
        color: AppTheme.successColor,
        icon: Icons.check_circle,
      );

    default:
      return ItemStatus(
        message: 'Return in progress',
        color: Colors.orange.shade700,
        icon: Icons.sync,
      );
  }
}

Future<void> makePhoneCall({required String phoneNumber, required BuildContext context}) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    if(context.mounted) {
      ToastManager.show(
          context: context,
          message: 'Could not launch dialer'
      );
    }
  }
}

bool isDarkMode(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

String getAppLogoUrl(BuildContext context) {
  const String darkLogoUrl  = "assets/images/app_logos/app-logo-dark.png";
  return darkLogoUrl;
}

String generateId(double lat, double lng, String? address) {
  final cleanAddress = (address ?? '').trim().toLowerCase();
  final key = '${lat.toStringAsFixed(6)}_${lng.toStringAsFixed(6)}_$cleanAddress';
  return key.hashCode.toString(); // or use uuid.v5 if you want
}

int? parseInt(dynamic value, {String context = 'parseInt'}) {
  if (value == null) {
    // developer.log('parseInt: value is null → returning null', name: context);
    return null;
  }

  if (value == "") {
    // developer.log('parseInt: value is empty string → returning null', name: context);
    return null;
  }

  if (value is int) {
    // developer.log('parseInt: value is already int → $value', name: context);
    return value;
  }

  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      return parsed;
    } else {
      // developer.log('parseInt: failed to parse string "$value" → returning null', name: context);
      return null;
    }
  }

  // developer.log('parseInt: unsupported type ${value.runtimeType} → returning null', name: context);
  return null;
}

double? parseDouble(dynamic value, {String context = 'parseDouble'}) {
  if (value == null) {
    // developer.log('parseDouble: value is null → returning null', name: context);
    return null;
  }

  if (value == "") {
    // developer.log('parseDouble: value is empty string → returning null', name: context);
    return null;
  }

  if (value is double) {
    return value;
  }

  if (value is int) {
    final result = value.toDouble();
    return result;
  }

  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      // developer.log('parseDouble: successfully parsed string "$value" → $parsed', name: context);
      return parsed;
    } else {
      // developer.log('parseDouble: failed to parse string "$value" → returning null', name: context);
      return null;
    }
  }

  // developer.log('parseDouble: unsupported type ${value.runtimeType} → returning null', name: context);
  return null;
}

String? parseString(dynamic value, {String context = 'parseString'}) {
  if (value == null) {
    // developer.log('parseString: value is null → returning null', name: context);
    return null;
  }

  if (value == "") {
    // developer.log('parseString: value is empty string → returning null', name: context);
    return null;
  }

  final result = value.toString();
  return result;
}

bool? parseBool(dynamic value, {String context = 'parseBool'}) {
  if (value == null) {
    // developer.log('parseBool: value is null → returning null', name: context);
    return null;
  }

  if (value is bool) {
    return value;
  }

  final str = value.toString().trim().toLowerCase();

  if (str.isEmpty) {
    // developer.log('parseBool: trimmed string is empty → returning null', name: context);
    return null;
  }

  if (str == 'true' || str == '1' || str == 'yes' || str == 'on') {
    return true;
  }

  if (str == 'false' || str == '0' || str == 'no' || str == 'off') {
    // developer.log('parseBool: recognized falsy value "$str" → false', name: context);
    return false;
  }

  // developer.log('parseBool: unrecognized value "$str" (original: $value) → returning null', name: context);
  return null;
}


const String darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#212121"}]
    },
    {
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#212121"}]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#2c2c2c"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#000000"}]
    }
  ]
  ''';


Future<String> downloadAndSaveImage(String url, String fileName) async {
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/$fileName';

  final response = await http.get(Uri.parse(url));
  final file = File(filePath);

  await file.writeAsBytes(response.bodyBytes);

  return filePath;
}


String? getDialCodeFromIso(String isoCode) {
  try {
    final country = countries.firstWhere(
          (c) => c.code.toUpperCase() == isoCode.toUpperCase(),
    );
    return '+${country.dialCode}';
  } catch (e) {
    return null;
  }
}

String? getIsoFromDialCode(String dialCode) {
  try {
    final cleanedDialCode = dialCode.replaceAll('+', '');

    final country = countries.firstWhere(
          (element) => element.dialCode == cleanedDialCode,
    );

    return country.code;
  } catch (e) {
    return null;
  }
}

/// The country list to feed into IntlPhoneField. When admin "Country
/// Validation" is OFF, returns the full world list (package default).
/// When ON, returns only the iso2-allowed subset.
///
/// Always non-null so the call site can pass it directly:
///   IntlPhoneField(countries: phoneInputAllowedCountries, ...)
List<Country> get phoneInputAllowedCountries {
  if (!AppHelpers.countryValidationEnable) return countries;
  final allowed = AppHelpers.allowedCountries
      .map((c) => c.toUpperCase())
      .toSet();
  if (allowed.isEmpty) return countries;
  final filtered = countries
      .where((c) => allowed.contains(c.code.toUpperCase()))
      .toList();
  // If somehow nothing matched (admin saved a code the package doesn't
  // know about), fall back to the full list so the picker isn't empty.
  return filtered.isEmpty ? countries : filtered;
}

/// Resolved initial ISO2 country code to seed phone inputs with. If the
/// admin's allow-list is non-empty, prefer its first entry so the picker
/// opens on an allowed country (rather than the hardcoded 'IN' default,
/// which might not even be in the allowed list).
String get phoneInputInitialIso2 {
  if (AppHelpers.countryValidationEnable) {
    final allowed = AppHelpers.allowedCountries;
    if (allowed.isNotEmpty) return allowed.first.toUpperCase();
  }
  return AppHelpers.countryCode; // 'IN'
}