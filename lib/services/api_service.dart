import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import '../models/compression_result.dart';

class ApiService {
  // Production API URL
  static const String baseUrl = 'https://file-compressor-backend.onrender.com/api/v1';
  
  final Dio _dio = Dio();

  // ==================== IMAGE COMPRESSION ====================
  
  // Compress Image (Mobile)
  Future<CompressionResult> compressImage({
    required File file,
    int quality = 50,
    Function(double)? onProgress,
  }) async {
    try {
      String fileName = file.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '$baseUrl/image/compress?quality=$quality',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            onProgress(sent / total);
          }
        },
      );

      return CompressionResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Compression failed: $e');
    }
  }

  // Compress Image (Web)
  Future<CompressionResult> compressImageWeb({
    required String fileName,
    required Uint8List bytes,
    int quality = 50,
    Function(double)? onProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '$baseUrl/image/compress?quality=$quality',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            onProgress(sent / total);
          }
        },
      );

      return CompressionResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Compression failed: $e');
    }
  }

  // Download Image
  Future<String> downloadImage(String filename) async {
    try {
      if (kIsWeb) {
        return '$baseUrl/image/download/$filename';
      }
      
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }
      
      if (status.isGranted) {
        // Get Downloads directory
        Directory? downloadsDir;
        if (Platform.isAndroid) {
          downloadsDir = Directory('/storage/emulated/0/Download');
          if (!await downloadsDir.exists()) {
            downloadsDir = await getExternalStorageDirectory();
          }
        } else {
          downloadsDir = await getApplicationDocumentsDirectory();
        }
        
        final savePath = '${downloadsDir!.path}/$filename';

        await _dio.download(
          '$baseUrl/image/download/$filename',
          savePath,
        );

        return savePath;
      } else {
        throw Exception('Storage permission denied');
      }
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  // ==================== PDF COMPRESSION ====================
  
  // Compress PDF (Mobile)
  Future<CompressionResult> compressPdf({
    required File file,
    int quality = 50,
    Function(double)? onProgress,
  }) async {
    try {
      String fileName = file.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '$baseUrl/pdf/compress?quality=$quality',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            onProgress(sent / total);
          }
        },
      );

      return CompressionResult.fromJson(response.data);
    } catch (e) {
      throw Exception('PDF compression failed: $e');
    }
  }

  // Compress PDF (Web)
  Future<CompressionResult> compressPdfWeb({
    required String fileName,
    required Uint8List bytes,
    int quality = 50,
    Function(double)? onProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '$baseUrl/pdf/compress?quality=$quality',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            onProgress(sent / total);
          }
        },
      );

      return CompressionResult.fromJson(response.data);
    } catch (e) {
      throw Exception('PDF compression failed: $e');
    }
  }

  // Download PDF
  Future<String> downloadPdf(String filename) async {
    try {
      if (kIsWeb) {
        return '$baseUrl/pdf/download/$filename';
      }
      
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }
      
      if (status.isGranted) {
        // Get Downloads directory
        Directory? downloadsDir;
        if (Platform.isAndroid) {
          downloadsDir = Directory('/storage/emulated/0/Download');
          if (!await downloadsDir.exists()) {
            downloadsDir = await getExternalStorageDirectory();
          }
        } else {
          downloadsDir = await getApplicationDocumentsDirectory();
        }
        
        final savePath = '${downloadsDir!.path}/$filename';

        await _dio.download(
          '$baseUrl/pdf/download/$filename',
          savePath,
        );

        return savePath;
      } else {
        throw Exception('Storage permission denied');
      }
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  // ==================== VIDEO COMPRESSION ====================
  
  // Compress Video (Mobile)
  Future<CompressionResult> compressVideo({
    required File file,
    String quality = "medium",
    String? resolution,
    Function(double)? onProgress,
  }) async {
    try {
      String fileName = file.path.split('/').last;
      
      String url = '$baseUrl/video/compress?quality=$quality';
      if (resolution != null) {
        url += '&resolution=$resolution';
      }
      
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        url,
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            onProgress(sent / total);
          }
        },
      );

      return CompressionResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Video compression failed: $e');
    }
  }

  // Compress Video (Web)
  Future<CompressionResult> compressVideoWeb({
    required String fileName,
    required Uint8List bytes,
    String quality = "medium",
    String? resolution,
    Function(double)? onProgress,
  }) async {
    try {
      String url = '$baseUrl/video/compress?quality=$quality';
      if (resolution != null) {
        url += '&resolution=$resolution';
      }
      
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        url,
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            onProgress(sent / total);
          }
        },
      );

      return CompressionResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Video compression failed: $e');
    }
  }

  // Download Video
  Future<String> downloadVideo(String filename) async {
    try {
      if (kIsWeb) {
        return '$baseUrl/video/download/$filename';
      }
      
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }
      
      if (status.isGranted) {
        // Get Downloads directory
        Directory? downloadsDir;
        if (Platform.isAndroid) {
          downloadsDir = Directory('/storage/emulated/0/Download');
          if (!await downloadsDir.exists()) {
            downloadsDir = await getExternalStorageDirectory();
          }
        } else {
          downloadsDir = await getApplicationDocumentsDirectory();
        }
        
        final savePath = '${downloadsDir!.path}/$filename';

        await _dio.download(
          '$baseUrl/video/download/$filename',
          savePath,
        );

        return savePath;
      } else {
        throw Exception('Storage permission denied');
      }
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }
}