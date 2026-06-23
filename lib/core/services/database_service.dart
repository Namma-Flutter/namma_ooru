import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';

class DatabaseService {
  final AppDatabase _db;
  static DatabaseService? _instance;

  DatabaseService._(this._db);

  static Future<DatabaseService> init() async {
    if (_instance != null) return _instance!;
    final db = AppDatabase();
    _instance = DatabaseService._(db);
    return _instance!;
  }

  static DatabaseService get instance {
    if (_instance == null) {
      throw StateError('DatabaseService not initialized. Call init() first.');
    }
    return _instance!;
  }

  AppDatabase get database => _db;

  Future<int> insertReport(ReportsTableCompanion report) async {
    return await _db.into(_db.reportsTable).insert(report);
  }

  Future<List<ReportsTableData>> getAllReports() async {
    return (_db.select(_db.reportsTable)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
      .get();
  }

  Future<ReportsTableData?> getReportById(int id) async {
    return (_db.select(_db.reportsTable)
      ..where((t) => t.id.equals(id)))
      .getSingleOrNull();
  }

  Future<int> deleteReport(int id) async {
    return (_db.delete(_db.reportsTable)
      ..where((t) => t.id.equals(id)))
      .go();
  }

  Future<int> updateReportStatus(int id, String status) async {
    return (_db.update(_db.reportsTable)
      ..where((t) => t.id.equals(id)))
      .write(ReportsTableCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ));
  }

  Future<int> updateSyncStatus(int id, String syncStatus, {String? serverId, String? errorMessage}) async {
    return (_db.update(_db.reportsTable)
      ..where((t) => t.id.equals(id)))
      .write(ReportsTableCompanion(
        syncStatus: Value(syncStatus),
        serverId: Value(serverId),
        errorMessage: Value(errorMessage),
        updatedAt: Value(DateTime.now()),
      ));
  }

  Future<List<ReportsTableData>> getPendingReports() async {
    return (_db.select(_db.reportsTable)
      ..where((t) => t.syncStatus.equals('pending'))
      ..orderBy([(o) => OrderingTerm(expression: o.createdAt, mode: OrderingMode.asc)]))
      .get();
  }

  Future<List<ReportsTableData>> getSyncedReports() async {
    return (_db.select(_db.reportsTable)
      ..where((t) => t.syncStatus.equals('synced')))
      .get();
  }

  Stream<List<ReportsTableData>> watchAllReports() {
    return (_db.select(_db.reportsTable)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
      .watch();
  }

  Stream<ReportsTableData?> watchReportById(int id) {
    return (_db.select(_db.reportsTable)
      ..where((t) => t.id.equals(id)))
      .watchSingleOrNull();
  }

  Future<String?> getPreference(String key) async {
    final row = await (_db.select(_db.appPreferencesTable)
      ..where((t) => t.key.equals(key)))
      .getSingleOrNull();
    return row?.value;
  }

  Future<void> setPreference(String key, String value) async {
    await _db.into(_db.appPreferencesTable).insert(
      AppPreferencesTableCompanion(
        key: Value(key),
        value: Value(value),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<String> getOrCreateDeviceId() async {
    const key = 'anonymous_device_id';
    final existing = await getPreference(key);
    if (existing != null) return existing;
    final newId = const Uuid().v4();
    await setPreference(key, newId);
    return newId;
  }
}
