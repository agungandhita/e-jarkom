class ScoreModel {
  final String id;
  final String userId;
  final String level;
  final int skor;
  final int totalSoal;
  final int benar;
  final int salah;
  final DateTime tanggal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userName;
  final String? userClass;

  // Computed properties
  double get percentage => totalSoal > 0 ? (benar / totalSoal * 100) : 0.0;

  // Compatibility getters for existing code
  int get score => skor;
  int get totalQuestions => totalSoal;
  int get correctAnswers => benar;
  int get wrongAnswers => salah;

  ScoreModel({
    required this.id,
    required this.userId,
    required this.level,
    required this.skor,
    required this.totalSoal,
    required this.benar,
    required this.salah,
    required this.tanggal,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userClass,
  });

  factory ScoreModel.fromMap(Map<String, dynamic> map) {
    return ScoreModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      level: map['level']?.toString() ?? '',
      skor: map['skor'] ?? 0,
      totalSoal: map['total_soal'] ?? 0,
      benar: map['benar'] ?? 0,
      salah: map['salah'] ?? 0,
      tanggal:
          DateTime.tryParse(map['tanggal']?.toString() ?? '') ?? DateTime.now(),
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      userName: map['user_name'] ?? map['nama_user'] ?? map['user']?['name'],
      userClass:
          map['user_class'] ?? map['kelas_user'] ?? map['user']?['kelas'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'level': level,
      'skor': skor,
      'total_soal': totalSoal,
      'benar': benar,
      'salah': salah,
      'tanggal': tanggal.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (userName != null) 'user_name': userName,
      if (userClass != null) 'user_class': userClass,
    };
  }

  ScoreModel copyWith({
    String? id,
    String? userId,
    String? level,
    int? skor,
    int? totalSoal,
    int? benar,
    int? salah,
    DateTime? tanggal,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userClass,
  }) {
    return ScoreModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      level: level ?? this.level,
      skor: skor ?? this.skor,
      totalSoal: totalSoal ?? this.totalSoal,
      benar: benar ?? this.benar,
      salah: salah ?? this.salah,
      tanggal: tanggal ?? this.tanggal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userClass: userClass ?? this.userClass,
    );
  }

  @override
  String toString() {
    return 'ScoreModel(id: $id, userId: $userId, level: $level, skor: $skor, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScoreModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
