// import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../services/url_service.dart';

class ApiService {
  late Dio _dio;
  String? _token;

  Dio get dio => _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(seconds: ApiConfig.timeoutDuration),
        receiveTimeout: Duration(
          seconds: ApiConfig.timeoutDuration * 2,
        ), // Longer for large responses
        sendTimeout: Duration(seconds: ApiConfig.timeoutDuration),
        headers: _getEnhancedHeaders(),
      ),
    );

    _setupInterceptors();
  }

  // Get enhanced headers with ngrok support
  Map<String, String> _getEnhancedHeaders() {
    Map<String, String> headers = Map.from(ApiConfig.defaultHeaders);

    // Add ngrok-specific headers if using ngrok
    if (UrlService.isNgrokUrl(ApiConfig.baseUrl)) {
      headers.addAll(UrlService.getNgrokHeaders());
    }

    // Add additional headers for better compatibility
    headers.addAll({
      'User-Agent': 'Flutter-App/1.0',
      'Cache-Control': 'no-cache',
    });

    return headers;
  }

  void _setupInterceptors() {
    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false, // Don't log request body to avoid sensitive data
        responseBody: false, // Don't log response body to reduce noise
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => print('API Service: $obj'),
      ),
    );

    // Add retry interceptor for network issues
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }

          // Ensure ngrok headers are present for ngrok URLs
          if (UrlService.isNgrokUrl(options.uri.toString())) {
            options.headers.addAll(UrlService.getNgrokHeaders());
          }

          handler.next(options);
        },
        onError: (error, handler) {
          print('API Service Error: ${error.message}');
          print('Status Code: ${error.response?.statusCode}');
          print('URL: ${error.requestOptions.uri}');

          // Handle common errors
          if (error.response?.statusCode == 401) {
            // Token expired, logout user
            _clearToken();
          }

          // Retry logic for network errors
          // if (_shouldRetry(error)) {
          //   return _retryRequest(error, handler);
          // }

          handler.next(error);
        },
      ),
    );
  }

  // Check if request should be retried
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  // Retry request with exponential backoff
  Future<void> _retryRequest(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    const maxRetries = 3;
    const baseDelay = Duration(seconds: 1);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      await Future.delayed(Duration(seconds: baseDelay.inSeconds * attempt));

      try {
        print('API Service: Retrying request (attempt $attempt/$maxRetries)');
        final response = await _dio.fetch(error.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        if (attempt == maxRetries) {
          handler.next(error);
          return;
        }
      }
    }
  }

  void setToken(String token) {
    _token = token;
  }

  void _clearToken() {
    _token = null;
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String kelas,
    required String password,
    required String passwordConfirmation,
    required String phone,
    String? bio,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'kelas': kelas,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone,
      };

      // Add bio if provided
      if (bio != null && bio.isNotEmpty) {
        data['bio'] = bio;
      }

      final response = await _dio.post('/auth/register', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/forgot-password',
        data: {'email': email},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
      _clearToken();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Profile endpoints
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String nama,
    required String kelas,
    File? profileImage,
  }) async {
    try {
      FormData formData = FormData.fromMap({'nama': nama, 'kelas': kelas});

      if (profileImage != null) {
        formData.files.add(
          MapEntry(
            'profile_image',
            await MultipartFile.fromFile(profileImage.path),
          ),
        );
      }

      final response = await _dio.put('/auth/profile', data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.put(
        '/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'password_confirmation': passwordConfirmation,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Tools endpoints
  Future<Map<String, dynamic>> getTools({
    String? search,
    int? categoryId,
    bool? featured,
    bool? active,
    bool? hasVideo,
    bool? hasPdf,
    String? sort,
    int perPage = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'per_page': perPage};

      if (search != null) queryParams['search'] = search;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (featured != null) queryParams['featured'] = featured;
      if (active != null) queryParams['active'] = active;
      if (hasVideo != null) queryParams['has_video'] = hasVideo;
      if (hasPdf != null) queryParams['has_pdf'] = hasPdf;
      if (sort != null) queryParams['sort'] = sort;

      final response = await _dio.get('/tools', queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTool(int id) async {
    try {
      final response = await _dio.get('/tools/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Tools by category
  Future<Map<String, dynamic>> getToolsByCategory(int categoryId) async {
    try {
      final response = await _dio.get('/tools/category/$categoryId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> incrementToolView(int id) async {
    try {
      await _dio.post('/tools/$id/view');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get Featured Tools
  Future<Map<String, dynamic>> getFeaturedTools() async {
    try {
      final response = await _dio.get('/tools/featured');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get Popular Tools
  Future<Map<String, dynamic>> getPopularTools() async {
    try {
      final response = await _dio.get('/tools/popular');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Toggle Favorite
  Future<Map<String, dynamic>> toggleFavorite(int toolId) async {
    try {
      final response = await _dio.post('/favorites/toggle/$toolId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get user favorites
  Future<Map<String, dynamic>> getFavorites() async {
    try {
      final response = await _dio.get('/favorites');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Check if tool is favorited
  Future<Map<String, dynamic>> checkFavorite(int toolId) async {
    try {
      final response = await _dio.get('/favorites/check/$toolId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Categories endpoints
  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCategory(int id) async {
    try {
      final response = await _dio.get('/categories/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Videos endpoints
  Future<Map<String, dynamic>> getVideos({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (search != null) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;

      final response = await _dio.get('/videos', queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getVideo(int id) async {
    try {
      final response = await _dio.get('/videos/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get video by ID (alias for compatibility)
  Future<Map<String, dynamic>> getVideoById(int id) async {
    try {
      final response = await _dio.get('/videos/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Videos by category
  Future<Map<String, dynamic>> getVideosByCategory(int categoryId) async {
    try {
      final response = await _dio.get('/videos/category/$categoryId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Quiz endpoints
  // Get quiz levels
  Future<Map<String, dynamic>> getQuizLevels() async {
    try {
      final response = await _dio.get('/quiz/levels');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get quiz by level
  Future<Map<String, dynamic>> getQuizByLevel(String level) async {
    try {
      final response = await _dio.get('/quiz/$level');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get quiz questions by level
  Future<Map<String, dynamic>> getQuizQuestions(String level) async {
    try {
      final response = await _dio.get('/quiz/$level/questions');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get quizzes with parameters (for compatibility)
  Future<Map<String, dynamic>> getQuizzes({
    required String level,
    int? page,
    int? limit,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dio.get(
        '/quiz/$level',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Submit quiz answers
  Future<Map<String, dynamic>> submitQuizAnswers(
    Map<String, dynamic> answers,
  ) async {
    try {
      final response = await _dio.post('/quiz/submit', data: answers);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get quiz history
  Future<Map<String, dynamic>> getQuizHistory() async {
    try {
      final response = await _dio.get('/quiz/history');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Scores endpoints
  // Get my scores
  Future<Map<String, dynamic>> getMyScores() async {
    try {
      final response = await _dio.get('/scores/my-scores');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Submit quiz (for compatibility)
  Future<Map<String, dynamic>> submitQuiz({
    required String level,
    required int skor,
    required int totalSoal,
    required int benar,
    int? timeSpent,
  }) async {
    try {
      final data = {
        'level': level,
        'skor': skor,
        'total_soal': totalSoal,
        'benar': benar,
        'salah': totalSoal - benar,
        if (timeSpent != null) 'time_spent': timeSpent,
      };
      final response = await _dio.post('/quiz/submit', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get scores with pagination
  Future<Map<String, dynamic>> getScores({
    int? page,
    int? limit,
    String? level,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (level != null) queryParams['level'] = level;

      final response = await _dio.get(
        '/scores/my-scores',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get leaderboard with optional parameters
  Future<Map<String, dynamic>> getLeaderboard({
    String? level,
    int? limit,
  }) async {
    try {
      String endpoint = '/scores/leaderboard';
      Map<String, dynamic> queryParams = {};

      if (level != null && level != 'all') {
        endpoint = '/scores/leaderboard/$level';
      }

      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await _dio.get(endpoint, queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get leaderboard by level
  Future<Map<String, dynamic>> getLeaderboardByLevel(String level) async {
    try {
      final response = await _dio.get('/scores/leaderboard/$level');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Dashboard endpoints
  // Get dashboard stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/dashboard/stats');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get user stats
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _dio.get('/users/stats');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get recent activity
  Future<Map<String, dynamic>> getRecentActivity() async {
    try {
      final response = await _dio.get('/dashboard/recent-activity');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      String message = 'Terjadi kesalahan';
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        message = data['message'];
      }

      switch (statusCode) {
        case 400:
          return Exception('Bad Request: $message');
        case 401:
          return Exception('Unauthorized: $message');
        case 403:
          return Exception('Forbidden: $message');
        case 404:
          return Exception('Not Found: $message');
        case 422:
          return Exception('Validation Error: $message');
        case 500:
          return Exception('Server Error: $message');
        default:
          return Exception('HTTP $statusCode: $message');
      }
    } else {
      return Exception('Network Error: ${e.message}');
    }
  }

  Future getCurrentUser() async {}

  Future<void> updateVideoView(int videoId) async {
    try {
      await _dio.post('/videos/$videoId/views');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
