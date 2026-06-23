import 'database_service.dart';

class AnonymousIdentityService {
  static final AnonymousIdentityService _instance = AnonymousIdentityService._();
  AnonymousIdentityService._();
  factory AnonymousIdentityService() => _instance;

  String? _deviceId;

  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    final dbService = DatabaseService.instance;
    _deviceId = await dbService.getOrCreateDeviceId();
    return _deviceId!;
  }

  Future<String> requireDeviceId() async {
    return await getDeviceId();
  }
}
