// Note: Video class moved to domain/entities/video.dart to avoid conflicts

class Video {
  final String id;
  final String judul;
  final String deskripsi;
  final String youtubeUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Video({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.youtubeUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id']?.toString() ?? '',
      judul: json['judul']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      youtubeUrl: json['youtube_url']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'youtube_url': youtubeUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  String? get youtubeId {
    final regex = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})');
    final match = regex.firstMatch(youtubeUrl);
    return match?.group(1);
  }

  String? get thumbnail {
    final videoId = youtubeId;
    if (videoId == null) return null;
    return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
  }

  Video copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    String? youtubeUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Video(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Video(id: $id, judul: $judul)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Video && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}