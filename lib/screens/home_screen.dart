import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/api_service.dart';
import '../models/compression_result.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  
  File? _selectedFile;
  PlatformFile? _selectedPlatformFile;
  bool _isCompressing = false;
  double _progress = 0.0;
  int _quality = 50;
  String _selectedType = 'image'; // 'image', 'pdf', or 'video'
  String _videoQuality = 'medium'; // 'low', 'medium', 'high'
  String? _videoResolution; // '480p', '720p', '1080p', or null

  Future<void> _pickFile() async {
    FileType fileType;
    List<String>? allowedExtensions;

    switch (_selectedType) {
      case 'image':
        fileType = FileType.image;
        break;
      case 'pdf':
        fileType = FileType.custom;
        allowedExtensions = ['pdf'];
        break;
      case 'video':
        fileType = FileType.video;
        break;
      default:
        fileType = FileType.image;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: fileType,
      allowedExtensions: allowedExtensions,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        _selectedPlatformFile = result.files.single;
        if (!kIsWeb) {
          _selectedFile = File(result.files.single.path!);
        }
      });
    }
  }

  Future<void> _compressFile() async {
    if (_selectedPlatformFile == null) return;

    setState(() {
      _isCompressing = true;
      _progress = 0.0;
    });

    try {
      CompressionResult result;
      
      if (_selectedType == 'image') {
        if (kIsWeb) {
          result = await _apiService.compressImageWeb(
            fileName: _selectedPlatformFile!.name,
            bytes: _selectedPlatformFile!.bytes!,
            quality: _quality,
            onProgress: (progress) => setState(() => _progress = progress),
          );
        } else {
          result = await _apiService.compressImage(
            file: _selectedFile!,
            quality: _quality,
            onProgress: (progress) => setState(() => _progress = progress),
          );
        }
      } else if (_selectedType == 'pdf') {
        if (kIsWeb) {
          result = await _apiService.compressPdfWeb(
            fileName: _selectedPlatformFile!.name,
            bytes: _selectedPlatformFile!.bytes!,
            quality: _quality,
            onProgress: (progress) => setState(() => _progress = progress),
          );
        } else {
          result = await _apiService.compressPdf(
            file: _selectedFile!,
            quality: _quality,
            onProgress: (progress) => setState(() => _progress = progress),
          );
        }
      } else {
        // Video
        if (kIsWeb) {
          result = await _apiService.compressVideoWeb(
            fileName: _selectedPlatformFile!.name,
            bytes: _selectedPlatformFile!.bytes!,
            quality: _videoQuality,
            resolution: _videoResolution,
            onProgress: (progress) => setState(() => _progress = progress),
          );
        } else {
          result = await _apiService.compressVideo(
            file: _selectedFile!,
            quality: _videoQuality,
            resolution: _videoResolution,
            onProgress: (progress) => setState(() => _progress = progress),
          );
        }
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              result: result,
              fileType: _selectedType,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCompressing = false;
        _selectedFile = null;
        _selectedPlatformFile = null;
      });
    }
  }

  String _getFileSize() {
    if (_selectedPlatformFile == null) return '0';
    
    int bytes = kIsWeb 
        ? _selectedPlatformFile!.bytes!.length 
        : _selectedFile!.lengthSync();
    
    return (bytes / 1024 / 1024).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Compressor'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getFileTypeIcon(),
                    size: 60,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Compress Your Files',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reduce file size without losing quality',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),

                // File Type Selector
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTypeButton(
                            icon: Icons.image,
                            label: 'Image',
                            type: 'image',
                          ),
                        ),
                        Expanded(
                          child: _buildTypeButton(
                            icon: Icons.picture_as_pdf,
                            label: 'PDF',
                            type: 'pdf',
                          ),
                        ),
                        Expanded(
                          child: _buildTypeButton(
                            icon: Icons.videocam,
                            label: 'Video',
                            type: 'video',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Selected File Info
                if (_selectedPlatformFile != null)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getFileTypeIcon(),
                          color: Colors.deepPurple,
                        ),
                      ),
                      title: Text(
                        _selectedPlatformFile!.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${_getFileSize()} MB',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedFile = null;
                            _selectedPlatformFile = null;
                          });
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Quality Controls
                if (_selectedPlatformFile != null) ...[
                  if (_selectedType == 'video')
                    _buildVideoQualitySelector()
                  else
                    _buildQualitySlider(),
                  const SizedBox(height: 24),
                ],

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isCompressing ? null : _pickFile,
                        icon: const Icon(Icons.folder_open),
                        label: Text(_selectedPlatformFile == null ? 'Pick File' : 'Change File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade100,
                          foregroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedPlatformFile != null) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isCompressing ? null : _compressFile,
                          icon: const Icon(Icons.compress),
                          label: const Text('Compress'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Progress Indicator
                if (_isCompressing) ...[
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      CircularProgressIndicator(
                        value: _progress > 0 ? _progress : null,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedType == 'video'
                            ? 'Compressing video... This may take a while'
                            : 'Compressing... ${(_progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_selectedType == 'video')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Please wait, video processing takes time',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFileTypeIcon() {
    switch (_selectedType) {
      case 'image':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildTypeButton({
    required IconData icon,
    required String label,
    required String type,
  }) {
    bool isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedFile = null;
          _selectedPlatformFile = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualitySlider() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quality',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_quality%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: _quality.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              activeColor: Colors.deepPurple,
              onChanged: (value) {
                setState(() => _quality = value.toInt());
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Smaller file', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('Better quality', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoQualitySelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quality Selection
            const Text(
              'Quality',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQualityChip('Low', 'low', Icons.speed),
                const SizedBox(width: 8),
                _buildQualityChip('Medium', 'medium', Icons.tune),
                const SizedBox(width: 8),
                _buildQualityChip('High', 'high', Icons.hd),
              ],
            ),
            const SizedBox(height: 20),
            
            // Resolution Selection
            const Text(
              'Resolution (Optional)',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildResolutionChip('Original', null),
                const SizedBox(width: 8),
                _buildResolutionChip('480p', '480p'),
                const SizedBox(width: 8),
                _buildResolutionChip('720p', '720p'),
                const SizedBox(width: 8),
                _buildResolutionChip('1080p', '1080p'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityChip(String label, String value, IconData icon) {
    bool isSelected = _videoQuality == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _videoQuality = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResolutionChip(String label, String? value) {
    bool isSelected = _videoResolution == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _videoResolution = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}