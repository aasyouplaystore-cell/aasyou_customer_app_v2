import 'package:flutter/material.dart';

import '../../../model/settings_model/settings_model.dart';

EdgeInsets getPadding(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final horizontalPadding = screenWidth * 0.04;
  return EdgeInsets.symmetric(horizontal: horizontalPadding);
}

int getCrossAxisCount(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth >= 1200) return 6;
  if (screenWidth >= 800) return 5;
  if (screenWidth >= 600) return 4;
  if (screenWidth >= 400) return 4;
  return 3;
}

double getSpacing(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return screenWidth * 0.04;
}

bool isValidHomeGeneralSettings(HomeGeneralSettings settings) {
  return settings.title.trim().isNotEmpty ||
      settings.icon.trim().isNotEmpty ||
      settings.activeIcon.trim().isNotEmpty;
}