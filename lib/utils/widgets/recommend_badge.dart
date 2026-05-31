import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';

enum RecommendBadgeStyle { pill, chip }

class RecommendBadge extends StatelessWidget {
  final RecommendBadgeStyle style;
  const RecommendBadge({super.key, this.style = RecommendBadgeStyle.pill});

  @override
  Widget build(BuildContext context) {
    const Color bg = AppTheme.primaryColor;
    const Color fg = Colors.white;
    final String label =
        AppLocalizations.of(context)?.recommended ?? 'Recommended';

    final bool isChip = style == RecommendBadgeStyle.chip;
    final EdgeInsets padding = isChip
        ? EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 3);
    final BorderRadius radius = isChip
        ? BorderRadius.circular(4.r)
        : BorderRadius.circular(999);
    final double iconSize = isChip ? 10.sp : 12;
    final double fontSize = isChip ? 9.sp : 11;
    final double gap = isChip ? 3.w : 4;

    return Semantics(
      label: label,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(color: bg, borderRadius: radius),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(TablerIcons.sparkles, size: iconSize, color: fg),
            SizedBox(width: gap),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
