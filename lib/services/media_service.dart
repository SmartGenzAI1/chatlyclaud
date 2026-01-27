// ============================================================================
// FILE: lib/services/media_service.dart
// PURPOSE: Media handling service for voice messages and image sharing
// ============================================================================

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../core/constants/app_constants.dart';
import '../core/errors/error_handler.dart';

class MediaService {
  static final MediaService _instance = MediaService._internal();
  final ImagePicker _imagePicker = ImagePicker();
  final Record _record = Record();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  factory MediaService() => _instance;

  MediaService._internal();

  /// Request necessary permissions for media operations
  Future<bool> requestMediaPermissions() async {
    try {
      // Request storage permission
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        return false;
      }

      // Request microphone permission for audio recording
      final microphoneStatus = await Permission.microphone.request();
      if (!microphoneStatus.isGranted) {
        return false;
      }

      // Request camera permission for image capture
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        return false;
      }

      return true;
    } catch (e) {
      await ErrorHandler.logError(e, null, context: 'MediaService.requestMediaPermissions');
      return false;
    }
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final permissionGranted = await requestMediaPermissions();
      if (!permissionGranted) {
        throw Exception('Media permissions not granted');
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }

      return null;
    } catch (e) {
      await ErrorHandler.logError(e, null, context: 'MediaService.pickImageFromGallery');
      rethrow;
    }
  }

  /// Capture image from camera
  Future<File?> captureImageFromCamera() async {
    try {
      final permissionGranted = await requestMediaPermissions();
      if (!permissionGranted) {
        throw Exception('Media permissions not granted');
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }

      return null;
    } catch (e) {
      await ErrorHandler.logError(e, null, context: 'MediaService.captureImageFromCamera');
      rethrow;
    }
  }

  /// Compress and optimize image
  Future<File> compressImage(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final compressedImagePath = '${tempDir.path}/compressed_$timestamp.jpg';

      // Load image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image if too large
      final maxSize = 1024;
      if (image.width > maxSize || image.height > maxSize) {
        final aspectRatio = image.width / image.height;
        int newWidth, newHeight;

        if (image.width > image.height) {
          newWidth = maxSize;
          newHeight = (maxSize / aspectRatio).toInt();
        } else {
          newHeight = maxSize;
          newWidth = (maxSize * aspectRatio).toInt();
        }

        final resizedImage = img.copyResize(image, width: newWidth, height: newHeight);
        final compressedBytes = img.encodeJpg(resizedImage, quality: 80);
        await File(compressedImagePath).writeAsBytes(compressedBytes);
      } else {
        // Just compress without resizing
        final compressedBytes = img.encodeJpg(image, quality: 80);
        await File(compressedImagePath).writeAsBytes(compressedBytes);
      }

      final compressedFile = File(compressedImagePath);
      final fileSizeInMB = compressedFile.lengthSync() / (1024 * 1024);

      // If still too large, reduce quality further
      if (fileSizeInMB > AppConstants.maxImageSizeMB) {
        return compressImageWithQuality(imageFile, 60);
      }

      return compressedFile;
    } catch (e) {
      await ErrorHandler.logError(e, null, context: 'MediaService.compressImage');
      rethrow;
    }
  }

  /// Compress image with specific quality
  Future<File> compressImageWithQuality(File imageFile, int quality) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final compressedImagePath = '${tempDir.path}/compressed_$timestamp.jpg';

    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final compressedBytes = img.encodeJpg(image, quality: quality);
    await File(compressedImagePath).writeAsBytes(compressedBytes);

    return File(compressedImagePath);
  }

  /// Start audio recording
  Future<void> startAudioRecording() async {
    try {
      final permissionGranted = await requestMediaPermissions();
      if (!permissionGranted) {
        throw Exception('Microphone permission not granted');
      }

      if (await _record.isRecording()) {
        throw Exception('Recording already in progress');
      }

      await _record.start();
    } catch (e) {
      await ErrorHandler.logError(e, null, context: 'MediaService.startAudioRecording');
      rethrow;
    }
  }

  /// Stop audio recording and return file path
  Future<File?> stopAudioRecording() async {
    try {
      if (!await _record.isRecording()) {
        throw Exception('No recording in progress');
      }

      final path = await _record.stop();
      if (path != null) {
        return File(path);
      }

      return null;
    } catch (e) {
      await ErrorHandler.logError(e, null, context: 'MediaService.stopAudioRecording');
      rethrow;
    }
  }

  /// Check if recording is in progress
  Future<bool> isRecording() async {
    try {
      return await _record.isRecording();
    } catch (e) {
      await ErrorHandler.logError(e, null, context: 'MediaService.isRecording');
      return false;
    }
  }

  /// Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile, String chatId, String messageId) async {
    try {
      // Compress image first
      final compressedFile = await compressImage(imageFile);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'images/$chatId/$messageId/$timestamp.jpg';
      final storageRef = _storage.ref().child(fileName);

      final uploadTask = storageRef.putFile(compressedFile);
      final snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } else {
        throw Exception('Image upload failed');
      }
    } catch (e) {
      await ErrorHandler.logError(e, null, context: 'MediaService.uploadImage');
      rethrow;
    }
  }

  /// Upload audio to Firebase Storage
  Future<String> uploadAudio(File audioFile, String chatId, String messageId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'audio/$chatId/$messageId/$timestamp.m4a';
      final storageRef = _storage.ref().child(fileName);

      final uploadTask = storageRef.putFile(audioFile);
      final snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } else {
        throw Exception('Audio upload failed');
      }
    } catch (e) {
      await ErrorHandler.logError(e, null, context: 'MediaService.uploadAudio');
      rethrow;
    }
  }

  /// Get file size in MB
  double getFileSizeInMB(File file) {
    final fileSizeInBytes = file.lengthSync();
    return fileSizeInBytes / (1024 * 1024);
  }

  /// Check if file size is within limits
  bool isFileSizeWithinLimit(File file, double maxMB) {
    final fileSizeMB = getFileSizeInMB(file);
    return fileSizeMB <= maxMB;
  }

  /// Delete temporary file
  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      await ErrorHandler.logError(e, null, context: 'MediaService.deleteFile');
    }
  }

  /// Get audio duration (placeholder implementation)
  Future<Duration> getAudioDuration(File audioFile) async {
    // This would require additional audio processing libraries
    // For now, return a default duration
    return Duration(seconds: 30); // Default max duration
  }

  /// Validate audio file
  bool isValidAudioFile(File audioFile) {
    final fileSizeMB = getFileSizeInMB(audioFile);
    return fileSizeMB <= AppConstants.maxAudioSizeMB;
  }

  /// Validate image file
  bool isValidImageFile(File imageFile) {
    final fileSizeMB = getFileSizeInMB(imageFile);
    return fileSizeMB <= AppConstants.maxImageSizeMB;
  }

  /// Cleanup temporary files
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      for (final file in files) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          if (fileName.startsWith('compressed_') || fileName.startsWith('audio_')) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      await ErrorHandler.logError(e, null, context: 'MediaService.cleanupTempFiles');
    }
  }
}