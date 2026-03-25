import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OpportunityBadge extends StatelessWidget {
  final bool isExclusive;

  const OpportunityBadge({super.key, required this.isExclusive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isExclusive
            ? Colors.amber.withValues(alpha: .2)
            : Colors.grey.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isExclusive
            ? AppStrings.opportunityTypeExclusive
            : AppStrings.opportunityTypeOpen,
        style: TextStyle(
          color: isExclusive ? AppColors.accentYellow : AppColors.textGray,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
