class Video {
  final String id;
  final String judul;
  final String deskripsi;
  final String youtubeUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Video({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.youtubeUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create Video from JSON
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id']?.toString() ?? '',
      judul: json['judul']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      youtubeUrl: json['youtube_url']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  // Convert Video to JSON
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

  // Copy with method for updating video data
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

  // Extract YouTube video ID from URL
  String? get youtubeVideoId {
    if (youtubeUrl.isEmpty) return null;

    final RegExp regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );

    final match = regExp.firstMatch(youtubeUrl);
    return match?.group(1);
  }

  // Get YouTube thumbnail URL
  String? get youtubeThumbnailUrl {
    final videoId = youtubeVideoId;
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    }
    return null;
  }

  // Get short description (for cards)
  String get shortDescription {
    if (deskripsi.length <= 100) return deskripsi;
    return '${deskripsi.substring(0, 97)}...';
  }

  // Check if video has valid YouTube URL
  bool get hasValidYouTubeUrl {
    return youtubeVideoId != null;
  }

  // Search in video content
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return judul.toLowerCase().contains(lowerQuery) ||
        deskripsi.toLowerCase().contains(lowerQuery);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Video &&
        other.id == id &&
        other.judul == judul &&
        other.youtubeUrl == youtubeUrl;
  }

  @override
  int get hashCode {
    return Object.hash(id, judul, youtubeUrl);
  }

  @override
  String toString() {
    return 'Video(id: $id, judul: $judul)';
  }
}

// Video sort options
enum VideoSortBy { newest, oldest, judul }

// Sort order
enum SortOrder { ascending, descending }

// Extension for VideoSortBy
extension VideoSortByExtension on VideoSortBy {
  String get displayName {
    switch (this) {
      case VideoSortBy.newest:
        return 'Terbaru';
      case VideoSortBy.oldest:
        return 'Terlama';
      case VideoSortBy.judul:
        return 'Judul A-Z';
    }
  }

  String get value {
    switch (this) {
      case VideoSortBy.newest:
        return 'created_at';
      case VideoSortBy.oldest:
        return 'created_at';
      case VideoSortBy.judul:
        return 'judul';
    }
  }
}

// Extension for SortOrder
extension SortOrderExtension on SortOrder {
  String get value {
    switch (this) {
      case SortOrder.ascending:
        return 'asc';
      case SortOrder.descending:
        return 'desc';
    }
  }
}
