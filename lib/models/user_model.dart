class UserModel {
  final String id;
  final String name;
  final String className;
  final String profileImageUrl;
  final int completedQuizzes;
  final int totalQuizzes;

  UserModel({
    required this.id,
    required this.name,
    required this.className,
    required this.profileImageUrl,
    required this.completedQuizzes,
    required this.totalQuizzes,
  });

  double get progressPercentage =>
      totalQuizzes > 0 ? (completedQuizzes / totalQuizzes) * 100 : 0;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      className: map['kelas'] ?? map['className'] ?? '', // fallback
      profileImageUrl:
          map['foto'] ??
          map['profileImageUrl'] ??
          map['profile_image_url'] ??
          '',
      completedQuizzes:
          (map['completed_quizzes'] ?? map['completedQuizzes'] ?? 0).toInt(),
      totalQuizzes: (map['total_quizzes'] ?? map['totalQuizzes'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'className': className,
      'profileImageUrl': profileImageUrl,
      'completedQuizzes': completedQuizzes,
      'totalQuizzes': totalQuizzes,
    };
  }
}
