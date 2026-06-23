import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/services/database_service.dart';
import '../../core/database/database.dart' show ReportsTableData;
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_radius.dart';
import '../../shared/widgets/category_badge.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/sync_status_indicator.dart';

class ReportDetailScreen extends StatefulWidget {
  final int reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final DatabaseService _db = DatabaseService.instance;
  StreamSubscription<ReportsTableData?>? _reportSubscription;
  ReportsTableData? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _reportSubscription = _db.watchReportById(widget.reportId).listen((report) {
      if (mounted) {
        setState(() {
          _report = report;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _reportSubscription?.cancel();
    super.dispose();
  }

  Future<void> _deleteReport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('This report has not been synced yet. Delete it?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorText),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && _report != null) {
      if (_report!.photoPath != null) {
        final file = File(_report!.photoPath!);
        if (await file.exists()) await file.delete();
      }
      await _db.deleteReport(widget.reportId);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report Detail')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final report = _report;
    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report Detail')),
        body: const Center(child: Text('Report not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Detail'),
        actions: [
          if (report.syncStatus == 'pending')
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteReport,
            ),
        ],
      ),
      body: ListView(
        children: [
          if (report.photoPath != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.md)),
              child: Image.file(
                File(report.photoPath!),
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CategoryBadge(category: report.category),
                    const Spacer(),
                    SyncStatusIndicator(syncStatus: report.syncStatus),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                Text(
                  report.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.ink,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.muted),
                    ),
                    StatusBadge(status: report.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.muted),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year} at ${report.createdAt.hour}:${report.createdAt.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                if (report.latitude != null && report.longitude != null) ...[
                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: SizedBox(
                      height: 180,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(report.latitude!, report.longitude!),
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.namma_ooru.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(report.latitude!, report.longitude!),
                                child: const Icon(Icons.location_on, color: AppColors.primary, size: 36),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${report.latitude!.toStringAsFixed(6)}, ${report.longitude!.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      SyncStatusIndicator(syncStatus: report.syncStatus),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _syncStatusText(report.syncStatus),
                        style: const TextStyle(fontSize: 14, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),

                if (report.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: AppColors.errorText.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.errorText.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      report.errorMessage!,
                      style: const TextStyle(fontSize: 13, color: AppColors.errorText),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _syncStatusText(String status) {
    switch (status) {
      case 'synced':
        return 'Synced to server';
      case 'pending':
        return 'Waiting to sync';
      case 'failed':
        return 'Sync failed. Tap to retry.';
      default:
        return status;
    }
  }
}
