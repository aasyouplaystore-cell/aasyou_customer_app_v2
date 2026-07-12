import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:aasyou/utils/widgets/custom_textfield.dart';
import '../../../config/helper.dart';
import '../../../config/theme.dart';

/// "GST invoice (business purchase)" section on the cart/checkout page.
/// Collects the buyer GSTIN + registered legal name; the backend derives
/// place_of_supply and allocates a per-seller tax invoice. Structure is
/// checked here (15-char pattern); the server runs the authoritative
/// mod-36 checksum.
class GstInvoiceWidget extends StatefulWidget {
  final bool enabled;
  final String gstin;
  final String legalName;
  final bool isEnabled;
  final void Function(bool enabled, String gstin, String legalName) onChanged;

  const GstInvoiceWidget({
    super.key,
    required this.enabled,
    required this.gstin,
    required this.legalName,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  State<GstInvoiceWidget> createState() => _GstInvoiceWidgetState();
}

class _GstInvoiceWidgetState extends State<GstInvoiceWidget> {
  static final RegExp _gstinRe = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[A-Z]{1}[0-9A-Z]{1}$');

  late final TextEditingController _gstinCtrl =
      TextEditingController(text: widget.gstin);
  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.legalName);

  @override
  void dispose() {
    _gstinCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _valid =>
      !widget.enabled || _gstinRe.hasMatch(_gstinCtrl.text.trim().toUpperCase());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: isDarkMode(context)
            ? Theme.of(context).colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Row(
              children: [
                Icon(TablerIcons.file_invoice,
                    size: 22.sp, color: AppTheme.primaryColor),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'GST invoice (business purchase)',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isDarkMode(context) ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Switch(
                  value: widget.enabled,
                  onChanged: widget.isEnabled
                      ? (v) => widget.onChanged(
                          v, _gstinCtrl.text.trim(), _nameCtrl.text.trim())
                      : null,
                  activeColor: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextFormField(
                    controller: _gstinCtrl,
                    enabled: widget.isEnabled,
                    hintText: 'GSTIN (e.g. 22AAAAA0000A1Z5)',
                    onChanged: (v) {
                      setState(() {});
                      widget.onChanged(widget.enabled, v.trim().toUpperCase(),
                          _nameCtrl.text.trim());
                    },
                  ),
                  SizedBox(height: 10.h),
                  CustomTextFormField(
                    controller: _nameCtrl,
                    enabled: widget.isEnabled,
                    hintText: 'Business / legal name (as per GSTIN)',
                    onChanged: (v) => widget.onChanged(widget.enabled,
                        _gstinCtrl.text.trim().toUpperCase(), v.trim()),
                  ),
                  if (!_valid) ...[
                    SizedBox(height: 6.h),
                    Text(
                      'Enter a valid 15-character GSTIN.',
                      style: TextStyle(fontSize: 11.sp, color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
            crossFadeState: widget.enabled
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
