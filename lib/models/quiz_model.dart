class Quiz {
  final String id;
  final String soal;
  final Map<String, String> pilihan;
  final String jawabanBenar;
  final String level;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.soal,
    required this.pilihan,
    required this.jawabanBenar,
    required this.level,
    required this.createdAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    // Handle pilihan as nested object from Laravel API
    Map<String, String> pilihanMap = {};
    if (json['pilihan'] is Map) {
      final pilihanData = json['pilihan'] as Map<String, dynamic>;
      pilihanMap = {
        'a': pilihanData['a']?.toString() ?? '',
        'b': pilihanData['b']?.toString() ?? '',
        'c': pilihanData['c']?.toString() ?? '',
        'd': pilihanData['d']?.toString() ?? '',
      };
    } else {
      // Fallback for individual fields
      pilihanMap = {
        'a': json['pilihan_a']?.toString() ?? '',
        'b': json['pilihan_b']?.toString() ?? '',
        'c': json['pilihan_c']?.toString() ?? '',
        'd': json['pilihan_d']?.toString() ?? '',
      };
    }

    // Normalize jawaban benar - ensure it's lowercase and trimmed
    final rawJawabanBenar =
        json['jawaban_benar']?.toString() ?? json['jawaban']?.toString() ?? '';
    final normalizedJawabanBenar = rawJawabanBenar.toLowerCase().trim();

    return Quiz(
      id: json['id']?.toString() ?? '',
      soal: json['soal']?.toString() ?? '',
      pilihan: pilihanMap,
      jawabanBenar: normalizedJawabanBenar,
      level: json['level']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'soal': soal,
      'pilihan': pilihan,
      'jawaban_benar': jawabanBenar,
      'level': level,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper getters for individual options
  String get pilihanA => pilihan['a'] ?? '';
  String get pilihanB => pilihan['b'] ?? '';
  String get pilihanC => pilihan['c'] ?? '';
  String get pilihanD => pilihan['d'] ?? '';

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

  Quiz copyWith({
    String? id,
    String? soal,
    Map<String, String>? pilihan,
    String? jawabanBenar,
    String? level,
    DateTime? createdAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      soal: soal ?? this.soal,
      pilihan: pilihan ?? this.pilihan,
      jawabanBenar: jawabanBenar ?? this.jawabanBenar,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
    );
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
}
