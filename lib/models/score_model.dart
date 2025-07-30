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
  final String? userName;
  final String? userClass;

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
    this.userName,
    this.userClass,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      skor: json['skor']?.toInt() ?? 0,
      totalSoal: json['total_soal']?.toInt() ?? 0,
      benar: json['benar']?.toInt() ?? 0,
      salah: json['salah']?.toInt() ?? 0,
      tanggal: DateTime.tryParse(json['tanggal']?.toString() ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      userName: json['user_name']?.toString(),
      userClass: json['user_class']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
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
      if (userName != null) 'user_name': userName,
      if (userClass != null) 'user_class': userClass,
    };
  }

  // Alias methods for compatibility
  factory ScoreModel.fromMap(Map<String, dynamic> map) => ScoreModel.fromJson(map);
  Map<String, dynamic> toMap() => toJson();

  // Getter for compatibility with quiz_provider
  int get score => skor;

  // Computed properties
  double get percentage {
    if (totalSoal == 0) return 0.0;
    return (benar / totalSoal) * 100;
  }

  String get formattedPercentage {
    return '${percentage.toStringAsFixed(1)}%';
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

  String get grade {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'E';
  }

  bool get isPassed {
    return percentage >= 60;
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
      userName: userName ?? this.userName,
      userClass: userClass ?? this.userClass,
    );
  }

  @override
  String toString() {
    return 'ScoreModel(id: $id, userId: $userId, level: $level, skor: $skor, percentage: ${formattedPercentage})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScoreModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
