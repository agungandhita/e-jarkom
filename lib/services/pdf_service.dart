import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../services/url_service.dart';

class PdfService {
  // Singleton pattern
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  final Dio _dio = Dio();
  final Map<String, String> _downloadCache = {};
  final Map<String, double> _downloadProgress = {};

  // Initialize PDF service with proper configuration
  void initialize() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5), // Longer timeout for PDF downloads
      sendTimeout: const Duration(seconds: 30),
    );

    // Add interceptor for logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('PDF Service: Downloading ${options.uri}');
          handler.next(options);
        },
        onError: (error, handler) {
          print('PDF Service Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // Generate cache key for PDF URL
  String _generateCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  // Get cache directory for PDFs
  Future<Directory> _getCacheDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/pdf_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  // Check if PDF is cached
  Future<String?> _getCachedPdfPath(String url) async {
    final cacheKey = _generateCacheKey(url);
    if (_downloadCache.containsKey(cacheKey)) {
      final cachedPath = _downloadCache[cacheKey]!;
      if (await File(cachedPath).exists()) {
        return cachedPath;
      } else {
        // Remove invalid cache entry
        _downloadCache.remove(cacheKey);
      }
    }
    return null;
  }

  // Download PDF with progress tracking
  Future<PdfDownloadResult> downloadPdf({
    required String url,
    required String fileName,
    bool useCache = true,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Validate and construct URL
      final processedUrl = UrlService.constructPdfUrl(url);
      if (processedUrl.isEmpty || !UrlService.isValidUrl(processedUrl)) {
        return PdfDownloadResult.error('Invalid PDF URL: $url');
      }

      // Check cache first
      if (useCache) {
        final cachedPath = await _getCachedPdfPath(processedUrl);
        if (cachedPath != null) {
          print('PDF Service: Using cached PDF at $cachedPath');
          return PdfDownloadResult.success(cachedPath, fromCache: true);
        }
      }

      // Prepare download
      final cacheDir = await _getCacheDirectory();
      final cacheKey = _generateCacheKey(processedUrl);
      final filePath = '${cacheDir.path}/${cacheKey}_$fileName';

      // Set up headers
      final headers = UrlService.getPdfHeaders(processedUrl);

      // Download with progress tracking
      await _dio.download(
        processedUrl,
        filePath,
        options: Options(headers: headers),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _downloadProgress[cacheKey] = progress;
            onProgress?.call(progress);
          }
        },
      );

      // Verify download
      final file = File(filePath);
      if (!await file.exists()) {
        return PdfDownloadResult.error('Downloaded file does not exist');
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        await file.delete();
        return PdfDownloadResult.error('Downloaded file is empty');
      }

      // Cache the result
      _downloadCache[cacheKey] = filePath;
      _downloadProgress.remove(cacheKey);

      print('PDF Service: Successfully downloaded PDF to $filePath (${fileSize} bytes)');
      return PdfDownloadResult.success(filePath);
    } catch (e) {
      print('PDF Service: Download failed - $e');
      return PdfDownloadResult.error('Download failed: ${e.toString()}');
    }
  }

  // Get download progress for a URL
  double getDownloadProgress(String url) {
    final cacheKey = _generateCacheKey(url);
    return _downloadProgress[cacheKey] ?? 0.0;
  }

  // Check if PDF is currently downloading
  bool isDownloading(String url) {
    final cacheKey = _generateCacheKey(url);
    return _downloadProgress.containsKey(cacheKey);
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      _downloadCache.clear();
      _downloadProgress.clear();
      print('PDF Service: Cache cleared');
    } catch (e) {
      print('PDF Service: Failed to clear cache - $e');
    }
  }

  // Get cache size
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      print('PDF Service: Failed to calculate cache size - $e');
      return 0;
    }
  }

  // Get cache info
  Future<Map<String, dynamic>> getCacheInfo() async {
    final size = await getCacheSize();
    return {
      'cacheSize': size,
      'cacheSizeFormatted': _formatBytes(size),
      'cachedFiles': _downloadCache.length,
      'activeDownloads': _downloadProgress.length,
    };
  }

  // Format bytes to human readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Cancel download (if needed in future)
  void cancelDownload(String url) {
    final cacheKey = _generateCacheKey(url);
    _downloadProgress.remove(cacheKey);
  }
}

// Result class for PDF downloads
class PdfDownloadResult {
  final bool isSuccess;
  final String? filePath;
  final String? errorMessage;
  final bool fromCache;

  PdfDownloadResult._(
    this.isSuccess,
    this.filePath,
    this.errorMessage,
    this.fromCache,
  );

  factory PdfDownloadResult.success(String filePath, {bool fromCache = false}) {
    return PdfDownloadResult._(true, filePath, null, fromCache);
  }

  factory PdfDownloadResult.error(String errorMessage) {
    return PdfDownloadResult._(false, null, errorMessage, false);
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'PdfDownloadResult.success(filePath: $filePath, fromCache: $fromCache)';
    } else {
      return 'PdfDownloadResult.error(errorMessage: $errorMessage)';
    }
  }
}

// PDF download progress widget
class PdfDownloadProgress {
  final double progress;
  final bool isDownloading;
  final bool isCompleted;
  final String? errorMessage;

  PdfDownloadProgress({
    required this.progress,
    required this.isDownloading,
    required this.isCompleted,
    this.errorMessage,
  });

  factory PdfDownloadProgress.idle() {
    return PdfDownloadProgress(
      progress: 0.0,
      isDownloading: false,
      isCompleted: false,
    );
  }

  factory PdfDownloadProgress.downloading(double progress) {
    return PdfDownloadProgress(
      progress: progress,
      isDownloading: true,
      isCompleted: false,
    );
  }

  factory PdfDownloadProgress.completed() {
    return PdfDownloadProgress(
      progress: 1.0,
      isDownloading: false,
      isCompleted: true,
    );
  }

  factory PdfDownloadProgress.error(String errorMessage) {
    return PdfDownloadProgress(
      progress: 0.0,
      isDownloading: false,
      isCompleted: false,
      errorMessage: errorMessage,
    );
  }
}