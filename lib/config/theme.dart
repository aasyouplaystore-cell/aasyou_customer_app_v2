import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AppTheme {
  /// App main color
  static const Color primaryColor = Color(0xFFC2410C);
  static Color primaryVariant = primaryColor.withValues(alpha: 0.8);

  /// Brand palette tokens
  static const Color brandPrimaryHover = Color(0xFFA8350A);
  static const Color brandPrimaryPressed = Color(0xFF9A2D0A);
  static const Color brandPrimaryDark = Color(0xFFFB923C);
  static const Color brandAccent = Color(0xFFFF6A1F);
  static const Color brandAccentFlame = Color(0xFFFFB020);
  static const Color brandPrimarySoft = Color(0xFFFFEDE3);

  static Color lightFontColor = Colors.black;
  static Color darkFontColor = Colors.white;

  /// Light Theme Colors
  static const Color mainLightBackgroundColor = Colors.white;
  static Color mainLightBackgroundColor2 = Colors.grey.shade200;
  static const Color mainLightContainerBgColor = Color(0xFFF7FAFC);
  static const Color lightSecondary = Color(0xFFE0E0E0);
  static const Color lightTertiary = Color(0xFF0D1117);
  static Color lightProductCardColor = Colors.grey.shade100;
  static const Color lightSubCategoryCardColor = Color(0xFFE5FBFF);
  static Color lightOutline = Colors.grey.shade200;
  static Color lightOutlineVariant = Colors.grey.shade300;

  /// Dark Theme Colors — 4-level surface elevation system
  static const Color mainDarkBackgroundColor = Color(0xFF0D0D0D);    // page bg
  static const Color mainDarkContainerBgColor = Color(0xFF1A1A1A);   // cards (L1)
  static const Color darkSubCategoryCardColor = Color(0xFF242424);   // elevated cards (L2)
  static const Color darkExtraCardColor = Color(0xFF2E2E2E);          // chips / inputs (L3)
  static const Color darkTertiary = Color(0xFFF0F0F0);                // primary text
  static Color darkProductCardColor = const Color(0xFF1A1A1A);
  static Color darkOutline = const Color(0x1FFFFFFF);                 // 12% white border
  static Color darkOutlineVariant = const Color(0x0FFFFFFF);          // 6% white divider

  /// Typography
  static const String fontFamily = 'LexendDeca';

  /// Messages Color
  static const Color errorColor = Color(0xFFB91C1C);
  static const Color successColor = Color(0xFF15803D);
  static const Color warningColor = Color(0xFFB45309);
  static const Color semanticInfo = Color(0xFF0369A1);

  /// Rating Star color
  static const Color ratingStarColor = brandAccentFlame;
  static const IconData ratingStarIcon = TablerIcons.star;
  static const IconData ratingStarIconFilled = TablerIcons.star_filled;
  static const IconData ratingStarIconHalfFilled = TablerIcons.star_half_filled;


  /// Delivery Time Widget Color
  static const Color deliveryTimeWidgetColor = Color(0xFFC2FBFF);

  /// Discount Card Color
  static const Color discountCardColor = Color(0xFF256533);
/*
  /// Sponsored Badge Color
  static const Color sponsoredBadgeColor = ;*/

  ///Coupon Card Colors
  static Color couponShadeColor = Colors.blue.shade50;
  static Color couponCollectBgColor = primaryColor.withValues(alpha: 0.1);

  /// Resolves a [ThemeMode] to a concrete [ThemeData].
  /// [brightness] is only used when [mode] is [ThemeMode.system].
  static ThemeData resolveFromMode(ThemeMode mode, Brightness brightness) {
    switch (mode) {
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        return brightness == Brightness.dark ? darkTheme : lightTheme;
      case ThemeMode.light:
        return lightTheme;
    }
  }
  /// Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      surface: mainLightBackgroundColor,
      surfaceContainer: mainLightBackgroundColor2,
      primary: mainLightContainerBgColor,
      onPrimary: lightProductCardColor,
      onSecondary: lightSubCategoryCardColor,
      secondary: lightSecondary,
      tertiary: lightTertiary,
      outline: lightOutline,
      outlineVariant: lightOutlineVariant,
      onSecondaryContainer: Colors.grey[700]
    ),
    fontFamily: AppTheme.fontFamily,

    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(
          lightTertiary,
        ),
      )
    ),

  );

  /// Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: mainDarkBackgroundColor,
    colorScheme: ColorScheme.dark(
      surface: mainDarkBackgroundColor,
      surfaceContainer: mainDarkContainerBgColor,
      primary: mainDarkContainerBgColor,
      onPrimary: mainDarkContainerBgColor,
      onSecondary: darkSubCategoryCardColor,
      secondary: darkExtraCardColor,
      tertiary: darkTertiary,
      onSecondaryContainer: const Color(0xFF9E9E9E),
      outline: darkOutline,
      outlineVariant: darkOutlineVariant,
      error: Colors.red,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: mainDarkBackgroundColor,
      foregroundColor: darkTertiary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF111111),
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF6B6B6B),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: mainDarkContainerBgColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0x1FFFFFFF), width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x14FFFFFF),
      thickness: 0.5,
      space: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: mainDarkContainerBgColor,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x1FFFFFFF), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x1FFFFFFF), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1),
      ),
      hintStyle: const TextStyle(color: Color(0xFF6B6B6B)),
    ),
    fontFamily: AppTheme.fontFamily,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(darkTertiary),
      ),
    ),
  );
}