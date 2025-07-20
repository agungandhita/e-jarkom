import 'package:flutter/foundation.dart';
import '../models/tool_model.dart';
import '../models/video_model.dart';
import '../models/quiz_model.dart';
import '../models/user_model.dart';
import '../data/dummy_data.dart';
import 'api_service.dart';

/// Service untuk mengelola data dari API atau fallback ke dummy data
class DataService {
  static bool _useApi = false;
  static bool _isConnected = false;

  /// Inisialisasi dan test koneksi ke server
  static Future<void> initialize() async {
    try {
      _isConnected = await ApiService.testConnection();
      _useApi = _isConnected;
      
      if (kDebugMode) {
        print('DataService initialized: API ${_useApi ? 'connected' : 'not available, using dummy data'}');
      }
    } catch (e) {
      _useApi = false;
      _isConnected = false;
      
      if (kDebugMode) {
        print('DataService: Failed to connect to API, using dummy data: $e');
      }
    }
  }

  /// Toggle antara API dan dummy data (untuk testing)
  static void toggleDataSource() {
    _useApi = !_useApi;
    if (kDebugMode) {
      print('DataService: Switched to ${_useApi ? 'API' : 'dummy'} data');
    }
  }

  /// Check status koneksi
  static bool get isConnected => _isConnected;
  static bool get isUsingApi => _useApi;

  // ==================== TOOLS DATA ====================
  
  /// Mengambil semua data alat teknik
  static Future<List<ToolModel>> getTools() async {
    if (_useApi) {
      try {
        return await ApiService.getTools();
      } catch (e) {
        if (kDebugMode) {
          print('DataService: API failed, fallback to dummy data: $e');
        }
        return DummyData.dummyTools;
      }
    }
    return DummyData.dummyTools;
  }

