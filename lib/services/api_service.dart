import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/tool_model.dart';
import '../models/video_model.dart';
import '../models/quiz_model.dart';
import '../models/user_model.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HTTP Client dengan timeout
  static final http.Client _client = http.Client();

  // Helper method untuk handle HTTP requests
  static Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(endpoint));
      final headers = {
        ...ApiConfig.defaultHeaders,
        if (additionalHeaders != null) ...additionalHeaders,
      };

      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(url, headers: headers)
              .timeout(Duration(seconds: ApiConfig.timeoutDuration));
          break;
        case 'POST':
          response = await _client.post(
            url,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(Duration(seconds: ApiConfig.timeoutDuration));
          break;
        case 'PUT':
          response = await _client.put(
            url,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(Duration(seconds: ApiConfig.timeoutDuration));
          break;
        case 'DELETE':
          response = await _client.delete(url, headers: headers)
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

  // ==================== TOOLS API ====================
  
  /// Mengambil semua data alat teknik
  static Future<List<ToolModel>> getTools() async {
    try {
      final response = await _makeRequest('GET', ApiConfig.toolsEndpoint);
      final List<dynamic> toolsData = response['data'] ?? response['tools'] ?? [];
      return toolsData.map((json) => ToolModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tools: $e');
    }
  }

  /// Mengambil detail alat teknik berdasarkan ID
  static Future<ToolModel> getToolById(String id) async {
    try {
      final response = await _makeRequest('GET', '${ApiConfig.toolsEndpoint}/$id');
      final toolData = response['data'] ?? response['tool'];
      return ToolModel.fromMap(toolData);
    } catch (e) {
      throw Exception('Failed to fetch tool details: $e');
    }
  }

  /// Menambah alat teknik baru
  static Future<ToolModel> createTool(ToolModel tool) async {
    try {
      final response = await _makeRequest(
        'POST',
        ApiConfig.toolsEndpoint,
        body: tool.toMap(),
      );
      final toolData = response['data'] ?? response['tool'];
      return ToolModel.fromMap(toolData);
    } catch (e) {
      throw Exception('Failed to create tool: $e');
    }
  }

  /// Mencari alat teknik berdasarkan query
  static Future<List<ToolModel>> searchTools(String query) async {
    try {
      final response = await _makeRequest(
        'GET',
        '${ApiConfig.toolsEndpoint}/search?q=$query',
      );
      final List<dynamic> toolsData = response['data'] ?? response['tools'] ?? [];
      return toolsData.map((json) => ToolModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Failed to search tools: $e');
    }
  }

  // ==================== VIDEOS API ====================
  
  /// Mengambil semua data video pembelajaran
  static Future<List<VideoModel>> getVideos() async {
    try {
      final response = await _makeRequest('GET', ApiConfig.videosEndpoint);
      final List<dynamic> videosData = response['data'] ?? response['videos'] ?? [];
      return videosData.map((json) => VideoModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch videos: $e');
    }
  }

  /// Mengambil video berdasarkan kategori
  static Future<List<VideoModel>> getVideosByCategory(String category) async {
    try {
      final response = await _makeRequest(
        'GET',
        '${ApiConfig.videosEndpoint}/category/$category',
      );
      final List<dynamic> videosData = response['data'] ?? response['videos'] ?? [];
      return videosData.map((json) => VideoModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch videos by category: $e');
    }
  }

  // ==================== QUIZ API ====================
  
  /// Mengambil soal kuis berdasarkan level
  static Future<List<QuizQuestion>> getQuizQuestions(QuizLevel level) async {
    try {
      final levelString = level.toString().split('.').last;
      final response = await _makeRequest(
        'GET',
        '${ApiConfig.quizEndpoint}/questions?level=$levelString',
      );
      final List<dynamic> questionsData = response['data'] ?? response['questions'] ?? [];
      return questionsData.map((json) => QuizQuestion.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch quiz questions: $e');
    }
  }

  /// Submit jawaban kuis
  static Future<Map<String, dynamic>> submitQuizAnswers({
    required String userId,
    required List<Map<String, dynamic>> answers,
    required QuizLevel level,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        '${ApiConfig.quizEndpoint}/submit',
        body: {
          'user_id': userId,
          'answers': answers,
          'level': level.toString().split('.').last,
        },
      );
      return response['data'] ?? response;
    } catch (e) {
      throw Exception('Failed to submit quiz answers: $e');
    }
  }

  // ==================== USER API ====================
  
  /// Mengambil data user berdasarkan ID
  static Future<UserModel> getUserById(String id) async {
    try {
      final response = await _makeRequest('GET', '${ApiConfig.userEndpoint}/$id');
      final userData = response['data'] ?? response['user'];
      return UserModel.fromMap(userData);
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  /// Update progress user
  static Future<UserModel> updateUserProgress(String userId, {
    int? completedQuizzes,
    int? totalQuizzes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (completedQuizzes != null) body['completed_quizzes'] = completedQuizzes;
      if (totalQuizzes != null) body['total_quizzes'] = totalQuizzes;
      
      final response = await _makeRequest(
        'PUT',
        '${ApiConfig.userEndpoint}/$userId/progress',
        body: body,
      );
      final userData = response['data'] ?? response['user'];
      return UserModel.fromMap(userData);
    } catch (e) {
      throw Exception('Failed to update user progress: $e');
    }
  }

  // ==================== UTILITY METHODS ====================
  
  /// Test koneksi ke server
  static Future<bool> testConnection() async {
    try {
      final response = await _makeRequest('GET', '/test');
      return response['message'] != null;
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
      
      final streamedResponse = await request.send()
          .timeout(Duration(seconds: ApiConfig.timeoutDuration));
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