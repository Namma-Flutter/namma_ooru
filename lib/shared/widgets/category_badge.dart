import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({super.key, required this.category});

  static const categories = ['Trash', 'Pothole', 'Broken Streetlight', 'Graffiti', 'Illegal Dumping', 'Other'];

  static IconData iconFor(String category) {
    switch (category) {
      case 'Trash':
        return Icons.delete_outline;
      case 'Pothole':
        return Icons.warning_amber_rounded;
      case 'Broken Streetlight':
        return Icons.lightbulb_outline;
      case 'Graffiti':
        return Icons.brush_outlined;
      case 'Illegal Dumping':
        return Icons.construction_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconFor(category), size: 14, color: AppColors.muted),
          const SizedBox(width: 4),
          Text(
            category,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
