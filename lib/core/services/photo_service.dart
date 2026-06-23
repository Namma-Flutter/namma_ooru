import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PhotoService {
  static final PhotoService _instance = PhotoService._();
  PhotoService._();
  factory PhotoService() => _instance;

  final ImagePicker _picker = ImagePicker();

  Future<String?> captureFromCamera() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (xFile == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final photoDir = Directory(p.join(dir.path, 'photos'));
    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = p.join(photoDir.path, fileName);
    await File(xFile.path).copy(savedPath);

    return savedPath;
  }

  Future<String?> getLocalPath(String relativePath) async {
    final file = File(relativePath);
    if (await file.exists()) return relativePath;
    return null;
  }

  Future<bool> deletePhoto(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      return true;
    }
    return false;
  }

  Future<File?> getPhotoFile(String path) async {
    final file = File(path);
    if (await file.exists()) return file;
    return null;
  }
}
