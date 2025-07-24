import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';
import '../../models/score_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

enum QuizState { idle, loading, ready, inProgress, paused, completed, error }

class QuizProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  QuizProvider({required ApiService apiService, required StorageService storageService})
    : _apiService = apiService,
      _storageService = storageService;

  // State variables
  QuizState _state = QuizState.idle;
  List<Quiz> _questions = [];
  List<ScoreModel> _userScores = [];
  List<ScoreModel> _leaderboard = [];
  Map<String, dynamic> _statistics = {};

  String? _currentSessionId;
  String _selectedLevel = 'mudah';
  String? _selectedCategoryId;
  int _currentQuestionIndex = 0;
  List<int?> _userAnswers = [];
  int? _timeLimit;
  ScoreModel? _lastQuizScore;
  DateTime? _startTime;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreScores = true;
  String? _errorMessage;
  Map<String, String> _validationErrors = {};

  Timer? _quizTimer;
  Duration _remainingTime = Duration.zero;

  int _currentScorePage = 1;
  final int _pageSize = 10;

  // Getters
  QuizState get state => _state;
  List<Quiz> get questions => _questions;
  List<ScoreModel> get userScores => _userScores;
  List<ScoreModel> get leaderboard => _leaderboard;
  Map<String, dynamic> get statistics => _statistics;

  String? get currentSessionId => _currentSessionId;
  String get selectedLevel => _selectedLevel;
  String? get selectedCategoryId => _selectedCategoryId;
  int get currentQuestionIndex => _currentQuestionIndex;
  List<int?> get userAnswers => _userAnswers;
  ScoreModel? get lastQuizScore => _lastQuizScore;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreScores => _hasMoreScores;
  String? get errorMessage => _errorMessage;
  Map<String, String> get validationErrors => _validationErrors;

  Duration get remainingTime => _remainingTime;
  bool get hasTimer => _timeLimit != null;
  bool get isTimeUp => _remainingTime.inSeconds <= 0 && hasTimer;

  // Quiz progress getters
  bool get hasQuestions => _questions.isNotEmpty;
  bool get isQuizInProgress => _state == QuizState.inProgress;
  bool get isQuizCompleted => _state == QuizState.completed;
  bool get canGoToNextQuestion => _currentQuestionIndex < _questions.length - 1;
  bool get canGoToPreviousQuestion => _currentQuestionIndex > 0;
  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;
  bool get isFirstQuestion => _currentQuestionIndex == 0;

  double get progress {
    if (_questions.isEmpty) return 0.0;
    return (_currentQuestionIndex + 1) / _questions.length;
  }

  int get answeredCount {
    return _userAnswers.where((answer) => answer != null).length;
  }

  bool get isAllAnswered {
    return _userAnswers.every((answer) => answer != null);
  }

  Quiz? get currentQuestion {
    if (_currentQuestionIndex >= 0 &&
        _currentQuestionIndex < _questions.length) {
      return _questions[_currentQuestionIndex];
    }
    return null;
  }

  // Initialize quiz data
  Future<void> initialize() async {
    await Future.wait([
      loadUserScores(),
      loadLeaderboard(),
      loadStatistics(),
      _checkForExistingSession(),
    ]);
  }

  // Check for existing quiz session
  Future<void> _checkForExistingSession() async {
    try {
      final sessionData = _storageService.getString('current_quiz_session');
      if (sessionData != null) {
        // Parse session data and restore state if needed
        _state = QuizState.ready;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error checking for existing session: $e');
    }
  }

  // Load quiz questions for selected level
  Future<bool> loadQuizQuestions({
    required String level,
    String? categoryId,
    int limit = 10,
  }) async {
    _setLoading(true);
    _clearError();
    _state = QuizState.loading;
    notifyListeners();

    try {
      final response = await _apiService.getQuizzes(
        level: level,
        page: 1,
        limit: limit,
      );

      if (response['success'] == true && response['data'] != null) {
        _questions = (response['data'] as List)
            .map((item) => Quiz.fromJson(item))
            .toList();
        _selectedLevel = level;
        _selectedCategoryId = categoryId;
        _state = QuizState.ready;

        // Cache questions
        await _storageService.setString(
          'quizzes_$level',
          response['data'].toString(),
        );

        return true;
      } else {
        _setError(response['message'] ?? 'Gagal memuat soal kuis');
        _state = QuizState.error;
        return false;
      }
    } catch (e) {
      _setError('Gagal memuat soal kuis: ${e.toString()}');
      _state = QuizState.error;

      // Try to load from cache
      try {
        final cachedData = _storageService.getString('quizzes_$level');
        if (cachedData != null) {
          // Parse cached data if available
          _state = QuizState.ready;
          return true;
        }
      } catch (cacheError) {
        debugPrint('Failed to load from cache: $cacheError');
      }

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Start a new quiz session
  Future<bool> startQuizSession({
    required String level,
    String? categoryId,
    int? timeLimit,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Load questions first
      final questionsLoaded = await loadQuizQuestions(
        level: level,
        categoryId: categoryId,
      );

      if (!questionsLoaded) {
        return false;
      }

      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _userAnswers = List.filled(_questions.length, null);
      _selectedLevel = level;
      _selectedCategoryId = categoryId;
      _timeLimit = timeLimit;
      _currentQuestionIndex = 0;
      _state = QuizState.inProgress;

      // Start timer if time limit is set
      if (timeLimit != null) {
        _remainingTime = Duration(seconds: timeLimit);
        _startTimer();
      }

      // Save session to storage
      await _storageService.setString(
        'current_quiz_session',
        _currentSessionId!,
      );

      return true;
    } catch (e) {
      _setError('Gagal memulai kuis: ${e.toString()}');
      _state = QuizState.error;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Answer current question
  void answerQuestion(int answerIndex) {
    if (_currentQuestionIndex >= 0 &&
        _currentQuestionIndex < _userAnswers.length) {
      _userAnswers[_currentQuestionIndex] = answerIndex;

      // Save progress
      _saveSessionProgress();

      notifyListeners();
    }
  }

  // Go to next question
  void nextQuestion() {
    if (canGoToNextQuestion) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // Go to previous question
  void previousQuestion() {
    if (canGoToPreviousQuestion) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Go to specific question
  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  // Submit quiz answers
  Future<bool> submitQuiz() async {
    if (_currentSessionId == null || _questions.isEmpty) return false;

    _setLoading(true);
    _clearError();
    _stopTimer();

    try {
      // Calculate score
      int correctAnswers = 0;
      for (int i = 0; i < _questions.length; i++) {
        final userAnswer = _userAnswers[i];
        if (userAnswer != null) {
          final question = _questions[i];
          final correctAnswer = question.jawabanBenar;
          final options = [
            question.pilihanA,
            question.pilihanB,
            question.pilihanC,
            question.pilihanD,
          ];
          if (userAnswer < options.length &&
              options[userAnswer] == correctAnswer) {
            correctAnswers++;
          }
        }
      }

      final totalQuestions = _questions.length;
      final score = (correctAnswers * 100) ~/ totalQuestions;
      final timeSpent = _timeLimit != null
          ? _timeLimit! - _remainingTime.inSeconds
          : 0;

      final response = await _apiService.submitQuiz(
        level: _selectedLevel,
        skor: score,
        totalSoal: totalQuestions,
        benar: correctAnswers,
        timeSpent: timeSpent,
      );

      if (response['success'] == true) {
        // Create score model
        _lastQuizScore = ScoreModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'current_user',
          level: _selectedLevel,
          skor: score,
          totalSoal: totalQuestions,
          benar: correctAnswers,
          salah: totalQuestions - correctAnswers,
          tanggal: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        _state = QuizState.completed;

        // Clear session
        await _storageService.remove('current_quiz_session');

        // Refresh user scores to include the new score
        await loadUserScores(refresh: true);

        return true;
      } else {
        _setError(response['message'] ?? 'Gagal mengirim jawaban');
        return false;
      }
    } catch (e) {
      _setError('Gagal mengirim jawaban: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Pause quiz
  void pauseQuiz() {
    if (_state == QuizState.inProgress) {
      _state = QuizState.paused;
      _stopTimer();
      _saveSessionProgress();
      notifyListeners();
    }
  }

  // Resume quiz
  void resumeQuiz() {
    if (_state == QuizState.paused) {
      _state = QuizState.inProgress;
      if (hasTimer) {
        _startTimer();
      }
      notifyListeners();
    }
  }

  // Reset quiz
  void resetQuiz() {
    _stopTimer();
    _currentSessionId = null;
    _questions.clear();
    _userAnswers.clear();
    _currentQuestionIndex = 0;
    _remainingTime = Duration.zero;
    _timeLimit = null;
    _lastQuizScore = null;
    _state = QuizState.idle;
    _storageService.remove('current_quiz_session');
    notifyListeners();
  }

  // Load user quiz scores
  Future<void> loadUserScores({bool refresh = false, String? level}) async {
    if (refresh) {
      _currentScorePage = 1;
      _hasMoreScores = true;
      _userScores.clear();
    }

    if (_isLoading || (!_hasMoreScores && !refresh)) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getScores(
        page: _currentScorePage,
        limit: _pageSize,
        level: level,
      );

      if (response['success'] == true && response['data'] != null) {
        final scores = (response['data'] as List)
            .map((item) => ScoreModel.fromMap(item))
            .toList();

        if (refresh) {
          _userScores = scores;
        } else {
          _userScores.addAll(scores);
        }

        _hasMoreScores = scores.length == _pageSize;
        _currentScorePage++;

        // Cache scores
        await _storageService.setQuizScores(
          _userScores.map((score) => score.toMap()).toList(),
        );
      } else {
        // Try to load from cache
        final cachedScores = _storageService.getQuizScores();
        if (cachedScores != null && refresh) {
          _userScores = cachedScores
              .map((item) => ScoreModel.fromMap(item))
              .toList();
        }
      }
    } catch (e) {
      _setError('Gagal memuat riwayat skor: ${e.toString()}');

      // Try to load from cache on error
      try {
        final cachedScores = _storageService.getQuizScores();
        if (cachedScores != null && refresh) {
          _userScores = cachedScores
              .map((item) => ScoreModel.fromMap(item))
              .toList();
        }
      } catch (cacheError) {
        debugPrint('Failed to load scores from cache: $cacheError');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Load more user scores
  Future<void> loadMoreUserScores() async {
    if (_isLoadingMore || !_hasMoreScores) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _apiService.getScores(
        page: _currentScorePage,
        limit: _pageSize,
      );

      if (response['success'] == true && response['data'] != null) {
        final scores = (response['data'] as List)
            .map((item) => ScoreModel.fromMap(item))
            .toList();

        _userScores.addAll(scores);
        _hasMoreScores = scores.length == _pageSize;
        _currentScorePage++;
      }
    } catch (e) {
      _setError('Gagal memuat data tambahan: ${e.toString()}');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load leaderboard
  Future<void> loadLeaderboard({
    String? level,
    String period = 'all',
    int limit = 50,
  }) async {
    try {
      final response = await _apiService.getLeaderboard(
        level: level ?? 'all',
        limit: limit,
      );

      if (response['success'] == true && response['data'] != null) {
        _leaderboard = (response['data'] as List)
            .map((item) => ScoreModel.fromMap(item))
            .toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading leaderboard: $e');
    }
  }

  // Load quiz statistics
  Future<void> loadStatistics() async {
    try {
      final response = await _apiService.getUserStats();
      if (response['success'] == true && response['data'] != null) {
        _statistics = response['data'];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  // Set selected level
  void setSelectedLevel(String level) {
    _selectedLevel = level;
    notifyListeners();
  }

  // Set selected category
  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  // Set time limit
  void setTimeLimit(int? timeLimit) {
    _timeLimit = timeLimit;
    notifyListeners();
  }

  // Timer management
  void _startTimer() {
    _stopTimer();

    _quizTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        notifyListeners();
      } else {
        // Time's up - auto submit
        timer.cancel();
        submitQuiz();
      }
    });
  }

  void _stopTimer() {
    _quizTimer?.cancel();
    _quizTimer = null;
  }

  // Save session progress
  Future<void> _saveSessionProgress() async {
    if (_currentSessionId != null) {
      final sessionData = {
        'sessionId': _currentSessionId,
        'userAnswers': _userAnswers,
        'startTime': _startTime?.millisecondsSinceEpoch,
        'selectedLevel': _selectedLevel,
        'timeLimit': _timeLimit,
      };
      await _storageService.setString(
        'current_quiz_session',
        jsonEncode(sessionData),
      );
    }
  }

  // Get quiz results
  Map<String, dynamic> getQuizResults() {
    if (_lastQuizScore == null) return {};

    final scoreModel = _lastQuizScore!;
    final salah = scoreModel.totalSoal - scoreModel.benar;
    final percentage = (scoreModel.benar / scoreModel.totalSoal * 100).round();

    String grade = 'F';
    if (percentage >= 90) {
      grade = 'A';
    } else if (percentage >= 80) {
      grade = 'B';
    } else if (percentage >= 70) {
      grade = 'C';
    } else if (percentage >= 60) {
      grade = 'D';
    }

    return {
      'skor': scoreModel.skor,
      'total_soal': scoreModel.totalSoal,
      'benar': scoreModel.benar,
      'salah': salah,
      'percentage': percentage,
      'grade': grade,
      'duration': _timeLimit != null
          ? (_timeLimit! - _remainingTime.inSeconds)
          : 0,
      'level': scoreModel.level,
    };
  }

  // Get question review data
  List<Map<String, dynamic>> getQuestionReview() {
    if (_questions.isEmpty || _userAnswers.isEmpty) return [];

    return _questions.asMap().entries.map((entry) {
      final index = entry.key;
      final question = entry.value;
      final userAnswer = _userAnswers[index];

      // Find correct answer index from options
      int correctAnswerIndex = -1;
      final options = [
        question.pilihanA,
        question.pilihanB,
        question.pilihanC,
        question.pilihanD,
      ];
      for (int i = 0; i < options.length; i++) {
        if (options[i] == question.jawabanBenar) {
          correctAnswerIndex = i;
          break;
        }
      }

      final isCorrect = userAnswer == correctAnswerIndex;

      return {
        'question': question,
        'userAnswer': userAnswer,
        'correctAnswer': correctAnswerIndex,
        'isCorrect': isCorrect,
        'userAnswerText': userAnswer != null && userAnswer < options.length
            ? options[userAnswer]
            : 'Tidak dijawab',
        'correctAnswerText': question.jawabanBenar,
      };
    }).toList();
  }

  // Get user rank in leaderboard
  int? getUserRankInLeaderboard(String userId) {
    final index = _leaderboard.indexWhere((score) => score.userId == userId);
    return index != -1 ? index + 1 : null;
  }

  // Get user's best score for level
  ScoreModel? getBestScoreForLevel(String level) {
    final levelScores = _userScores
        .where((score) => score.level == level)
        .toList();
    if (levelScores.isEmpty) return null;

    levelScores.sort((a, b) => b.score.compareTo(a.score));
    return levelScores.first;
  }

  // Get user's average score for level
  double getAverageScoreForLevel(String level) {
    final levelScores = _userScores
        .where((score) => score.level == level)
        .toList();
    if (levelScores.isEmpty) return 0.0;

    final totalScore = levelScores.fold<double>(
      0.0,
      (sum, score) => sum + score.skor.toDouble(),
    );
    return totalScore / levelScores.length;
  }

  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadUserScores(refresh: true),
      loadLeaderboard(),
      loadStatistics(),
    ]);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Validation helpers
  bool get hasValidationErrors => _validationErrors.isNotEmpty;

  String? getValidationError(String field) {
    return _validationErrors[field];
  }

  // Loading state helpers
  bool get isLoadingQuestions => _isLoading && _state == QuizState.loading;
  bool get isLoadingScores => _isLoading && _userScores.isEmpty;
  bool get isLoadingLeaderboard => _leaderboard.isEmpty;
  bool get isLoadingStatistics => _statistics.isEmpty;

  Map<String, dynamic>? get userStatistics {
    if (_userScores.isEmpty) return null;
    
    final totalQuizzes = _userScores.length;
    final totalScore = _userScores.fold<double>(0, (sum, score) => sum + score.skor);
    final averageScore = totalQuizzes > 0 ? totalScore / totalQuizzes : 0.0;
    
    return {
      'totalQuizzes': totalQuizzes,
      'averageScore': averageScore,
      'recentScores': _userScores.take(5).toList(),
    };
  }

  // Clear cache
  Future<void> clearCache() async {
    // Clear cached quiz data
    await _storageService.remove('current_quiz_session');
    // Clear other cached data as needed
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  Future<void> loadQuizLevel() async {
    try {
      await loadUserScores(refresh: true);
    } catch (e) {
      debugPrint('Error loading quiz level: $e');
    }
  }

  void loadQuizQuestion(String quizId) {
    // TODO: Implement load quiz question
  }

  Future<void> loadUserStatistics() async {
    try {
      await loadUserScores(refresh: true);
      await loadLeaderboard();
    } catch (e) {
      debugPrint('Error loading user statistics: $e');
    }
  }
}
