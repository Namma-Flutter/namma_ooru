import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/database/database.dart';
import '../../core/services/database_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/photo_service.dart';
import '../../core/services/anonymous_identity_service.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_radius.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/category_badge.dart';

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  String? _photoPath;
  double? _latitude;
  double? _longitude;
  bool _isLocating = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() => _isLocating = true);
    final locationService = LocationService();
    final position = await locationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _latitude = position?.latitude;
        _longitude = position?.longitude;
        _isLocating = false;
      });
    }
  }

  Future<void> _capturePhoto() async {
    final photoService = PhotoService();
    final path = await photoService.captureFromCamera();
    if (mounted) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _retakePhoto() async {
    final photoService = PhotoService();
    if (_photoPath != null) {
      await photoService.deletePhoto(_photoPath!);
    }
    await _capturePhoto();
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<Map<String, double>>(
      context,
      MaterialPageRoute(
        builder: (_) => _LocationPickerScreen(
          latitude: _latitude ?? 0,
          longitude: _longitude ?? 0,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _latitude = result['lat'];
        _longitude = result['lng'];
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dbService = DatabaseService.instance;
      final identityService = AnonymousIdentityService();
      final deviceId = await identityService.getDeviceId();

      await dbService.insertReport(
        ReportsTableCompanion(
          category: drift.Value(_selectedCategory!),
          description: drift.Value(_descriptionController.text.trim()),
          latitude: drift.Value(_latitude),
          longitude: drift.Value(_longitude),
          photoPath: drift.Value(_photoPath),
          anonymousDeviceId: drift.Value(deviceId),
        ),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save report: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Report'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.base),
          children: [
            const Text(
              'Category',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: CategoryBadge.categories.map((cat) {
                final selected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: AppColors.primary.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : AppColors.ink,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.hairline,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text(
              'Description',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Describe the issue in detail...',
              ),
              validator: (value) {
                if (value == null || value.trim().length < 10) {
                  return 'Please enter at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text(
              'Photo',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_photoPath != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Image.file(
                      File(_photoPath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                        onPressed: _retakePhoto,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: _capturePhoto,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Take Photo'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(100),
                  side: const BorderSide(color: AppColors.hairline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),

            const Text(
              'Location',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_isLocating)
              const Row(
                children: [
                  SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Getting your location...',
                    style: TextStyle(fontSize: 14, color: AppColors.muted),
                  ),
                ],
              )
            else if (_latitude != null && _longitude != null)
              GestureDetector(
                onTap: _openLocationPicker,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: SizedBox(
                    height: 120,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(_latitude!, _longitude!),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
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
                              point: LatLng(_latitude!, _longitude!),
                              child: const Icon(Icons.location_on, color: AppColors.primary, size: 32),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  const Icon(Icons.location_off, size: 16, color: AppColors.muted),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'Location not available',
                    style: TextStyle(fontSize: 14, color: AppColors.muted),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _captureLocation,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.xl),

            AppButton(
              label: 'Submit Report',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _LocationPickerScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const _LocationPickerScreen({required this.latitude, required this.longitude});

  @override
  State<_LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<_LocationPickerScreen> {
  late MapController _mapController;
  late LatLng _selectedPoint;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedPoint = LatLng(widget.latitude, widget.longitude);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust Location'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, {'lat': _selectedPoint.latitude, 'lng': _selectedPoint.longitude}),
            child: const Text('Confirm'),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _selectedPoint,
          initialZoom: 15,
          onTap: (tapPosition, point) {
            setState(() => _selectedPoint = point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.namma_ooru.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedPoint,
                child: const Icon(Icons.location_on, color: AppColors.primary, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
