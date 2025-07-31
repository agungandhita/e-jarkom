import 'package:dio/dio.dart';
import '../models/quiz_model.dart';
import '../models/score_model.dart';
import 'api_service.dart';

class QuizService {
  final ApiService _apiService;

  QuizService(this._apiService);

  /// Get quiz questions by level
  Future<List<Quiz>> getQuizzesByLevel(String level, {int? limit}) async {
    try {
      final response = await _apiService.getQuizzes(level: level, limit: limit);

      // Debug logging
      print('DEBUG: Quiz API Response for level $level:');
      print('DEBUG: Full response: $response');
      print('DEBUG: Response type: ${response.runtimeType}');
      print('DEBUG: Success: ${response['success']}');
      print('DEBUG: Data: ${response['data']}');
      print('DEBUG: Data type: ${response['data']?.runtimeType}');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> quizzesData = response['data'] is List
            ? response['data']
            : response['data']['quizzes'] ?? response['data']['data'] ?? [];

        print('DEBUG: Quizzes data length: ${quizzesData.length}');
        if (quizzesData.isNotEmpty) {
          print('DEBUG: First quiz data: ${quizzesData.first}');
          // Log each quiz for debugging
          for (int i = 0; i < quizzesData.length; i++) {
            final quiz = quizzesData[i];
            print('DEBUG: Quiz ${i + 1}:');
            print('  ID: ${quiz['id']}');
            print('  Soal: ${quiz['soal']}');
            print(
              '  Jawaban Benar: "${quiz['jawaban_benar'] ?? quiz['jawaban']}"',
            );
            print('  Level: ${quiz['level']}');
            print('  Pilihan: ${quiz['pilihan']}');
          }
        } else {
          print('DEBUG: No quiz data found');
        }

        final quizzes = quizzesData.map((json) => Quiz.fromJson(json)).toList();
        print('DEBUG: Successfully parsed ${quizzes.length} quizzes');
        return quizzes;
      } else {
        print(
          'DEBUG: API Error - Success: ${response['success']}, Message: ${response['message']}',
        );
        throw Exception(response['message'] ?? 'Failed to fetch quizzes');
      }
    } catch (e) {
      print('DEBUG: Exception in getQuizzesByLevel: $e');
      throw Exception('Error fetching quizzes: $e');
    }
  }

  /// Submit quiz answers
  Future<Map<String, dynamic>> submitQuizAnswers({
    required String level,
    required List<Map<String, dynamic>> answers,
    String? sessionId,
    int? timeSpent,
  }) async {
    try {
      print('DEBUG: Submitting quiz answers');
      print('DEBUG: Level: $level');
      print('DEBUG: Answers count: ${answers.length}');
      print('DEBUG: Answers: $answers');
      print('DEBUG: Session ID: $sessionId');
      print('DEBUG: Time spent: $timeSpent');

      final requestData = {
        'answers': answers,
        'level': level,
        if (sessionId != null) 'session_id': sessionId,
        if (timeSpent != null) 'time_spent': timeSpent,
      };

      print('DEBUG: Request data: $requestData');

      final response = await _apiService.submitQuizAnswers(level, requestData);

      print('DEBUG: Submit response received: $response');
      print('DEBUG: Response success: ${response['success']}');
      print('DEBUG: Response data: ${response['data']}');

      if (response['success'] == true) {
        return response;
      } else {
        print('DEBUG: Submit failed - ${response['message']}');
        throw Exception(response['message'] ?? 'Failed to submit quiz');
      }
    } catch (e) {
      print('DEBUG: Exception in submitQuizAnswers: $e');
      throw Exception('Error submitting quiz: $e');
    }
  }

  /// Get user quiz history
  Future<List<ScoreModel>> getQuizHistory() async {
    try {
      final response = await _apiService.getQuizHistory();

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> historyData = response['data'] is List
            ? response['data']
            : response['data']['data'] ?? [];

        return historyData.map((json) => ScoreModel.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch quiz history');
      }
    } catch (e) {
      throw Exception('Error fetching quiz history: $e');
    }
  }

  /// Get user quiz statistics
  Future<Map<String, dynamic>> getQuizStatistics() async {
    try {
      final response = await _apiService.getQuizStats();

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception(
          response['message'] ?? 'Failed to fetch quiz statistics',
        );
      }
    } catch (e) {
      throw Exception('Error fetching quiz statistics: $e');
    }
  }

  /// Get leaderboard
  Future<List<ScoreModel>> getLeaderboard({
    String? level,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.getLeaderboardByLevel(
        level: level,
        limit: limit,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> leaderboardData = response['data'] is List
            ? response['data']
            : response['data']['data'] ?? [];

        return leaderboardData
            .map((json) => ScoreModel.fromJson(json))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch leaderboard');
      }
    } catch (e) {
      throw Exception('Error fetching leaderboard: $e');
    }
  }

  /// Get user scores
  Future<List<ScoreModel>> getUserScores({
    int? page,
    int? limit,
    String? level,
  }) async {
    try {
      final response = await _apiService.getScores(
        page: page,
        limit: limit,
        level: level,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> scoresData = response['data'] is List
            ? response['data']
            : response['data']['data'] ?? [];

        return scoresData.map((json) => ScoreModel.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch user scores');
      }
    } catch (e) {
      throw Exception('Error fetching user scores: $e');
    }
  }

  /// Calculate quiz score
  Map<String, dynamic> calculateScore({
    required List<Quiz> questions,
    required List<int?> userAnswers,
  }) {
    int correctAnswers = 0;
    int answeredQuestions = 0;
    int totalQuestions = questions.length;

    print('DEBUG: Starting score calculation');
    print('DEBUG: Total questions: $totalQuestions');
    print('DEBUG: User answers length: ${userAnswers.length}');

    for (int i = 0; i < questions.length; i++) {
      final userAnswer = userAnswers[i];
      if (userAnswer != null && userAnswer >= 0 && userAnswer < 4) {
        answeredQuestions++;
        final question = questions[i];
        final correctAnswer =
            question.jawabanBenar; // Already normalized in model

        // Convert user answer index to letter (0=a, 1=b, 2=c, 3=d)
        final userAnswerLetter = ['a', 'b', 'c', 'd'][userAnswer];

        print('DEBUG Quiz ${i + 1} (ID: ${question.id}):');
        print('  Question: ${question.soal}');
        print('  User answer index: $userAnswer');
        print('  User answer letter: $userAnswerLetter');
        print('  Correct answer (normalized): "$correctAnswer"');
        print('  Options: ${question.pilihan}');

        // Compare normalized values
        final isCorrect = userAnswerLetter == correctAnswer;
        print('  Match: $isCorrect');

        if (isCorrect) {
          correctAnswers++;
          print('  -> CORRECT!');
        } else {
          print('  -> WRONG!');
          print('  -> Expected: "$correctAnswer", Got: "$userAnswerLetter"');
        }
      } else {
        print('DEBUG Quiz ${i + 1}: No answer provided (skipped)');
      }
    }

    // Calculate score based on total questions (consistent with backend receiving all questions)
    final score = totalQuestions > 0
        ? (correctAnswers * 100) ~/ totalQuestions
        : 0;
    final percentage = totalQuestions > 0
        ? (correctAnswers / totalQuestions) * 100
        : 0.0;

    print('DEBUG: Final calculation results:');
    print('  Correct answers: $correctAnswers');
    print('  Answered questions: $answeredQuestions');
    print('  Total questions: $totalQuestions');
    print('  Score: $score');
    print('  Percentage: $percentage');

    return {
      'correct_answers': correctAnswers,
      'total_questions': totalQuestions, // Use total questions for consistency
      'incorrect_answers': totalQuestions - correctAnswers,
      'score': score,
      'percentage': percentage,
    };
  }

  /// Format answers for backend submission
  List<Map<String, dynamic>> formatAnswersForSubmission({
    required List<Quiz> questions,
    required List<int?> userAnswers,
  }) {
    List<Map<String, dynamic>> formattedAnswers = [];

    print('DEBUG: Formatting answers for submission');
    print('DEBUG: Questions count: ${questions.length}');
    print('DEBUG: User answers count: ${userAnswers.length}');

    for (int i = 0; i < questions.length; i++) {
      final userAnswer = userAnswers[i];
      final question = questions[i];

      // Ensure quiz_id is properly converted
      int quizId;
      try {
        quizId = int.parse(question.id);
      } catch (e) {
        print('  ERROR: Cannot parse quiz_id "${question.id}" to int: $e');
        continue;
      }

      String? answerLetter;
      if (userAnswer != null && userAnswer >= 0 && userAnswer < 4) {
        answerLetter = ['a', 'b', 'c', 'd'][userAnswer];
        print('DEBUG: Formatting answer for question ${i + 1}:');
        print('  Quiz ID: ${question.id}');
        print('  User answer index: $userAnswer');
        print('  Answer letter: $answerLetter');
        print('  Correct answer: ${question.jawabanBenar}');
      } else {
        // Send null for unanswered questions
        answerLetter = null;
        print('DEBUG: Formatting UNANSWERED question ${i + 1}:');
        print('  Quiz ID: ${question.id}');
        print('  User answer: null/invalid (${userAnswer})');
        print('  Answer letter: null (unanswered)');
        print('  Correct answer: ${question.jawabanBenar}');
      }

      formattedAnswers.add({'quiz_id': quizId, 'jawaban': answerLetter});
      print('  Formatted: {quiz_id: $quizId, jawaban: $answerLetter}');
    }

    print('DEBUG: Total formatted answers: ${formattedAnswers.length}');
    print('DEBUG: All questions included (answered + unanswered)');
    print('DEBUG: Formatted answers: $formattedAnswers');
    return formattedAnswers;
  }
}
