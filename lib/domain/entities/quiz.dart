// Quiz Level enum
enum QuizLevel { easy, medium, hard }

// Extension for QuizLevel
extension QuizLevelExtension on QuizLevel {
  String get displayName {
    switch (this) {
      case QuizLevel.easy:
        return 'Mudah';
      case QuizLevel.medium:
        return 'Sedang';
      case QuizLevel.hard:
        return 'Sulit';
    }
  }

  String get description {
    switch (this) {
      case QuizLevel.easy:
        return 'Pertanyaan dasar untuk pemula';
      case QuizLevel.medium:
        return 'Pertanyaan menengah untuk yang sudah paham';
      case QuizLevel.hard:
        return 'Pertanyaan sulit untuk yang ahli';
    }
  }

  String get value {
    switch (this) {
      case QuizLevel.easy:
        return 'mudah';
      case QuizLevel.medium:
        return 'sedang';
      case QuizLevel.hard:
        return 'sulit';
    }
  }

  static QuizLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'mudah':
      case 'easy':
        return QuizLevel.easy;
      case 'sedang':
      case 'medium':
        return QuizLevel.medium;
      case 'sulit':
      case 'hard':
        return QuizLevel.hard;
      default:
        return QuizLevel.easy;
    }
  }
}

// Quiz Question class
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;
  final String? imageUrl;
  final QuizLevel level;
  final String? categoryId;
  final String? categoryName;
  final List<String> tags;
  final int points;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    this.imageUrl,
    required this.level,
    this.categoryId,
    this.categoryName,
    this.tags = const [],
    this.points = 10,
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  // Create QuizQuestion from JSON
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: json['options'] != null
          ? List<String>.from(json['options'].map((x) => x.toString()))
          : [],
      correctAnswerIndex:
          json['correct_answer_index'] ?? json['correctAnswerIndex'] ?? 0,
      explanation: json['explanation']?.toString(),
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      level: QuizLevelExtension.fromString(json['level']?.toString() ?? 'easy'),
      categoryId:
          json['category_id']?.toString() ?? json['categoryId']?.toString(),
      categoryName:
          json['category_name']?.toString() ?? json['categoryName']?.toString(),
      tags: json['tags'] != null
          ? List<String>.from(json['tags'].map((x) => x.toString()))
          : [],
      points: json['points'] ?? 10,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdBy:
          json['created_by']?.toString() ?? json['createdBy']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert QuizQuestion to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_answer_index': correctAnswerIndex,
      'explanation': explanation,
      'image_url': imageUrl,
      'level': level.value,
      'category_id': categoryId,
      'category_name': categoryName,
      'tags': tags,
      'points': points,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Copy with method
  QuizQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswerIndex,
    String? explanation,
    String? imageUrl,
    QuizLevel? level,
    String? categoryId,
    String? categoryName,
    List<String>? tags,
    int? points,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanation: explanation ?? this.explanation,
      imageUrl: imageUrl ?? this.imageUrl,
      level: level ?? this.level,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      tags: tags ?? this.tags,
      points: points ?? this.points,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get correct answer text
  String get correctAnswer {
    if (correctAnswerIndex >= 0 && correctAnswerIndex < options.length) {
      return options[correctAnswerIndex];
    }
    return '';
  }

  // Get option labels (A, B, C, D)
  List<String> get optionLabels {
    return ['A', 'B', 'C', 'D'];
  }

  // Get formatted options with labels
  List<String> get formattedOptions {
    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final label = index < optionLabels.length
          ? optionLabels[index]
          : '${index + 1}';
      return '$label. $option';
    }).toList();
  }

  // Check if answer is correct
  bool isCorrectAnswer(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }

  // Get display image URL
  String? get displayImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // If it's already a full URL, return as is
      if (imageUrl!.startsWith('http')) {
        return imageUrl;
      }
      // Otherwise, construct the full URL
      return imageUrl;
    }
    return null;
  }

  // Check if question has image
  bool get hasImage {
    return displayImageUrl != null;
  }

  // Get short question (for lists)
  String get shortQuestion {
    if (question.length <= 80) return question;
    return '${question.substring(0, 77)}...';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizQuestion &&
        other.id == id &&
        other.question == question;
  }

  @override
  int get hashCode {
    return Object.hash(id, question);
  }

  @override
  String toString() {
    return 'QuizQuestion(id: $id, level: ${level.displayName}, points: $points)';
  }
}

// Quiz Session class
class QuizSession {
  final String id;
  final String userId;
  final QuizLevel level;
  final List<QuizQuestion> questions;
  final List<int?> userAnswers;
  final DateTime startTime;
  final DateTime? endTime;
  final int? timeLimit; // in seconds
  final bool isCompleted;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double percentage;
  final Map<String, dynamic>? metadata;

  const QuizSession({
    required this.id,
    required this.userId,
    required this.level,
    required this.questions,
    required this.userAnswers,
    required this.startTime,
    this.endTime,
    this.timeLimit,
    this.isCompleted = false,
    this.score = 0,
    required this.totalQuestions,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.percentage = 0.0,
    this.metadata,
  });

