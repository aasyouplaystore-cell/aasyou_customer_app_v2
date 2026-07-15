import 'package:aasyou/l10n/app_localizations.dart';

/// Friendly label for an order's payment_method code.
///
/// Store-counter (POS) tenders previously fell into the generic
/// "Paid Online" default — wrong and confusing for a bill the customer
/// paid at the shop. Mirrors the web OrderCard mapping.
String friendlyPaymentLabel(String method, AppLocalizations? l10n) {
  switch (method) {
    case 'cod':
      return l10n?.cashOnDelivery ?? 'Cash on Delivery';
    case 'wallet':
      return l10n?.wallet ?? 'Wallet';
    case 'posKhata':
      return 'Khata (Udhaar) · Store';
    case 'posCash':
      return 'Cash · Store';
    case 'pos_upi':
      return 'UPI · Store';
    case 'posCustom':
      return 'Store billing';
    default:
      return l10n?.paidOnline ?? 'Paid Online';
  }
}
