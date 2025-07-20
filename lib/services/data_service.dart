import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/tool_model.dart';
import '../models/video_model.dart';
import '../models/quiz_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// Service untuk mengelola data dari API
class DataService {
  static bool _isConnected = false;

  /// Inisialisasi dan test koneksi ke server
  static Future<void> initialize() async {
    try {
      _isConnected = await ApiService.testConnection();
      
      if (kDebugMode) {
        print('DataService initialized: API ${_isConnected ? 'connected' : 'not available'}');
      }
    } catch (e) {
      _isConnected = false;
      
      if (kDebugMode) {
        print('DataService: Failed to connect to API: $e');
      }
      rethrow;
    }
  }

  /// Check status koneksi
  static bool get isConnected => _isConnected;

  // ==================== TOOLS DATA ====================
  
  /// Mengambil semua data alat teknik
  static Future<List<ToolModel>> getTools() async {
    try {
      return await ApiService.getToolsLegacy();
    } catch (e) {
      if (kDebugMode) {
        print('DataService: Failed to get tools from API: $e');
      }
      rethrow;
    }
  }

  /// Mengambil detail alat teknik berdasarkan ID
  static Future<ToolModel?> getToolById(String id) async {
    try {
      final result = await ApiService.getToolById(id);
      return result.data;
    } catch (e) {
      if (kDebugMode) {
        print('DataService: Failed to get tool by ID from API: $e');
      }
      rethrow;
    }
  }

  /// Menambah alat teknik baru dengan upload gambar
  static Future<ToolModel?> createTool(ToolModel tool, {File? imageFile}) async {
    try {
      final result = await ApiService.createTool(tool, imageFile: imageFile);
      return result.data;
    } catch (e) {
      if (kDebugMode) {
        print('DataService: Failed to create tool via API: $e');
      }
      rethrow;
    }
  }

  /// Mencari alat teknik
  static Future<List<ToolModel>> searchTools(String query) async {
    try {
      return await ApiService.searchTools(query);
    } catch (e) {
      if (kDebugMode) {
        print('DataService: Failed to search tools via API: $e');
      }
      rethrow;
    }
  }

  // ==================== VIDEOS DATA ====================
  
  /// Mengambil semua data video pembelajaran
  static Future<List<VideoModel>> getVideos() async {
    try {
      return await ApiService.getVideosLegacy();
    } catch (e) {
      if (kDebugMode) {
        print('DataService: Failed to get videos from API: $e');
      }
      rethrow;
    }
  }

  /// Mengambil video berdasarkan kategori
  static Future<List<VideoModel>> getVideosByCategory(String category) async {
    try {
      final result = await ApiService.getVideos(search: category, perPage: 100);
      return result.data ?? [];
    } catch (e) {
      if (kDebugMode) {
        print('DataService: Failed to get videos by category from API: $e');
      }
      rethrow;
    }
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
    try {
      return await ApiService.getQuizQuestionsLegacy(level);
    } catch (e) {
      if (kDebugMode) {
        print('DataService: Failed to get quiz questions from API: $e');
      }
      rethrow;
    }
  }

  /// Submit jawaban kuis
  static Future<Map<String, dynamic>?> submitQuizAnswers({
    required String userId,
    required List<Map<String, dynamic>> answers,
    required QuizLevel level,
  }) async {
    try {
      return await ApiService.submitQuizAnswersLegacy(
        userId: userId,
        answers: answers,
        level: level,
      );
    } catch (e) {
      if (kDebugMode) {
        print('DataService: Failed to submit quiz via API: $e');
      }
      rethrow;
    }
  }

  // ==================== USER DATA ====================
  
  /// Mengambil data user berdasarkan ID
  static Future<UserModel> getUserById(String id) async {
    try {
      return await ApiService.getUserById(id);
    } catch (e) {
      if (kDebugMode) {
        print('DataService: Failed to get user by ID from API: $e');
      }
      rethrow;
    }
  }

  /// Update progress user
  static Future<UserModel> updateUserProgress(String userId, {
    int? completedQuizzes,
    int? totalQuizzes,
  }) async {
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
      rethrow;
    }
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
      'data_source': _isConnected ? 'API' : 'No Connection',
    };
  }
}