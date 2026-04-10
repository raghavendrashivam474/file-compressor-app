import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/compression_result.dart';

class ApiService {
  // Change to localhost for Chrome testing
  static const String baseUrl = 'https://file-compressor-backend-bacl.onrender.com/api/v1';
  
  final Dio _dio = Dio();

  // ==================== IMAGE COMPRESSION ====================
  
  // Compress Image (Mobile - uses File)
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

  // Compress Image (Web - uses bytes)
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
      
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$filename';

      await _dio.download(
        '$baseUrl/video/download/$filename',
        savePath,
      );

      return savePath;
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  // Download Compressed Image
  Future<String> downloadImage(String filename) async {
    try {
      if (kIsWeb) {
        // On web, return download URL for browser
        return '$baseUrl/image/download/$filename';
      }
      
      // On mobile, download to device storage
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$filename';

      await _dio.download(
        '$baseUrl/image/download/$filename',
        savePath,
      );

      return savePath;
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  // ==================== PDF COMPRESSION ====================
  
  // Compress PDF (Mobile - uses File)
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

  // Compress PDF (Web - uses bytes)
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

  // Download Compressed PDF
  Future<String> downloadPdf(String filename) async {
    try {
      if (kIsWeb) {
        // On web, return download URL for browser
        return '$baseUrl/pdf/download/$filename';
      }
      
      // On mobile, download to device storage
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$filename';

      await _dio.download(
        '$baseUrl/pdf/download/$filename',
        savePath,
      );

      return savePath;
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }
}