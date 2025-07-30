class QuizQuestion {
  final String id;
  final String soal;
  final String pilihanA;
  final String pilihanB;
  final String pilihanC;
  final String pilihanD;
  final String jawabanBenar;
  final String level;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuizQuestion({
    required this.id,
    required this.soal,
    required this.pilihanA,
    required this.pilihanB,
    required this.pilihanC,
    required this.pilihanD,
    required this.jawabanBenar,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id']?.toString() ?? '',
      soal: json['soal']?.toString() ?? '',
      pilihanA: json['pilihan_a']?.toString() ?? '',
      pilihanB: json['pilihan_b']?.toString() ?? '',
      pilihanC: json['pilihan_c']?.toString() ?? '',
      pilihanD: json['pilihan_d']?.toString() ?? '',
      jawabanBenar: json['jawaban_benar']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'soal': soal,
      'pilihan_a': pilihanA,
      'pilihan_b': pilihanB,
      'pilihan_c': pilihanC,
      'pilihan_d': pilihanD,
      'jawaban_benar': jawabanBenar,
      'level': level,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper method to get all options as a map
  Map<String, String> get pilihan {
    return {
      'a': pilihanA,
      'b': pilihanB,
      'c': pilihanC,
      'd': pilihanD,
    };
  }

  // Helper method to get options as a list
  List<String> get pilihanList {
    return [pilihanA, pilihanB, pilihanC, pilihanD];
  }

  // Check if the given answer is correct
  bool isCorrectAnswer(String answer) {
    return jawabanBenar.toLowerCase() == answer.toLowerCase();
  }

  // Get the correct answer text
  String get correctAnswerText {
    switch (jawabanBenar.toLowerCase()) {
      case 'a':
        return pilihanA;
      case 'b':
        return pilihanB;
      case 'c':
        return pilihanC;
      case 'd':
        return pilihanD;
      default:
        return '';
    }
  }

  String get levelDisplayName {
    switch (level.toLowerCase()) {
      case 'mudah':
        return 'Mudah';
      case 'sedang':
        return 'Sedang';
      case 'sulit':
        return 'Sulit';
      default:
        return level;
    }
  }

  QuizQuestion copyWith({
    String? id,
    String? soal,
    String? pilihanA,
    String? pilihanB,
    String? pilihanC,
    String? pilihanD,
    String? jawabanBenar,
    String? level,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      soal: soal ?? this.soal,
      pilihanA: pilihanA ?? this.pilihanA,
      pilihanB: pilihanB ?? this.pilihanB,
      pilihanC: pilihanC ?? this.pilihanC,
      pilihanD: pilihanD ?? this.pilihanD,
      jawabanBenar: jawabanBenar ?? this.jawabanBenar,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'QuizQuestion(id: $id, soal: $soal, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizQuestion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}