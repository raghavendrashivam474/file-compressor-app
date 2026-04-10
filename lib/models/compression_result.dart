class CompressionResult {
  final bool success;
  final String outputPath;
  final String outputFilename;
  final double originalSizeMb;
  final double compressedSizeMb;
  final String compressionRatio;
  final String message;

  CompressionResult({
    required this.success,
    required this.outputPath,
    required this.outputFilename,
    required this.originalSizeMb,
    required this.compressedSizeMb,
    required this.compressionRatio,
    required this.message,
  });

  factory CompressionResult.fromJson(Map<String, dynamic> json) {
    return CompressionResult(
      success: json['success'] ?? false,
      outputPath: json['output_path'] ?? '',
      outputFilename: json['output_filename'] ?? '',
      originalSizeMb: (json['original_size_mb'] ?? 0).toDouble(),
      compressedSizeMb: (json['compressed_size_mb'] ?? 0).toDouble(),
      compressionRatio: json['compression_ratio'] ?? '0%',
      message: json['message'] ?? '',
    );
  }
}