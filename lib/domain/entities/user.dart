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
  final int progressPercentage;

  const User({
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

  // Create User from JSON
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
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at'].toString())
          : null,
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.parse(json['email_verified_at'].toString())
          : null,
      password: json['password']?.toString(),
      rememberToken: json['remember_token']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      progressPercentage: json['progress_percentage'] ?? json['progressPercentage'] ?? 0,
    );
  }

  // Convert User to JSON
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
      'progress_percentage': progressPercentage,
    };
  }

  // Copy with method for updating user data
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
    int? progressPercentage,
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
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  // Check if user is admin
  bool get isAdmin => role.toLowerCase() == 'admin';

  // Check if user is siswa
  bool get isSiswa => role.toLowerCase() == 'siswa';

  // Legacy compatibility
  bool get isModerator => role.toLowerCase() == 'admin';
  bool get isUser => role.toLowerCase() == 'siswa';
  bool get isStudent => role.toLowerCase() == 'siswa';
  bool get isTeacher => role.toLowerCase() == 'admin';

  // Permission helpers
  bool get canManageTools => isAdmin;
  bool get canManageUsers => isAdmin;

  // Get display name
  String get displayName {
    if (name.isNotEmpty) return name;
    return email.split('@').first;
  }

  // Get initials for avatar
  String get initials {
    final nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty && nameParts.first.isNotEmpty) {
      return nameParts.first[0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  // Get profile image URL or null
  String? get profileImageUrl {
    if (foto != null && foto!.isNotEmpty) {
      // If it's already a full URL, return as is
      if (foto!.startsWith('http')) {
        return foto;
      }
      // Otherwise, construct the full URL
      // This should be adjusted based on your backend configuration
      return '${foto}';
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.kelas == kelas &&
        other.foto == foto &&
        other.bio == bio &&
        other.role == role &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      email,
      phone,
      kelas,
      foto,
      bio,
      role,
      createdAt,
      updatedAt,
      isActive,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }

  // Get sample users for testing/demo
  static List<User> getSampleUsers() {
    return [
      User(
        id: '1',
        name: 'Admin User',
        email: 'admin@ejarkom.com',
        phone: '081234567890',
        foto: 'https://example.com/admin.jpg',
        bio: 'Administrator sistem e-jarkom',
        role: 'admin',
        kelas: null,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
        lastLoginAt: DateTime.now().subtract(const Duration(hours: 1)),
        emailVerifiedAt: DateTime.now().subtract(const Duration(days: 364)),
        progressPercentage: 100,
      ),
      User(
        id: '2',
        name: 'John Doe',
        email: 'john.doe@student.com',
        phone: '081234567891',
        foto: 'https://example.com/john.jpg',
        bio: 'Mahasiswa Teknik Informatika yang antusias belajar jaringan komputer',
        role: 'user',
        kelas: 'TI-3A',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        isActive: true,
        lastLoginAt: DateTime.now().subtract(const Duration(days: 2)),
        emailVerifiedAt: DateTime.now().subtract(const Duration(days: 119)),
        progressPercentage: 75,
      ),
      User(
        id: '3',
        name: 'Jane Smith',
        email: 'jane.smith@student.com',
        phone: '081234567892',
        foto: null,
        bio: 'Suka belajar tentang cybersecurity dan ethical hacking',
        role: 'user',
        kelas: 'TI-3B',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
        lastLoginAt: DateTime.now().subtract(const Duration(hours: 6)),
        emailVerifiedAt: DateTime.now().subtract(const Duration(days: 89)),
        progressPercentage: 85,
      ),
      User(
        id: '4',
        name: 'Bob Wilson',
        email: 'bob.wilson@moderator.com',
        phone: '081234567893',
        foto: 'https://example.com/bob.jpg',
        bio: 'Moderator konten dan asisten dosen',
        role: 'moderator',
        kelas: null,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        isActive: true,
        lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
        emailVerifiedAt: DateTime.now().subtract(const Duration(days: 199)),
        progressPercentage: 90,
      ),
      User(
        id: '5',
        name: 'Alice Brown',
        email: 'alice.brown@student.com',
        phone: null,
        foto: 'https://example.com/alice.jpg',
        bio: null,
        role: 'user',
        kelas: 'TI-2A',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        isActive: false,
        lastLoginAt: DateTime.now().subtract(const Duration(days: 15)),
        emailVerifiedAt: null,
        progressPercentage: 25,
      ),
      User(
        id: '6',
        name: 'Charlie Davis',
        email: 'charlie.davis@student.com',
        phone: '081234567894',
        foto: null,
        bio: 'Tertarik dengan network automation dan DevOps',
        role: 'user',
        kelas: 'TI-3C',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
        isActive: true,
        lastLoginAt: DateTime.now().subtract(const Duration(minutes: 30)),
        emailVerifiedAt: DateTime.now().subtract(const Duration(days: 44)),
        progressPercentage: 60,
      ),
    ];
  }
}

// User roles enum for better type safety
enum UserRole {
  admin('admin'),
  moderator('moderator'),
  user('user');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'moderator':
        return UserRole.moderator;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}