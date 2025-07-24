class User {
  final String id;
  final String name;
  final String email;
  final String? kelas;
  final String? foto;
  final String? phone;
  final String? bio;
  final String role;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime? emailVerifiedAt;
  final String? password;
  final String? rememberToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  double progressPercentage;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.kelas,
    this.foto,
    this.phone,
    this.bio,
    this.role = 'siswa',
    this.isActive = true,
    this.lastLoginAt,
    this.emailVerifiedAt,
    this.password,
    this.rememberToken,
    required this.createdAt,
    required this.updatedAt,
    this.progressPercentage = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      kelas: json['kelas']?.toString(),
      foto: json['foto']?.toString(),
      phone: json['phone']?.toString(),
      bio: json['bio']?.toString(),
      role: json['role']?.toString() ?? 'siswa',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'].toString())
          : null,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'].toString())
          : null,
      password: json['password']?.toString(),
      rememberToken: json['remember_token']?.toString(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      progressPercentage: (json['progress_percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'kelas': kelas,
      'foto': foto,
      'phone': phone,
      'bio': bio,
      'role': role,
      'is_active': isActive,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'password': password,
      'remember_token': rememberToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? kelas,
    String? foto,
    String? phone,
    String? bio,
    String? role,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? emailVerifiedAt,
    String? password,
    String? rememberToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      kelas: kelas ?? this.kelas,
      foto: foto ?? this.foto,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      password: password ?? this.password,
      rememberToken: rememberToken ?? this.rememberToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods
  bool get isSiswa => role == 'siswa';
  bool get isAdmin => role == 'admin';
  bool get canManageTools => isAdmin;
  bool get canManageUsers => isAdmin;
  
  // Legacy compatibility
  bool get isStudent => role == 'siswa';
  bool get isTeacher => role == 'admin';

  String get displayName => name.isNotEmpty ? name : email;
  String get initials {
    if (name.isEmpty) return email.substring(0, 1).toUpperCase();
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  get completedQuiz => null;

  get totalQuiz => null;
}

class UserStatistics {
  final int totalQuizTaken;
  final double averageScore;
  final int totalToolsViewed;
  final int totalVideosWatched;
  final int currentStreak;
  final int longestStreak;
  final Map<String, int> quizScoresByLevel;
  final List<Achievement> achievements;
  final DateTime lastActivity;

  UserStatistics({
    this.totalQuizTaken = 0,
    this.averageScore = 0.0,
    this.totalToolsViewed = 0,
    this.totalVideosWatched = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.quizScoresByLevel = const {},
    this.achievements = const [],
    required this.lastActivity,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalQuizTaken: json['total_quiz_taken']?.toInt() ?? 0,
      averageScore: json['average_score']?.toDouble() ?? 0.0,
      totalToolsViewed: json['total_tools_viewed']?.toInt() ?? 0,
      totalVideosWatched: json['total_videos_watched']?.toInt() ?? 0,
      currentStreak: json['current_streak']?.toInt() ?? 0,
      longestStreak: json['longest_streak']?.toInt() ?? 0,
      quizScoresByLevel: Map<String, int>.from(
        json['quiz_scores_by_level'] ?? {},
      ),
      achievements: (json['achievements'] as List<dynamic>? ?? [])
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastActivity:
          DateTime.tryParse(json['last_activity']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_quiz_taken': totalQuizTaken,
      'average_score': averageScore,
      'total_tools_viewed': totalToolsViewed,
      'total_videos_watched': totalVideosWatched,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'quiz_scores_by_level': quizScoresByLevel,
      'achievements': achievements.map((e) => e.toJson()).toList(),
      'last_activity': lastActivity.toIso8601String(),
    };
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime unlockedAt;
  final String category;
  final int points;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.unlockedAt,
    required this.category,
    this.points = 0,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      unlockedAt:
          DateTime.tryParse(json['unlocked_at']?.toString() ?? '') ??
          DateTime.now(),
      category: json['category']?.toString() ?? '',
      points: json['points']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'unlocked_at': unlockedAt.toIso8601String(),
      'category': category,
      'points': points,
    };
  }
}