  /// Mengambil detail alat teknik berdasarkan ID
  static Future<ToolModel?> getToolById(String id) async {
    if (_useApi) {
      try {
        return await ApiService.getToolById(id);
      } catch (e) {
        if (kDebugMode) {
          print('DataService: API failed, fallback to dummy data: $e');
        }
        return DummyData.dummyTools.firstWhere(
          (tool) => tool.id == id,
          orElse: () => DummyData.dummyTools.first,
        );
      }
    }
    
    try {
      return DummyData.dummyTools.firstWhere((tool) => tool.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Menambah alat teknik baru
  static Future<ToolModel?> createTool(ToolModel tool) async {
    if (_useApi) {
      try {
        return await ApiService.createTool(tool);
      } catch (e) {
        if (kDebugMode) {
          print('DataService: Failed to create tool via API: $e');
        }
        return null;
      }
    }
    
    // Untuk dummy data, simulasi penambahan
    if (kDebugMode) {
      print('DataService: Tool created in dummy mode (not persisted)');
    }
    return tool;
  }

  /// Mencari alat teknik
  static Future<List<ToolModel>> searchTools(String query) async {
    if (_useApi) {
      try {
        return await ApiService.searchTools(query);
      } catch (e) {
        if (kDebugMode) {
          print('DataService: API search failed, fallback to local search: $e');
        }
      }
    }
    
    // Fallback ke pencarian lokal
    final tools = DummyData.dummyTools;
    if (query.isEmpty) return tools;
    
    return tools.where((tool) {
      return tool.name.toLowerCase().contains(query.toLowerCase()) ||
             tool.description.toLowerCase().contains(query.toLowerCase()) ||
             tool.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // ==================== VIDEOS DATA ====================
  
  /// Mengambil semua data video pembelajaran
  static Future<List<VideoModel>> getVideos() async {
    if (_useApi) {
      try {
        return await ApiService.getVideos();
      } catch (e) {
        if (kDebugMode) {
          print('DataService: API failed, fallback to dummy data: $e');
        }
        return DummyData.dummyVideos;
      }
    }
    return DummyData.dummyVideos;
  }

  /// Mengambil video berdasarkan kategori
  static Future<List<VideoModel>> getVideosByCategory(String category) async {
    if (_useApi) {
      try {
        return await ApiService.getVideosByCategory(category);
      } catch (e) {
        if (kDebugMode) {
          print('DataService: API failed, fallback to dummy data: $e');
        }
      }
    }
    
    // Fallback ke filter lokal
    return DummyData.dummyVideos
        .where((video) => video.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Mengambil video berdasarkan ID
  static Future<VideoModel?> getVideoById(String id) async {
    final videos = await getVideos();
    try {
      return videos.firstWhere((video) => video.id == id);
    } catch (e) {
      return null;
    }
  }

  // ==================== QUIZ DATA ====================
  
  /// Mengambil soal kuis berdasarkan level
  static Future<List<QuizQuestion>> getQuizQuestions(QuizLevel level) async {
    if (_useApi) {
      try {
        return await ApiService.getQuizQuestions(level);
      } catch (e) {
        if (kDebugMode) {
          print('DataService: API failed, fallback to dummy data: $e');
        }
      }
    }
    
    // Fallback ke dummy data
    return DummyData.dummyQuizQuestions
        .where((question) => question.level == level)
        .toList();
  }

  /// Submit jawaban kuis
  static Future<Map<String, dynamic>?> submitQuizAnswers({
    required String userId,
    required List<Map<String, dynamic>> answers,
    required QuizLevel level,
  }) async {
    if (_useApi) {
      try {
        return await ApiService.submitQuizAnswers(
          userId: userId,
          answers: answers,
          level: level,
        );
      } catch (e) {
        if (kDebugMode) {
          print('DataService: Failed to submit quiz via API: $e');
        }
        return null;
      }
    }
    
    // Simulasi untuk dummy data
    if (kDebugMode) {
      print('DataService: Quiz submitted in dummy mode (not persisted)');
    }
    
    // Hitung hasil secara lokal
    int correctAnswers = 0;
    final questions = await getQuizQuestions(level);
    
    for (var answer in answers) {
      final questionId = answer['question_id'];
      final selectedAnswer = answer['selected_answer'];
      
      final question = questions.firstWhere(
        (q) => q.id == questionId,
        orElse: () => questions.first,
      );
      
      if (selectedAnswer == question.correctAnswerIndex) {
        correctAnswers++;
      }
    }
    
    final percentage = (correctAnswers / answers.length) * 100;
    
    return {
      'total_questions': answers.length,
      'correct_answers': correctAnswers,
      'wrong_answers': answers.length - correctAnswers,
      'percentage': percentage,
      'passed': percentage >= 70,
    };
  }

  // ==================== USER DATA ====================
  
  /// Mengambil data user berdasarkan ID
  static Future<UserModel> getUserById(String id) async {
    if (_useApi) {
      try {
        return await ApiService.getUserById(id);
      } catch (e) {
        if (kDebugMode) {
          print('DataService: API failed, fallback to dummy data: $e');
        }
        return DummyData.dummyUser;
      }
    }
    return DummyData.dummyUser;
  }

  /// Update progress user
  static Future<UserModel?> updateUserProgress(String userId, {
    int? completedQuizzes,
    int? totalQuizzes,
  }) async {
    if (_useApi) {
      try {
        return await ApiService.updateUserProgress(
          userId,
          completedQuizzes: completedQuizzes,
          totalQuizzes: totalQuizzes,
        );
      } catch (e) {
        if (kDebugMode) {
          print('DataService: Failed to update user progress via API: $e');
        }
        return null;
      }
    }
    
    // Simulasi untuk dummy data
    if (kDebugMode) {
      print('DataService: User progress updated in dummy mode (not persisted)');
    }
    
    final currentUser = DummyData.dummyUser;
    return UserModel(
      id: currentUser.id,
      name: currentUser.name,
      className: currentUser.className,
      profileImageUrl: currentUser.profileImageUrl,
      completedQuizzes: completedQuizzes ?? currentUser.completedQuizzes,
      totalQuizzes: totalQuizzes ?? currentUser.totalQuizzes,
    );
  }

  // ==================== UTILITY METHODS ====================
  
  /// Refresh koneksi
  static Future<void> refreshConnection() async {
    await initialize();
  }

  /// Get status info
  static Map<String, dynamic> getStatus() {
    return {
      'connected': _isConnected,
      'using_api': _useApi,
      'data_source': _useApi ? 'API' : 'Dummy Data',
    };
  }
}