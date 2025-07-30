import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/quiz_model.dart';
import '../../models/score_model.dart';
import '../../models/quiz_level.dart';
import '../../models/quiz_session.dart';
import '../../models/quiz_question.dart';
import '../../models/quiz_score.dart';
import '../datasources/local_storage.dart';

class QuizRepository {
  final Dio _dio;

  QuizRepository(this._dio);

  // Get quiz questions by level
  Future<List<Quiz>> getQuizQuestions({
    required String level,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/quizzes',
        queryParameters: {
          'level': level,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> quizzesData = data['data']['data'] ?? [];
          final quizzes = quizzesData.map((json) => Quiz.fromJson(json)).toList();
          
          // Cache the quiz questions
          await _cacheQuizQuestions(level, quizzes);
          
          return quizzes;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch quiz questions');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // Try to get cached data if available
      final cachedQuizzes = await _getCachedQuizQuestions(level);
      if (cachedQuizzes.isNotEmpty) {
        return cachedQuizzes;
      }
      
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to fetch quiz questions: $e');
    }
  }

  // Submit quiz answers
  Future<Map<String, dynamic>> submitQuizAnswers({
    required String level,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    int timeSpent = 0,
  }) async {
    try {
      final response = await _dio.post(
        '/scores',
        data: {
          'level': level,
          'skor': score,
          'total_soal': totalQuestions,
          'benar': correctAnswers,
          'salah': totalQuestions - correctAnswers,
          'time_spent': timeSpent,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
          'Failed to submit quiz answers: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Get user's quiz scores/history
  Future<List<ScoreModel>> getUserQuizScores({
    int page = 1,
    int limit = 20,
    String? level,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (level != null) {
        queryParams['level'] = level;
      }

      final response = await _dio.get('/scores', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> scoresData = data['data']['data'] ?? [];
          final scores = scoresData
              .map((json) => ScoreModel.fromJson(json))
              .toList();

          // Cache scores for offline access
          await _cacheUserScores(scores, page, level);

          return scores;
        } else {
          throw Exception(data['message'] ?? 'Failed to load quiz scores');
        }
      } else {
        throw Exception(
          'Failed to load quiz scores: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        // Try to load from cache when offline
        return await _getCachedUserScores(page, level);
      }
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Get leaderboard
  Future<List<ScoreModel>> getLeaderboard({
    String? level,
    int limit = 50,
    String period = 'all', // all, week, month
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit, 'period': period};

      if (level != null) {
        queryParams['level'] = level;
      }

      final response = await _dio.get(
        '/leaderboard',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> scoresData = data['data']['data'] ?? [];
          final scores = scoresData
              .map((json) => ScoreModel.fromJson(json))
              .toList();

          // Cache leaderboard for offline access
          await _cacheLeaderboard(scores, level, period);

          return scores;
        } else {
          throw Exception(data['message'] ?? 'Failed to load leaderboard');
        }
      } else {
        throw Exception(
          'Failed to load leaderboard: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        // Try to load from cache when offline
        return await _getCachedLeaderboard(level, period);
      }
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Get quiz statistics
  Future<Map<String, dynamic>> getQuizStatistics() async {
    try {
      final response = await _dio.get('/dashboard/quiz-stats');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final stats = data['data'] ?? {};

          // Cache statistics for offline access
          await LocalStorage.saveCache('quiz_statistics', stats);

          return stats;
        } else {
          throw Exception(data['message'] ?? 'Failed to load quiz statistics');
        }
      } else {
        throw Exception(
          'Failed to load quiz statistics: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        // Try to load from cache when offline
        return await _getCachedQuizStatistics();
      }
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Cache management methods
  Future<void> _cacheQuizQuestions(
    String level,
    List<Quiz> questions,
  ) async {
    try {
      final cacheKey = 'quiz_questions_$level';
      final questionsJson = questions.map((q) => q.toJson()).toList();
      await LocalStorage.saveCache(cacheKey, {'questions': questionsJson});
    } catch (e) {
      debugPrint('Failed to cache quiz questions: $e');
    }
  }

  Future<List<Quiz>> _getCachedQuizQuestions(String level) async {
    try {
      final cacheKey = 'quiz_questions_$level';
      final cachedData = await LocalStorage.getCache(cacheKey);
      if (cachedData != null && cachedData is Map<String, dynamic>) {
        final questionsList = cachedData['questions'] as List?;
        if (questionsList != null) {
          return questionsList
              .map((json) => Quiz.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Failed to get cached quiz questions: $e');
    }
    return [];
  }

  Future<void> _cacheUserScores(
    List<ScoreModel> scores,
    int page,
    String? level,
  ) async {
    try {
      final cacheKey = 'user_scores_page_${page}_${level ?? 'all'}';
      final scoresJson = scores.map((s) => s.toJson()).toList();
      await LocalStorage.saveCache(cacheKey, {'scores': scoresJson});
    } catch (e) {
      debugPrint('Failed to cache user scores: $e');
    }
  }

  Future<List<ScoreModel>> _getCachedUserScores(
    int page,
    String? level,
  ) async {
    try {
      final cacheKey = 'user_scores_page_${page}_${level ?? 'all'}';
      final cachedData = await LocalStorage.getCache(cacheKey);
      if (cachedData != null && cachedData is Map<String, dynamic>) {
        final scoresList = cachedData['scores'] as List?;
        if (scoresList != null) {
          return scoresList
              .map((json) => ScoreModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Failed to get cached user scores: $e');
    }
    return [];
  }

  Future<void> _cacheLeaderboard(
    List<ScoreModel> scores,
    String? level,
    String period,
  ) async {
    try {
      final cacheKey = 'leaderboard_${level ?? 'all'}_$period';
      final scoresJson = scores.map((s) => s.toJson()).toList();
      await LocalStorage.saveCache(cacheKey, {'scores': scoresJson});
    } catch (e) {
      debugPrint('Failed to cache leaderboard: $e');
    }
  }

  Future<List<ScoreModel>> _getCachedLeaderboard(
    String? level,
    String period,
  ) async {
    try {
      final cacheKey = 'leaderboard_${level ?? 'all'}_$period';
      final cachedData = await LocalStorage.getCache(cacheKey);
      if (cachedData != null && cachedData is Map<String, dynamic>) {
        final scoresList = cachedData['scores'] as List?;
        if (scoresList != null) {
          return scoresList
              .map((json) => ScoreModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Failed to get cached leaderboard: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> _getCachedQuizStatistics() async {
    try {
      final cachedData = await LocalStorage.getCache('quiz_statistics');
      if (cachedData != null && cachedData is Map<String, dynamic>) {
        return cachedData;
      }
    } catch (e) {
      debugPrint('Failed to get cached quiz statistics: $e');
    }
    return {};
  }

  // Error handling
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Server error occurred';
        return Exception('Server error ($statusCode): $message');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      default:
        return Exception('Network error: ${e.message}');
    }
  }

  // Clear all quiz cache
  Future<void> clearCache() async {
    try {
      // Clear quiz questions cache
      final levels = ['beginner', 'intermediate', 'advanced'];
      for (final level in levels) {
        await LocalStorage.removeCache('quiz_questions_$level');
      }

      // Clear user scores cache
      for (int i = 1; i <= 5; i++) {
        await LocalStorage.removeCache('user_scores_page_${i}_all');
        for (final level in levels) {
          await LocalStorage.removeCache('user_scores_page_${i}_$level');
        }
      }

      // Clear leaderboard cache
      for (final period in ['all', 'week', 'month']) {
        await LocalStorage.removeCache('leaderboard_all_$period');
        for (final level in levels) {
          await LocalStorage.removeCache('leaderboard_${level}_$period');
        }
      }

      // Clear statistics cache
      await LocalStorage.removeCache('quiz_statistics');
    } catch (e) {
      debugPrint('Failed to clear quiz cache: $e');
    }
  }
}
