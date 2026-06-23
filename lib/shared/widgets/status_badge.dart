import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  static Color colorFor(String status) {
    switch (status) {
      case 'submitted':
        return const Color(0xFF2196F3);
      case 'under_review':
        return const Color(0xFFFF9800);
      case 'in_progress':
        return const Color(0xFF9C27B0);
      case 'resolved':
        return const Color(0xFF4CAF50);
      default:
        return AppColors.muted;
    }
  }

  static String labelFor(String status) {
    switch (status) {
      case 'submitted':
        return 'Submitted';
      case 'under_review':
        return 'Under Review';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: colorFor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        labelFor(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorFor(status),
        ),
      ),
    );
  }
}