  // Create QuizSession from JSON
  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      level: QuizLevelExtension.fromString(json['level']?.toString() ?? 'easy'),
      questions: json['questions'] != null
          ? List<QuizQuestion>.from(
              json['questions'].map((x) => QuizQuestion.fromJson(x)),
            )
          : [],
      userAnswers: json['user_answers'] != null
          ? List<int?>.from(json['user_answers'].map((x) => x as int?))
          : [],
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'].toString())
          : DateTime.now(),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'].toString())
          : null,
      timeLimit: json['time_limit'] ?? json['timeLimit'],
      isCompleted: json['is_completed'] ?? json['isCompleted'] ?? false,
      score: json['skor'] ?? json['score'] ?? 0,
      totalQuestions:
          json['total_soal'] ??
          json['total_questions'] ??
          json['totalQuestions'] ??
          0,
      correctAnswers:
          json['benar'] ??
          json['correct_answers'] ??
          json['correctAnswers'] ??
          0,
      wrongAnswers:
          json['salah'] ?? json['wrong_answers'] ?? json['wrongAnswers'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert QuizSession to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'level': level.value,
      'questions': questions.map((x) => x.toJson()).toList(),
      'user_answers': userAnswers,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'time_limit': timeLimit,
      'is_completed': isCompleted,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'percentage': percentage,
      'metadata': metadata,
    };
  }

  // Copy with method
  QuizSession copyWith({
    String? id,
    String? userId,
    QuizLevel? level,
    List<QuizQuestion>? questions,
    List<int?>? userAnswers,
    DateTime? startTime,
    DateTime? endTime,
    int? timeLimit,
    bool? isCompleted,
    int? score,
    int? totalQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    double? percentage,
    Map<String, dynamic>? metadata,
  }) {
    return QuizSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      level: level ?? this.level,
      questions: questions ?? this.questions,
      userAnswers: userAnswers ?? this.userAnswers,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeLimit: timeLimit ?? this.timeLimit,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      percentage: percentage ?? this.percentage,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get duration of quiz session
  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }

  // Get formatted duration
  String get formattedDuration {
    final dur = duration;
    if (dur == null) return 'Belum selesai';

    final minutes = dur.inMinutes;
    final seconds = dur.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }

  // Get remaining time if time limit is set
  Duration? getRemainingTime() {
    if (timeLimit == null || isCompleted) return null;

    final elapsed = DateTime.now().difference(startTime);
    final remaining = Duration(seconds: timeLimit!) - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  // Get formatted remaining time
  String getFormattedRemainingTime() {
    final remaining = getRemainingTime();
    if (remaining == null) return '';

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Check if time is up
  bool get isTimeUp {
    if (timeLimit == null) return false;
    final remaining = getRemainingTime();
    return remaining == Duration.zero;
  }

  // Get progress percentage
  double get progress {
    if (totalQuestions == 0) return 0.0;
    final answered = userAnswers.where((answer) => answer != null).length;
    return answered / totalQuestions;
  }

  // Get current question index
  int get currentQuestionIndex {
    final answered = userAnswers.where((answer) => answer != null).length;
    return answered < totalQuestions ? answered : totalQuestions - 1;
  }

  // Check if all questions are answered
  bool get isAllAnswered {
    return userAnswers.every((answer) => answer != null);
  }

  // Get grade based on percentage
  String get grade {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'E';
  }

  // Get grade description
  String get gradeDescription {
    switch (grade) {
      case 'A':
        return 'Sangat Baik';
      case 'B':
        return 'Baik';
      case 'C':
        return 'Cukup';
      case 'D':
        return 'Kurang';
      case 'E':
        return 'Sangat Kurang';
      default:
        return 'Tidak Diketahui';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizSession && other.id == id && other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId);
  }

  @override
  String toString() {
    return 'QuizSession(id: $id, level: ${level.displayName}, score: $score/$totalQuestions)';
  }
}

// Quiz Score/Result class
class QuizScore {
  final String id;
  final String userId;
  final String userName;
  final QuizLevel level;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double percentage;
  final String grade;
  final Duration duration;
  final DateTime completedAt;
  final Map<String, dynamic>? metadata;

  const QuizScore({
    required this.id,
    required this.userId,
    required this.userName,
    required this.level,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.percentage,
    required this.grade,
    required this.duration,
    required this.completedAt,
    this.metadata,
  });

  // Create QuizScore from JSON
  factory QuizScore.fromJson(Map<String, dynamic> json) {
    return QuizScore(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      userName:
          json['user_name']?.toString() ?? json['userName']?.toString() ?? '',
      level: QuizLevelExtension.fromString(json['level']?.toString() ?? 'easy'),
      score: json['skor'] ?? json['score'] ?? 0,
      totalQuestions:
          json['total_soal'] ??
          json['total_questions'] ??
          json['totalQuestions'] ??
          0,
      correctAnswers:
          json['benar'] ??
          json['correct_answers'] ??
          json['correctAnswers'] ??
          0,
      wrongAnswers:
          json['salah'] ?? json['wrong_answers'] ?? json['wrongAnswers'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      grade: json['grade']?.toString() ?? 'E',
      duration: Duration(seconds: json['duration'] ?? 0),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'].toString())
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert QuizScore to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'level': level.value,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'wrong_answers': wrongAnswers,
      'percentage': percentage,
      'grade': grade,
      'duration': duration.inSeconds,
      'completed_at': completedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Get formatted duration
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }

  // Get formatted score
  String get formattedScore {
    return '$score/$totalQuestions';
  }

  // Get formatted percentage
  String get formattedPercentage {
    return '${percentage.toStringAsFixed(1)}%';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizScore && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    return 'QuizScore(id: $id, userName: $userName, score: $formattedScore, grade: $grade)';
  }
}
