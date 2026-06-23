import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SyncStatusIndicator extends StatelessWidget {
  final String syncStatus;

  const SyncStatusIndicator({super.key, required this.syncStatus});

  @override
  Widget build(BuildContext context) {
    switch (syncStatus) {
      case 'synced':
        return const Icon(Icons.cloud_done_outlined, size: 16, color: Color(0xFF4CAF50));
      case 'pending':
        return const Icon(Icons.cloud_upload_outlined, size: 16, color: Color(0xFFFF9800));
      case 'failed':
        return const Icon(Icons.cloud_off_outlined, size: 16, color: AppColors.errorText);
      default:
        return const SizedBox.shrink();
    }
  }
}
