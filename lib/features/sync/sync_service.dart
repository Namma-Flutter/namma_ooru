import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/services/database_service.dart';
import '../../core/services/connectivity_service.dart';

class SyncService {
  static const String _baseUrl = 'http://localhost:8080/api';
  static const Duration _pollInterval = Duration(minutes: 5);

  final DatabaseService _db = DatabaseService.instance;
  final ConnectivityService _connectivity = ConnectivityService();

  StreamSubscription<bool>? _connectivitySub;
  Timer? _pollTimer;
  bool _isSyncing = false;

  void init() {
    _connectivitySub = _connectivity.connectivityStream.listen((isOnline) {
      if (isOnline) {
        _processPendingReports();
        _startPolling();
      } else {
        _stopPolling();
      }
    });

    if (_connectivity.isOnline) {
      _processPendingReports();
      _startPolling();
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _stopPolling();
  }

  Future<void> forceSync() async {
    if (_connectivity.isOnline) {
      await _processPendingReports();
      await _pollStatusUpdates();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollStatusUpdates());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _processPendingReports() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = await _db.getPendingReports();
      for (final report in pending) {
        try {
          final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/reports'));

          request.fields['category'] = report.category;
          request.fields['description'] = report.description;
          request.fields['created_at'] = report.createdAt.toIso8601String();
          request.fields['anonymous_device_id'] = report.anonymousDeviceId ?? '';

          if (report.latitude != null) {
            request.fields['latitude'] = report.latitude.toString();
          }
          if (report.longitude != null) {
            request.fields['longitude'] = report.longitude.toString();
          }

          if (report.photoPath != null) {
            final photoFile = File(report.photoPath!);
            if (await photoFile.exists()) {
              request.files.add(
                await http.MultipartFile.fromPath('photo', report.photoPath!),
              );
            }
          }

          final response = await request.send();
          final body = await response.stream.bytesToString();

          if (response.statusCode == 200 || response.statusCode == 201) {
            final data = jsonDecode(body) as Map<String, dynamic>;
            final serverId = data['id']?.toString() ?? data['server_id']?.toString();
            await _db.updateSyncStatus(report.id, 'synced', serverId: serverId);
          } else {
            await _db.updateSyncStatus(report.id, 'failed', errorMessage: 'Server error: ${response.statusCode}');
          }
        } catch (e) {
          await _db.updateSyncStatus(report.id, 'failed', errorMessage: e.toString());
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pollStatusUpdates() async {
    try {
      final synced = await _db.getSyncedReports();
      if (synced.isEmpty) return;

      final ids = synced.where((r) => r.serverId != null).map((r) => r.serverId ?? '').where((id) => id.isNotEmpty).join(',');
      if (ids.isEmpty) return;

      final response = await http.get(
        Uri.parse('$_baseUrl/reports/status?ids=$ids'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        for (final item in data) {
          final serverId = item['id']?.toString();
          final status = item['status'] as String?;
          if (serverId != null && status != null) {
            final localReports = synced.where((r) => r.serverId == serverId);
            for (final local in localReports) {
              if (local.status != status) {
                await _db.updateReportStatus(local.id, status);
              }
            }
          }
        }
      }
    } catch (_) {
      // Silent fail for polling
    }
  }
}
