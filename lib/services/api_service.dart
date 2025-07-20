import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/tool_model.dart';
import '../models/video_model.dart';
import '../models/quiz_model.dart';
import '../models/user_model.dart';

/// Response model untuk API
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T? data) {
    return ApiResponse<T>(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      data: data,
      meta: json['meta'],
    );
  }
}

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HTTP Client dengan timeout
  static final http.Client _client = http.Client();

  // Authentication token and user data
  static String? _authToken;
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  /// Initialize and load saved token
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
  }

  /// Set authentication token and save to local storage
  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Clear authentication token from memory and local storage
  static Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
  }
  
  /// Save user data to local storage
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(userData));
  }
  
  /// Get saved user data from local storage
  static Future<Map<String, dynamic>?> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }
  
  /// Clear saved user data
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }

  /// Get current auth token
  static String? get authToken => _authToken;

  /// Check if user is authenticated
  static bool get isAuthenticated => _authToken != null;

  // Helper method untuk handle HTTP requests
  /// Make multipart request for file uploads
  static Future<Map<String, dynamic>> _makeMultipartRequest(
    String method,
    String endpoint, {
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, String>? additionalHeaders,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(endpoint));
      final request = http.MultipartRequest(method.toUpperCase(), url);
      
      // Add headers
      request.headers.addAll({
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        if (additionalHeaders != null) ...additionalHeaders,
      });
      
      // Check authentication
      if (requiresAuth && _authToken == null) {
        throw Exception('Authentication required but no token provided');
      }
      
      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          final file = entry.value;
          final multipartFile = await http.MultipartFile.fromPath(
            entry.key,
            file.path,
            filename: file.path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }
      
      final streamedResponse = await request.send()
          .timeout(Duration(seconds: ApiConfig.timeoutDuration));
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          uri: url,
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(endpoint));
      final headers = {
        ...ApiConfig.defaultHeaders,
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        if (additionalHeaders != null) ...additionalHeaders,
      };

      // Check if endpoint requires authentication
      if (requiresAuth && _authToken == null) {
        throw Exception('Authentication required but no token provided');
      }

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client
              .get(url, headers: headers)
              .timeout(Duration(seconds: ApiConfig.timeoutDuration));
          break;
        case 'POST':
          response = await _client
              .post(
                url,
                headers: headers,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(Duration(seconds: ApiConfig.timeoutDuration));
          break;
        case 'PUT':
          response = await _client
              .put(
                url,
                headers: headers,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(Duration(seconds: ApiConfig.timeoutDuration));
          break;
        case 'DELETE':
          response = await _client
              .delete(url, headers: headers)
              .timeout(Duration(seconds: ApiConfig.timeoutDuration));
          break;
        default:
          throw Exception('HTTP method $method not supported');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          uri: url,
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== AUTHENTICATION API ====================

  /// Register user baru
  static Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? className,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          if (className != null) 'kelas': className,
        },
      );
      return ApiResponse.fromJson(response, response['data']);
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  /// Login user
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/login',
        body: {'email': email, 'password': password},
      );

      // Set token jika login berhasil
      if (response['token'] != null) {
        await setAuthToken(response['token']);
      }
      
      // Save user data if provided
      if (response['data'] != null && response['data']['user'] != null) {
        await saveUserData(response['data']['user']);
      }

      return ApiResponse.fromJson(response, response['data']);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  /// Logout user
  static Future<ApiResponse<void>> logout() async {
    try {
      final response = await _makeRequest(
        'POST',
        '/logout',
        requiresAuth: true,
      );

      // Clear token and user data setelah logout
      await clearAuthToken();

      return ApiResponse.fromJson(response, null);
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  /// Forgot password
  static Future<ApiResponse<void>> forgotPassword(String email) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/forgot-password',
        body: {'email': email},
      );
      return ApiResponse.fromJson(response, null);
    } catch (e) {
      throw Exception('Failed to send reset password email: $e');
    }
  }

  /// Reset password
  static Future<ApiResponse<void>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/reset-password',
        body: {
          'token': token,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return ApiResponse.fromJson(response, null);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  /// Get user profile
  static Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final response = await _makeRequest(
        'GET',
        '/profile',
        requiresAuth: true,
      );
      final userData = response['data'] ?? response['user'];
      return ApiResponse.fromJson(response, UserModel.fromMap(userData));
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Update user profile
  static Future<ApiResponse<UserModel>> updateProfile({
    String? name,
    String? className,
    File? profileImage,
  }) async {
    try {
      Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (className != null) body['class_name'] = className;

      // TODO: Handle file upload for profile image

      final response = await _makeRequest(
        'PUT',
        '/profile',
        body: body,
        requiresAuth: true,
      );
      final userData = response['data'] ?? response['user'];
      return ApiResponse.fromJson(response, UserModel.fromMap(userData));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Change password
  static Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _makeRequest(
        'PUT',
        '/change-password',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
        requiresAuth: true,
      );
      return ApiResponse.fromJson(response, null);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // ==================== TOOLS API ====================

  /// Mengambil semua data alat teknik dengan pagination dan search
  static Future<ApiResponse<List<ToolModel>>> getTools({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      String endpoint = ApiConfig.toolsEndpoint;
      List<String> queryParams = [];

      queryParams.add('page=$page');
      queryParams.add('per_page=$perPage');
      if (search != null && search.isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(search)}');
      }

      if (queryParams.isNotEmpty) {
        endpoint += '?' + queryParams.join('&');
      }

      final response = await _makeRequest('GET', endpoint, requiresAuth: true);
      final List<dynamic> toolsData =
          response['data'] ?? response['tools'] ?? [];
      final tools = toolsData.map((json) => ToolModel.fromMap(json)).toList();

      return ApiResponse.fromJson(response, tools);
    } catch (e) {
      throw Exception('Failed to fetch tools: $e');
    }
  }

  /// Mengambil detail alat teknik berdasarkan ID
  static Future<ApiResponse<ToolModel>> getToolById(String id) async {
    try {
      final response = await _makeRequest(
        'GET',
        '${ApiConfig.toolsEndpoint}/$id',
        requiresAuth: true,
      );
      final toolData = response['data'] ?? response['tool'];
      return ApiResponse.fromJson(response, ToolModel.fromMap(toolData));
    } catch (e) {
      throw Exception('Failed to fetch tool details: $e');
    }
  }

  /// Menambah alat teknik baru dengan upload gambar
  static Future<ApiResponse<ToolModel>> createTool(ToolModel tool, {File? imageFile}) async {
    try {
      Map<String, dynamic> response;
      
      if (imageFile != null) {
        // Upload dengan multipart form data jika ada gambar
        response = await _makeMultipartRequest(
          'POST',
          ApiConfig.toolsEndpoint,
          fields: {
            'nama': tool.name,
            'deskripsi': tool.description,
            'fungsi': tool.function,
            'url_video': tool.videoUrl,
            'file_pdf': tool.pdfUrl,
          },
          files: {'gambar': imageFile},
          requiresAuth: true,
        );
      } else {
        // Upload tanpa gambar menggunakan JSON biasa
        response = await _makeRequest(
          'POST',
          ApiConfig.toolsEndpoint,
          body: tool.toMap(),
          requiresAuth: true,
        );
      }
      
      final toolData = response['data'] ?? response['tool'];
      return ApiResponse.fromJson(response, ToolModel.fromMap(toolData));
    } catch (e) {
      throw Exception('Failed to create tool: $e');
    }
  }

  /// Update alat teknik
  static Future<ApiResponse<ToolModel>> updateTool(
    String id,
    ToolModel tool,
  ) async {
    try {
      final response = await _makeRequest(
        'PUT',
        '${ApiConfig.toolsEndpoint}/$id',
        body: tool.toMap(),
        requiresAuth: true,
      );
      final toolData = response['data'] ?? response['tool'];
      return ApiResponse.fromJson(response, ToolModel.fromMap(toolData));
    } catch (e) {
      throw Exception('Failed to update tool: $e');
    }
  }

  /// Hapus alat teknik
  static Future<ApiResponse<void>> deleteTool(String id) async {
    try {
      final response = await _makeRequest(
        'DELETE',
        '${ApiConfig.toolsEndpoint}/$id',
        requiresAuth: true,
      );
      return ApiResponse.fromJson(response, null);
    } catch (e) {
      throw Exception('Failed to delete tool: $e');
    }
  }

  /// Mencari alat teknik berdasarkan query (deprecated - gunakan getTools dengan search parameter)
  static Future<List<ToolModel>> searchTools(String query) async {
    try {
      final result = await getTools(search: query);
      return result.data ?? [];
    } catch (e) {
      throw Exception('Failed to search tools: $e');
    }
  }

  // ==================== VIDEOS API ====================

  /// Mengambil semua data video pembelajaran dengan pagination dan search
  static Future<ApiResponse<List<VideoModel>>> getVideos({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      String endpoint = ApiConfig.videosEndpoint;
      List<String> queryParams = [];

      queryParams.add('page=$page');
      queryParams.add('per_page=$perPage');
      if (search != null && search.isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(search)}');
      }

      if (queryParams.isNotEmpty) {
        endpoint += '?' + queryParams.join('&');
      }

      final response = await _makeRequest('GET', endpoint, requiresAuth: true);
      final List<dynamic> videosData =
          response['data'] ?? response['videos'] ?? [];
      final videos = videosData
          .map((json) => VideoModel.fromMap(json))
          .toList();

      return ApiResponse.fromJson(response, videos);
    } catch (e) {
      throw Exception('Failed to fetch videos: $e');
    }
  }

  /// Mengambil detail video berdasarkan ID
  static Future<ApiResponse<VideoModel>> getVideoById(String id) async {
    try {
      final response = await _makeRequest(
        'GET',
        '${ApiConfig.videosEndpoint}/$id',
        requiresAuth: true,
      );
      final videoData = response['data'] ?? response['video'];
      return ApiResponse.fromJson(response, VideoModel.fromMap(videoData));
    } catch (e) {
      throw Exception('Failed to fetch video details: $e');
    }
  }

  // ==================== QUIZ API ====================

  /// Mengambil soal kuis berdasarkan level
  static Future<ApiResponse<List<QuizQuestion>>> getQuizQuestions({
    required String level,
  }) async {
    try {
      final response = await _makeRequest(
        'GET',
        '/quizzes?level=$level',
        requiresAuth: true,
      );
      final List<dynamic> questionsData =
          response['data'] ?? response['questions'] ?? [];
      final questions = questionsData
          .map((json) => QuizQuestion.fromMap(json))
          .toList();

      return ApiResponse.fromJson(response, questions);
    } catch (e) {
      throw Exception('Failed to fetch quiz questions: $e');
    }
  }

  /// Submit jawaban kuis
  static Future<ApiResponse<Map<String, dynamic>>> submitQuizAnswers({
    required List<Map<String, dynamic>> answers,
    required String level,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/quizzes/submit',
        body: {'answers': answers, 'level': level},
        requiresAuth: true,
      );
      return ApiResponse.fromJson(response, response['data'] ?? response);
    } catch (e) {
      throw Exception('Failed to submit quiz answers: $e');
    }
  }

  // ==================== SCORES API ====================

  /// Mengambil history skor user
  static Future<ApiResponse<List<Map<String, dynamic>>>> getScores({
    String? level,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      String endpoint = '/scores';
      List<String> queryParams = [];

      queryParams.add('page=$page');
      queryParams.add('per_page=$perPage');
      if (level != null && level.isNotEmpty) {
        queryParams.add('level=$level');
      }

      if (queryParams.isNotEmpty) {
        endpoint += '?' + queryParams.join('&');
      }

      final response = await _makeRequest('GET', endpoint, requiresAuth: true);
      final List<dynamic> scoresData =
          response['data'] ?? response['scores'] ?? [];
      final scores = scoresData.cast<Map<String, dynamic>>();

      return ApiResponse.fromJson(response, scores);
    } catch (e) {
      throw Exception('Failed to fetch scores: $e');
    }
  }

  /// Mengambil detail skor berdasarkan ID
  static Future<ApiResponse<Map<String, dynamic>>> getScoreById(
    String id,
  ) async {
    try {
      final response = await _makeRequest(
        'GET',
        '/scores/$id',
        requiresAuth: true,
      );
      final scoreData = response['data'] ?? response['score'];
      return ApiResponse.fromJson(response, scoreData);
    } catch (e) {
      throw Exception('Failed to fetch score details: $e');
    }
  }

  /// Simpan skor manual
  static Future<ApiResponse<Map<String, dynamic>>> saveScore({
    required String level,
    required int skor,
    required int totalSoal,
    required int benar,
    required int salah,
    DateTime? tanggal,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/scores',
        body: {
          'level': level,
          'skor': skor,
          'total_soal': totalSoal,
          'benar': benar,
          'salah': salah,
          'tanggal': (tanggal ?? DateTime.now()).toIso8601String(),
        },
        requiresAuth: true,
      );
      return ApiResponse.fromJson(response, response['data'] ?? response);
    } catch (e) {
      throw Exception('Failed to save score: $e');
    }
  }

  // ==================== DASHBOARD & STATISTICS API ====================

  /// Mengambil statistik dashboard user
  static Future<ApiResponse<Map<String, dynamic>>> getDashboardStats() async {
    try {
      final response = await _makeRequest(
        'GET',
        '/dashboard/stats',
        requiresAuth: true,
      );
      return ApiResponse.fromJson(response, response['data'] ?? response);
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  /// Mengambil leaderboard users
  static Future<ApiResponse<List<Map<String, dynamic>>>> getLeaderboard({
    String? level,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      String endpoint = '/leaderboard';
      List<String> queryParams = [];

      queryParams.add('page=$page');
      queryParams.add('per_page=$perPage');
      if (level != null && level.isNotEmpty) {
        queryParams.add('level=$level');
      }

      if (queryParams.isNotEmpty) {
        endpoint += '?' + queryParams.join('&');
      }

      final response = await _makeRequest('GET', endpoint, requiresAuth: true);
      final List<dynamic> leaderboardData =
          response['data'] ?? response['leaderboard'] ?? [];
      final leaderboard = leaderboardData.cast<Map<String, dynamic>>();

      return ApiResponse.fromJson(response, leaderboard);
    } catch (e) {
      throw Exception('Failed to fetch leaderboard: $e');
    }
  }

  /// Mengambil statistik aplikasi
  static Future<ApiResponse<Map<String, dynamic>>> getAppStats() async {
    try {
      final response = await _makeRequest(
        'GET',
        '/app/stats',
        requiresAuth: true,
      );
      return ApiResponse.fromJson(response, response['data'] ?? response);
    } catch (e) {
      throw Exception('Failed to fetch app stats: $e');
    }
  }

  // ==================== BACKWARD COMPATIBILITY METHODS ====================

  /// Backward compatibility untuk DataService - getTools tanpa pagination
  static Future<List<ToolModel>> getToolsLegacy() async {
    try {
      final result = await getTools(
        perPage: 100,
      ); // Get more items for legacy support
      return result.data ?? [];
    } catch (e) {
      throw Exception('Failed to fetch tools: $e');
    }
  }

  /// Backward compatibility untuk DataService - getVideos tanpa pagination
  static Future<List<VideoModel>> getVideosLegacy() async {
    try {
      final result = await getVideos(
        perPage: 100,
      ); // Get more items for legacy support
      return result.data ?? [];
    } catch (e) {
      throw Exception('Failed to fetch videos: $e');
    }
  }

  /// Backward compatibility untuk DataService - getQuizQuestions dengan QuizLevel
  static Future<List<QuizQuestion>> getQuizQuestionsLegacy(
    QuizLevel level,
  ) async {
    try {
      final levelString = level.toString().split('.').last;
      final result = await getQuizQuestions(level: levelString);
      return result.data ?? [];
    } catch (e) {
      throw Exception('Failed to fetch quiz questions: $e');
    }
  }

  /// Backward compatibility untuk DataService - submitQuizAnswers dengan QuizLevel
  static Future<Map<String, dynamic>?> submitQuizAnswersLegacy({
    required String userId,
    required List<Map<String, dynamic>> answers,
    required QuizLevel level,
  }) async {
    try {
      final levelString = level.toString().split('.').last;
      final result = await submitQuizAnswers(
        answers: answers,
        level: levelString,
      );
      return result.data;
    } catch (e) {
      return null;
    }
  }

  /// Backward compatibility untuk DataService - getUserById
  static Future<UserModel> getUserById(String id) async {
    try {
      final result = await getProfile(); // Assuming current user profile
      return result.data!;
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  /// Backward compatibility untuk DataService - updateUserProgress
  static Future<UserModel> updateUserProgress(
    String userId, {
    int? completedQuizzes,
    int? totalQuizzes,
  }) async {
    try {
      // This would need to be implemented based on actual backend endpoint
      // For now, return current user profile
      final result = await getProfile();
      return result.data!;
    } catch (e) {
      throw Exception('Failed to update user progress: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Test koneksi ke server
  static Future<bool> testConnection() async {
    try {
      // Coba akses endpoint tools tanpa auth untuk test koneksi
      final url = Uri.parse(ApiConfig.getFullUrl('/tools'));
      final response = await _client
          .get(url, headers: ApiConfig.defaultHeaders)
          .timeout(Duration(seconds: 5));

      // Jika server merespons (bahkan dengan redirect/error), berarti server hidup
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }

  /// Upload gambar (untuk fitur tambah alat)
  static Future<String> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.getFullUrl('/upload/image')),
      );

      request.headers.addAll(ApiConfig.defaultHeaders);
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(
        Duration(seconds: ApiConfig.timeoutDuration),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data']['url'] ?? responseData['url'];
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Dispose HTTP client
  static void dispose() {
    _client.close();
  }
}
