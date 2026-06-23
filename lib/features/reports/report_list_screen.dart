import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/services/database_service.dart';
import '../../core/database/database.dart' show ReportsTableData;
import '../../shared/theme/app_spacing.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/sync_status_indicator.dart';
import '../../shared/widgets/category_badge.dart';
import '../../shared/widgets/status_badge.dart';
import '../sync/sync_service.dart';
import 'report_detail_screen.dart';
import 'new_report_screen.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final DatabaseService _db = DatabaseService.instance;
  late final SyncService _syncService;
  StreamSubscription<List<ReportsTableData>>? _reportsSubscription;
  List<ReportsTableData> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _syncService = SyncService();
    _syncService.init();
    _reportsSubscription = _db.watchAllReports().listen((reports) {
      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _reportsSubscription?.cancel();
    _syncService.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _syncService.forceSync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const NewReportScreen()),
          );
          if (result == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report submitted successfully'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
          ? EmptyStateWidget(
              icon: Icons.assignment_outlined,
              title: 'No reports yet',
              subtitle: 'Tap the + button to report a civic issue',
              buttonLabel: 'Create First Report',
              onButtonTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const NewReportScreen()),
                );
                if (result == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report submitted successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            )
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.base),
                itemCount: _reports.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final report = _reports[index];
                  return _ReportListItem(
                    report: report,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ReportDetailScreen(reportId: report.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _ReportListItem extends StatelessWidget {
  final ReportsTableData report;
  final VoidCallback onTap;

  const _ReportListItem({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: report.photoPath != null
                    ? Image.file(
                        File(report.photoPath!),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _photoPlaceholder(),
                      )
                    : _photoPlaceholder(),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
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
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      report.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        StatusBadge(status: report.status),
                        const Spacer(),
                        Text(
                          _formatDate(report.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6a6a6a),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFf7f7f7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        CategoryBadge.iconFor(report.category),
        size: 28,
        color: const Color(0xFF929292),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
