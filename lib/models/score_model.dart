class Score {
  final String id;
  final String userId;
  final int skor;
  final int totalSoal;
  final int benar;
  final int salah;
  final String level;
  final DateTime tanggal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Score({
    required this.id,
    required this.userId,
    required this.skor,
    required this.totalSoal,
    required this.benar,
    required this.salah,
    required this.level,
    required this.tanggal,
    this.createdAt,
    this.updatedAt,
  });

  factory Score.fromMap(Map<String, dynamic> map) {
    return Score(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      skor: map['skor'] ?? 0,
      totalSoal: map['total_soal'] ?? 0,
      benar: map['benar'] ?? 0,
      salah: map['salah'] ?? 0,
      level: map['level'] ?? '',
      tanggal: map['tanggal'] != null 
          ? DateTime.parse(map['tanggal'])
          : DateTime.now(),
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'skor': skor,
      'total_soal': totalSoal,
      'benar': benar,
      'salah': salah,
      'level': level,
      'tanggal': tanggal.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Score(id: $id, userId: $userId, skor: $skor, totalSoal: $totalSoal, benar: $benar, salah: $salah, level: $level, tanggal: $tanggal)';
  }
}