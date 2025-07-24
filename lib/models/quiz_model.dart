class Quiz {
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

  Quiz({
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

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id']?.toString() ?? '',
      soal: json['soal']?.toString() ?? '',
      pilihanA: json['pilihan_a']?.toString() ?? '',
      pilihanB: json['pilihan_b']?.toString() ?? '',
      pilihanC: json['pilihan_c']?.toString() ?? '',
      pilihanD: json['pilihan_d']?.toString() ?? '',
      jawabanBenar: json['jawaban_benar']?.toString() ?? '',
      level: json['level']?.toString() ?? 'mudah',
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

  @override
  String toString() {
    return 'Quiz(id: $id, soal: $soal, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quiz && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods
  String get levelDisplayName {
    switch (level) {
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
}