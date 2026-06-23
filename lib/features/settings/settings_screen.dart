import 'package:flutter/material.dart';

import '../../core/services/anonymous_identity_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_radius.dart';
import '../../shared/widgets/category_badge.dart';
import '../sync/sync_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _deviceId = '';
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    final id = await AnonymousIdentityService().getDeviceId();
    if (mounted) setState(() => _deviceId = id);
  }

  Future<void> _forceSync() async {
    setState(() => _isSyncing = true);
    try {
      await SyncService().forceSync();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.base),
        children: [
          // Anonymous ID section
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person_outline, size: 20, color: AppColors.muted),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Anonymous Identity',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'You are reporting anonymously. Your device ID is used to track your reports.',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.sm),
                SelectableText(
                  _deviceId,
                  style: const TextStyle(fontSize: 12, color: AppColors.mutedSoft, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Report Categories section
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.category_outlined, size: 20, color: AppColors.muted),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Report Categories',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.base),
                ...CategoryBadge.categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(CategoryBadge.iconFor(cat), size: 18, color: AppColors.muted),
                      const SizedBox(width: AppSpacing.sm),
                      Text(cat, style: const TextStyle(fontSize: 14, color: AppColors.ink)),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Sync section
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.sync_outlined, size: 20, color: AppColors.muted),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Sync',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Text(
                      'Connection: ',
                      style: TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                    Text(
                      ConnectivityService().isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ConnectivityService().isOnline ? const Color(0xFF4CAF50) : AppColors.errorText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isSyncing ? null : _forceSync,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // About section
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: AppColors.muted),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'About',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Namma Ooru v1.0.0',
                  style: TextStyle(fontSize: 14, color: AppColors.ink),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  'Report civic issues in your neighborhood. Your reports help keep our city clean and safe.',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
