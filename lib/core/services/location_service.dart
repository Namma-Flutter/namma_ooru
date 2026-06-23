import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._();
  LocationService._();
  factory LocationService() => _instance;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      return result == LocationPermission.whileInUse || result == LocationPermission.always;
    }
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  Future<Position?> getCurrentLocation({Duration timeout = const Duration(seconds: 10)}) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      ).timeout(timeout);
    } catch (e) {
      return await Geolocator.getLastKnownPosition();
    }
  }
}
