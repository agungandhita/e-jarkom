import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/quiz.dart';
import '../datasources/local_storage.dart';

class QuizRepository {
  final Dio _dio;
  final LocalStorage _localStorage;

  QuizRepository(this._dio, this._localStorage);

  // Get quiz questions by level
  Future<List<QuizQuestion>> getQuizQuestions({
    required QuizLevel level,
    int limit = 10,
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'level': level.value,
        'limit': limit,
      };

      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['category_id'] = categoryId;
      }

      final response = await _dio.get('/quizzes', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> questionsJson = response.data['data'] ?? [];
        final questions = questionsJson
            .map((json) => QuizQuestion.fromJson(json))
            .toList();

        // Cache questions for offline access
        await _cacheQuizQuestions(questions, level, categoryId);

        return questions;
      } else {
        throw Exception(
          'Failed to load quiz questions: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        // Try to load from cache when offline
        return await _getCachedQuizQuestions(level, categoryId);
      }
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Start a new quiz session
  Future<QuizSession> startQuizSession({
    required QuizLevel level,
    String? categoryId,
    int? timeLimit,
  }) async {
    try {
      final requestData = {'level': level.value, 'time_limit': timeLimit};

      if (categoryId != null && categoryId.isNotEmpty) {
        requestData['category_id'] = categoryId;
      }

      final response = await _dio.post('/quizzes/start', data: requestData);

      if (response.statusCode == 201) {
        final sessionJson = response.data['data'];
        final session = QuizSession.fromJson(sessionJson);

        // Cache session for offline access
        await _localStorage.cacheData('current_quiz_session', session.toJson());

        return session;
      } else {
        throw Exception(
          'Failed to start quiz session: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Submit quiz answers
  Future<QuizSession> submitQuizAnswers({
    required String sessionId,
    required List<int?> answers,
  }) async {
    try {
      final response = await _dio.post(
        '/quizzes/submit',
        data: {'session_id': sessionId, 'answers': answers},
      );

      if (response.statusCode == 200) {
        final sessionJson = response.data['data'];
        final completedSession = QuizSession.fromJson(sessionJson);

        // Remove current session cache and cache the completed session
        await _localStorage.removeData('current_quiz_session');
        await _cacheQuizScore(completedSession);

        return completedSession;
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
  Future<List<QuizScore>> getUserQuizScores({
    int page = 1,
    int limit = 20,
    QuizLevel? level,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (level != null) {
        queryParams['level'] = level.value;
      }

      final response = await _dio.get('/scores', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> scoresJson = response.data['data'] ?? [];
        final scores = scoresJson
            .map((json) => QuizScore.fromJson(json))
            .toList();

        // Cache scores for offline access
        await _cacheUserScores(scores, page, level);

        return scores;
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
  Future<List<QuizScore>> getLeaderboard({
    QuizLevel? level,
    int limit = 50,
    String period = 'all', // all, week, month
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit, 'period': period};

      if (level != null) {
        queryParams['level'] = level.value;
      }

      final response = await _dio.get(
        '/leaderboard',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> scoresJson = response.data['data'] ?? [];
        final scores = scoresJson
            .map((json) => QuizScore.fromJson(json))
            .toList();

        // Cache leaderboard for offline access
        await _cacheLeaderboard(scores, level, period);

        return scores;
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
        final stats = response.data['data'] ?? {};

        // Cache statistics for offline access
        await _localStorage.cacheData('quiz_statistics', stats);

        return stats;
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

  // Create new quiz question (admin only)
  Future<QuizQuestion> createQuizQuestion(QuizQuestion question) async {
    try {
      final response = await _dio.post(
        '/quizzes/questions',
        data: question.toJson(),
      );

      if (response.statusCode == 201) {
        final questionJson = response.data['data'];
        return QuizQuestion.fromJson(questionJson);
      } else {
        throw Exception(
          'Failed to create quiz question: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Update quiz question (admin only)
  Future<QuizQuestion> updateQuizQuestion(
    String id,
    QuizQuestion question,
  ) async {
    try {
      final response = await _dio.put(
        '/quizzes/questions/$id',
        data: question.toJson(),
      );

      if (response.statusCode == 200) {
        final questionJson = response.data['data'];
        return QuizQuestion.fromJson(questionJson);
      } else {
        throw Exception(
          'Failed to update quiz question: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Delete quiz question (admin only)
  Future<void> deleteQuizQuestion(String id) async {
    try {
      final response = await _dio.delete('/quizzes/questions/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete quiz question: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unknown error occurred: $e');
    }
  }

  // Get current quiz session (if any)
  Future<QuizSession?> getCurrentQuizSession() async {
    try {
      final cachedData = await _localStorage.getCachedData(
        'current_quiz_session',
      );
      if (cachedData != null) {
        return QuizSession.fromJson(cachedData);
      }
    } catch (e) {
      debugPrint('Failed to get current quiz session: $e');
    }
    return null;
  }

  // Save current quiz session progress
  Future<void> saveQuizSessionProgress(QuizSession session) async {
    try {
      await _localStorage.cacheData('current_quiz_session', session.toJson());
    } catch (e) {
      debugPrint('Failed to save quiz session progress: $e');
    }
  }

  // Clear current quiz session
  Future<void> clearCurrentQuizSession() async {
    try {
      await _localStorage.removeData('current_quiz_session');
    } catch (e) {
      debugPrint('Failed to clear current quiz session: $e');
    }
  }

  // Cache management methods
  Future<void> _cacheQuizQuestions(
    List<QuizQuestion> questions,
    QuizLevel level,
    String? categoryId,
  ) async {
    try {
      final cacheKey = 'quiz_questions_${level.value}_${categoryId ?? 'all'}';
      final questionsJson = questions.map((q) => q.toJson()).toList();
      await _localStorage.cacheData(cacheKey, questionsJson);
    } catch (e) {
      debugPrint('Failed to cache quiz questions: $e');
    }
  }

  Future<List<QuizQuestion>> _getCachedQuizQuestions(
    QuizLevel level,
    String? categoryId,
  ) async {
    try {
      final cacheKey = 'quiz_questions_${level.value}_${categoryId ?? 'all'}';
      final cachedData = await _localStorage.getCachedData(cacheKey);
      if (cachedData != null) {
        final List<dynamic> questionsJson = cachedData;
        return questionsJson
            .map((json) => QuizQuestion.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to get cached quiz questions: $e');
    }
    return [];
  }

  Future<void> _cacheQuizScore(QuizSession session) async {
    try {
      // Cache individual score
      await _localStorage.cacheData(
        'quiz_score_${session.id}',
        session.toJson(),
      );

      // Add to user scores cache
      final existingScores = await _getCachedUserScores(1, null);
      final score = QuizScore(
        id: session.id,
        userId: session.userId,
        userName: '', // Will be filled from user data
        level: session.level,
        score: session.score,
        totalQuestions: session.totalQuestions,
        correctAnswers: session.correctAnswers,
        wrongAnswers: session.wrongAnswers,
        percentage: session.percentage,
        grade: 'C', // Default grade
        duration: Duration(seconds: 0), // Default duration
        completedAt: session.endTime ?? DateTime.now(),
      );

      existingScores.insert(0, score);
      await _localStorage.cacheData(
        'user_scores_page_1_all',
        existingScores.map((s) => s.toJson()).toList(),
      );
    } catch (e) {
      debugPrint('Failed to cache quiz score: $e');
    }
  }

  Future<void> _cacheUserScores(
    List<QuizScore> scores,
    int page,
    QuizLevel? level,
  ) async {
    try {
      final cacheKey = 'user_scores_page_${page}_${level?.value ?? 'all'}';
      final scoresJson = scores.map((s) => s.toJson()).toList();
      await _localStorage.cacheData(cacheKey, scoresJson);
    } catch (e) {
      debugPrint('Failed to cache user scores: $e');
    }
  }

  Future<List<QuizScore>> _getCachedUserScores(
    int page,
    QuizLevel? level,
  ) async {
    try {
      final cacheKey = 'user_scores_page_${page}_${level?.value ?? 'all'}';
      final cachedData = await _localStorage.getCachedData(cacheKey);
      if (cachedData != null) {
        final List<dynamic> scoresJson = cachedData;
        return scoresJson.map((json) => QuizScore.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to get cached user scores: $e');
    }
    return [];
  }

  Future<void> _cacheLeaderboard(
    List<QuizScore> scores,
    QuizLevel? level,
    String period,
  ) async {
    try {
      final cacheKey = 'leaderboard_${level?.value ?? 'all'}_$period';
      final scoresJson = scores.map((s) => s.toJson()).toList();
      await _localStorage.cacheData(cacheKey, scoresJson);
    } catch (e) {
      debugPrint('Failed to cache leaderboard: $e');
    }
  }

  Future<List<QuizScore>> _getCachedLeaderboard(
    QuizLevel? level,
    String period,
  ) async {
    try {
      final cacheKey = 'leaderboard_${level?.value ?? 'all'}_$period';
      final cachedData = await _localStorage.getCachedData(cacheKey);
      if (cachedData != null) {
        final List<dynamic> scoresJson = cachedData;
        return scoresJson.map((json) => QuizScore.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to get cached leaderboard: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> _getCachedQuizStatistics() async {
    try {
      final cachedData = await _localStorage.getCachedData('quiz_statistics');
      if (cachedData != null) {
        return Map<String, dynamic>.from(cachedData);
      }
    } catch (e) {
      debugPrint('Failed to get cached quiz statistics: $e');
    }
    return {};
  }

  // Helper methods
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.sendTimeout:
        return Exception('Send timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return Exception('Receive timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message =
            e.response?.data?['message'] ?? 'Unknown error occurred';

        switch (statusCode) {
          case 400:
            return Exception('Bad request: $message');
          case 401:
            return Exception('Unauthorized. Please login again.');
          case 403:
            return Exception('Forbidden. You don\'t have permission.');
          case 404:
            return Exception('Quiz not found.');
          case 422:
            // Validation errors
            final errors = e.response?.data?['errors'];
            if (errors != null) {
              throw {'validation_errors': errors};
            }
            return Exception('Validation error: $message');
          case 500:
            return Exception('Server error. Please try again later.');
          default:
            return Exception('Error $statusCode: $message');
        }
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      case DioExceptionType.badCertificate:
        return Exception('Certificate error. Please check your connection.');
      default:
        return Exception('Unknown error occurred: ${e.message}');
    }
  }

  // Clear all quiz cache
  Future<void> clearCache() async {
    try {
      // Clear quiz questions cache
      for (final level in QuizLevel.values) {
        await _localStorage.removeData('quiz_questions_${level.value}_all');
      }

      // Clear user scores cache
      for (int i = 1; i <= 5; i++) {
        await _localStorage.removeData('user_scores_page_${i}_all');
        for (final level in QuizLevel.values) {
          await _localStorage.removeData(
            'user_scores_page_${i}_${level.value}',
          );
        }
      }

      // Clear leaderboard cache
      for (final period in ['all', 'week', 'month']) {
        await _localStorage.removeData('leaderboard_all_$period');
        for (final level in QuizLevel.values) {
          await _localStorage.removeData('leaderboard_${level.value}_$period');
        }
      }

      // Clear statistics cache
      await _localStorage.removeData('quiz_statistics');

      // Clear current session
      await _localStorage.removeData('current_quiz_session');
    } catch (e) {
      debugPrint('Failed to clear quiz cache: $e');
    }
  }
}
