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

          // Handle retry logic if needed in the future

          handler.next(error);
        },
      ),
    );
  }

  void setToken(String token) {
    _token = token;
  }

  void _clearToken() {
    _token = null;
  }

  // User Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final token = data['data']['token'];
          final user = data['data']['user'];

          // Store token for future requests
          setToken(token);

          return {
            'success': true,
            'message': data['message'] ?? 'Login successful',
            'data': {
              'token': token,
              'user': user,
            },
          };
        }
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Login failed',
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? kelas,
    String? phone,
    String? bio,
  }) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          if (kelas != null) 'kelas': kelas,
          if (phone != null) 'phone': phone,
          if (bio != null) 'bio': bio,
        },
      );

      print('API Register Response Status: ${response.statusCode}');
      print('API Register Response Data: ${response.data}');

      if (response.statusCode == 201) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          // Safe extraction with null checks
          final responseData = data['data'];
          if (responseData != null &&
              responseData['user'] != null &&
              responseData['token'] != null) {
            return {
              'success': true,
              'message': data['message'] ?? 'Registration successful',
              'data': {
                'user': responseData['user'],
                'token': responseData['token'],
              },
            };
          } else {
            return {
              'success': false,
              'message': 'Data registrasi tidak lengkap dari server',
            };
          }
        }
      }

      // Handle non-201 status codes
      final errorMessage =
          response.data != null && response.data['message'] != null
          ? response.data['message']
          : 'Registration failed';

      return {'success': false, 'message': errorMessage};
    } on DioException catch (e) {
      print('API Register DioException: ${e.message}');
      print('API Register DioException Response: ${e.response?.data}');

      // Handle specific error responses
      if (e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        String errorMessage = 'Registration failed';

        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? errorMessage;
        }

        return {'success': false, 'message': errorMessage};
      }

      // Network or other errors
      final error = _handleError(e);
      return {
        'success': false,
        'message': error.toString().replaceFirst('Exception: ', ''),
      };
    } catch (e) {
      print('API Register Unexpected Error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga: ${e.toString()}',
      };
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

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post('/logout');
      _clearToken();

      return {
        'success': true,
        'message': response.data['message'] ?? 'Logout successful',
      };
    } on DioException catch (e) {
      _clearToken(); // Clear token even if request fails
      return {'success': false, 'message': 'Logout failed: ${e.message}'};
    }
  }

  // Profile endpoints
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/profile');
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

      final response = await _dio.put('/profile', data: formData);
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

  // Quiz endpoints
  // Get quiz by level
  Future<Map<String, dynamic>> getQuizByLevel(String level) async {
    try {
      final response = await _dio.get('/quizzes/$level');
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
        '/quizzes/$level',
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
      final response = await _dio.post('/quizzes/submit', data: answers);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get quiz history
  Future<Map<String, dynamic>> getQuizHistory() async {
    try {
      final response = await _dio.get('/quizzes/history/user');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get quiz stats
  Future<Map<String, dynamic>> getQuizStats() async {
    try {
      final response = await _dio.get('/quizzes/stats/user');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Scores endpoints
  // Get my scores
  Future<Map<String, dynamic>> getMyScores() async {
    try {
      final response = await _dio.get('/scores');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Store score
  Future<Map<String, dynamic>> storeScore(
    Map<String, dynamic> scoreData,
  ) async {
    try {
      final response = await _dio.post('/scores', data: scoreData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get score by ID
  Future<Map<String, dynamic>> getScore(int id) async {
    try {
      final response = await _dio.get('/scores/$id');
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
      final response = await _dio.post('/quizzes/submit', data: data);
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

      final response = await _dio.get('/scores', queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get leaderboard
  Future<Map<String, dynamic>> getLeaderboard({
    String? level,
    int? limit,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await _dio.get(
        '/leaderboard',
        queryParameters: queryParams,
      );
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

  // Get app stats
  Future<Map<String, dynamic>> getAppStats() async {
    try {
      final response = await _dio.get('/app/stats');
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

  // Get tools by category
  Future<Map<String, dynamic>> getToolsByCategory(int categoryId) async {
    try {
      final response = await _dio.get('/tools', queryParameters: {
        'category_id': categoryId,
        'per_page': 50, // Get more items for category view
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get quiz questions by level
  Future<Map<String, dynamic>> getQuizQuestions(String level) async {
    try {
      final response = await _dio.get('/quizzes/$level/questions');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update video view count
  Future<void> updateVideoView(int videoId) async {
    try {
      await _dio.post('/videos/$videoId/view');
    } on DioException catch (e) {
      // Don't throw error for view tracking, just log it
      print('Failed to update video view: ${e.message}');
    }
  }

  // Get video by ID
  Future<Map<String, dynamic>> getVideoById(int videoId) async {
    try {
      final response = await _dio.get('/videos/$videoId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get user stats
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _dio.get('/user/stats');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
