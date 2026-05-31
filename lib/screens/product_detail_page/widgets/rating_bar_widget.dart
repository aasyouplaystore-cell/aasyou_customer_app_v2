import 'package:flutter/material.dart';
import 'package:aasyou/config/theme.dart';

class RatingBarWidget extends StatelessWidget {
  final int score;
  final double percentage;
  const RatingBarWidget(
      {required this.score, required this.percentage, super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$score',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${percentage.toInt()}%',
          style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary, fontSize: 14),
        ),
      ],
    );
  }
}
