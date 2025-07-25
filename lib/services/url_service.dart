import '../config/api_config.dart';

class UrlService {
  // Private constructor for singleton pattern
  UrlService._internal();
  static final UrlService _instance = UrlService._internal();
  factory UrlService() => _instance;

  // Dynamic base URL configuration
  static String get baseUrl {
    // Extract base URL from API config and remove '/api' suffix
    String apiBaseUrl = ApiConfig.baseUrl;
    if (apiBaseUrl.endsWith('/api')) {
      return apiBaseUrl.substring(0, apiBaseUrl.length - 4);
    }
    return apiBaseUrl;
  }

  // Validate if URL is properly formatted
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Construct image URL with proper validation
  static String constructImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return getPlaceholderImageUrl('No Image');
    }

    // If it's already a full URL, validate and return
    if (imagePath.startsWith('http')) {
      return isValidUrl(imagePath)
          ? imagePath
          : getPlaceholderImageUrl('Invalid URL');
    }

    // Clean up any duplicate 'tools/' in the path first
    String cleanPath = imagePath;
    while (cleanPath.contains('/')) {}

    // Construct URL with correct Laravel storage path
    String constructedUrl;
    if (cleanPath.startsWith('/storage/')) {
      // If path already contains '/storage/', use it as is
      constructedUrl = '$baseUrl$cleanPath';
    } else if (cleanPath.startsWith('/')) {
      // If path starts with /, use it as is
      constructedUrl = '$baseUrl$cleanPath';
    } else {
      // For relative paths, construct proper storage URL
      constructedUrl = '$baseUrl/storage/$cleanPath';
    }

    return isValidUrl(constructedUrl)
        ? constructedUrl
        : getPlaceholderImageUrl('Construction Failed');
  }

  // Construct PDF URL with proper validation
  static String constructPdfUrl(String? pdfPath) {
    if (pdfPath == null || pdfPath.isEmpty) {
      return '';
    }

    // If it's already a full URL, validate and return
    if (pdfPath.startsWith('http')) {
      return isValidUrl(pdfPath) ? pdfPath : '';
    }

    // Construct URL with correct Laravel storage path
    String constructedUrl;
    if (pdfPath.startsWith('/storage/')) {
      // If path already contains '/storage/', use it as is
      constructedUrl = '$baseUrl$pdfPath';
    } else if (pdfPath.startsWith('/')) {
      // If path starts with /, use it as is
      constructedUrl = '$baseUrl$pdfPath';
    } else if (pdfPath.startsWith('pdfs/') || pdfPath.startsWith('manuals/')) {
      // If path already contains 'pdfs/' or 'manuals/' prefix, check for duplicates
      if (pdfPath.contains('pdfs/pdfs/') ||
          pdfPath.contains('manuals/manuals/')) {
        // Remove duplicate prefix
        String cleanPath = pdfPath
            .replaceFirst('pdfs/pdfs/', 'pdfs/')
            .replaceFirst('manuals/manuals/', 'manuals/');
        constructedUrl = '$baseUrl/storage/$cleanPath';
      } else {
        constructedUrl = '$baseUrl/storage/$pdfPath';
      }
    } else {
      // For relative paths without prefix, construct proper storage URL
      constructedUrl = '$baseUrl/storage/pdfs/$pdfPath';
    }

    return isValidUrl(constructedUrl) ? constructedUrl : '';
  }

  // Generate placeholder image URL
  static String getPlaceholderImageUrl(
    String text, {
    int width = 400,
    int height = 300,
  }) {
    final encodedText = Uri.encodeComponent(
      text.length > 20 ? '${text.substring(0, 20)}...' : text,
    );
    return 'https://via.placeholder.com/${width}x$height/E3F2FD/1976D2?text=$encodedText';
  }

  // Get fallback image URL for tools
  static String getToolPlaceholderUrl(String toolName) {
    return getPlaceholderImageUrl(toolName);
  }

  // Debug URL information
  static Map<String, dynamic> getUrlDebugInfo(
    String? originalPath,
    String constructedUrl,
  ) {
    return {
      'originalPath': originalPath,
      'constructedUrl': constructedUrl,
      'baseUrl': baseUrl,
      'isNgrokUrl': isNgrokUrl(constructedUrl),
      'isValidUrl': isValidUrl(constructedUrl),
    };
  }

  // Test URL construction with various scenarios
  static void testUrlConstruction() {
    print('=== URL CONSTRUCTION TEST ===');

    // Test cases for image URLs
    List<String> testImagePaths = [
      'tools/yW2mL8eyFnISAkmUv1rPwyssS6wPuFxXFD2cjibM.jpg',
      'tools/yW2mL8eyFnISAkmUv1rPwyssS6wPuFxXFD2cjibM.jpg',
      'yW2mL8eyFnISAkmUv1rPwyssS6wPuFxXFD2cjibM.jpg',
      '/storage/tools/yW2mL8eyFnISAkmUv1rPwyssS6wPuFxXFD2cjibM.jpg',
    ];

    for (String path in testImagePaths) {
      String result = constructImageUrl(path);
      print('Input: $path');
      print('Output: $result');
      print('---');
    }
  }

  // Check if URL is an ngrok URL
  static bool isNgrokUrl(String url) {
    return url.contains('ngrok') || url.contains('ngrok-free.app');
  }

  // Get appropriate headers for ngrok requests
  static Map<String, String> getNgrokHeaders() {
    return Map<String, String>.from(ApiConfig.ngrokHeaders);
  }

  // Get headers for image requests
  static Map<String, String> getImageHeaders(String url) {
    Map<String, String> headers = {
      'Accept': 'image/*',
      'User-Agent': 'Flutter-App/1.0',
    };

    if (isNgrokUrl(url)) {
      headers.addAll(getNgrokHeaders());
    }

    return headers;
  }

  // Get headers for PDF requests
  static Map<String, String> getPdfHeaders(String url) {
    Map<String, String> headers = {
      'Accept': 'application/pdf',
      'User-Agent': 'Flutter-App/1.0',
    };

    if (isNgrokUrl(url)) {
      headers.addAll(getNgrokHeaders());
    }

    return headers;
  }
}
