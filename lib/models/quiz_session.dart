class QuizSession {
  final String id;
  final String userId;
  final String level;
  final String? categoryId;
  final int? timeLimit;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final int currentQuestionIndex;
  final List<int?> userAnswers;
  final int? score;
  final int? totalQuestions;

  QuizSession({
    required this.id,
    required this.userId,
    required this.level,
    this.categoryId,
    this.timeLimit,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.currentQuestionIndex = 0,
    this.userAnswers = const [],
    this.score,
    this.totalQuestions,
  });

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      categoryId: json['category_id']?.toString(),
      timeLimit: json['time_limit'] as int?,
      startTime: DateTime.tryParse(json['start_time']?.toString() ?? '') ?? DateTime.now(),
      endTime: json['end_time'] != null ? DateTime.tryParse(json['end_time'].toString()) : null,
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
      currentQuestionIndex: json['current_question_index'] as int? ?? 0,
      userAnswers: (json['user_answers'] as List<dynamic>?)?.map((e) => e as int?).toList() ?? [],
      score: json['score'] as int?,
      totalQuestions: json['total_questions'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'level': level,
      'category_id': categoryId,
      'time_limit': timeLimit,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'is_completed': isCompleted,
      'current_question_index': currentQuestionIndex,
      'user_answers': userAnswers,
      'score': score,
      'total_questions': totalQuestions,
    };
  }

  QuizSession copyWith({
    String? id,
    String? userId,
    String? level,
    String? categoryId,
    int? timeLimit,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    int? currentQuestionIndex,
    List<int?>? userAnswers,
    int? score,
    int? totalQuestions,
  }) {
    return QuizSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      level: level ?? this.level,
      categoryId: categoryId ?? this.categoryId,
      timeLimit: timeLimit ?? this.timeLimit,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
    );
  }

  @override
  String toString() {
    return 'QuizSession(id: $id, level: $level, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}