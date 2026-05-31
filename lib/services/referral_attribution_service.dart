import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Holds a referral code captured from a deep link (or pre-auth input) so it
/// can be applied automatically once the user completes social sign-in.
///
/// Backed by the same Hive `AppPrefsBox` already used for simple app flags.
/// Read/written only via this service — widgets and blocs must never touch
/// the box directly.
class ReferralAttributionService {
  static const String _boxName = 'AppPrefsBox';
  static const String _codeKey = 'pendingReferralCode';

  Future<Box> _box() => Hive.openBox(_boxName);

  Future<void> setCode(String code) async {
    if (code.isEmpty) return;
    try {
      final box = await _box();
      await box.put(_codeKey, code);
    } catch (e) {
      debugPrint('ReferralAttributionService.setCode failed: $e');
    }
  }

  Future<String?> getCode() async {
    try {
      final box = await _box();
      return box.get(_codeKey) as String?;
    } catch (e) {
      debugPrint('ReferralAttributionService.getCode failed: $e');
      return null;
    }
  }

  Future<void> clearCode() async {
    try {
      final box = await _box();
      await box.delete(_codeKey);
    } catch (e) {
      debugPrint('ReferralAttributionService.clearCode failed: $e');
    }
  }
}
