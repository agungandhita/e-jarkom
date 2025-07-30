class Tool {
  final String id;
  final String nama;
  final String deskripsi;
  final String fungsi;
  final String? gambar;
  final String? urlVideo;
  final String? filePdf;
  final String? kategori;
  final String? categoryId;
  final String? categoryName;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional properties for enhanced functionality
  final List<String> tags;
  final bool isActive;
  final bool? isFavorited;
  final double rating;
  final int ratingCount;
  final int viewCount;
  final String? createdBy;

  Tool({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.fungsi,
    this.gambar,
    this.urlVideo,
    this.filePdf,
    this.kategori,
    this.categoryId,
    this.categoryName,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.isActive = true,
    this.isFavorited,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.viewCount = 0,
    this.createdBy,
  });

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? json['name']?.toString() ?? '',
      deskripsi:
          json['deskripsi']?.toString() ??
          json['description']?.toString() ??
          '',
      fungsi: json['fungsi']?.toString() ?? json['function']?.toString() ?? '',
      gambar: json['gambar']?.toString() ?? json['image']?.toString(),
      urlVideo: json['url_video']?.toString() ?? json['video_url']?.toString(),
      filePdf: json['file_pdf']?.toString() ?? json['pdf_file']?.toString(),
      kategori: json['kategori']?.toString() ?? json['category']?.toString(),
      categoryId: json['category_id']?.toString(),
      categoryName:
          json['category_name']?.toString() ??
          json['category']?['nama']?.toString(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      tags: _parseStringList(json['tags']),
      isActive: json['is_active'] ?? json['active'] ?? true,
      isFavorited: json['is_favorited'],
      rating: (json['rating'] ?? json['average_rating'] ?? 0.0).toDouble(),
      ratingCount: json['rating_count'] ?? json['total_ratings'] ?? 0,
      viewCount: json['view_count'] ?? json['views'] ?? 0,
      createdBy: json['created_by'] ?? json['author'] ?? 'Admin',
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is String) {
      try {
        // Try to parse as JSON array first
        final decoded = value.trim();
        if (decoded.startsWith('[') && decoded.endsWith(']')) {
          final List<dynamic> list = [];
          // Simple JSON array parsing
          final content = decoded.substring(1, decoded.length - 1);
          if (content.isNotEmpty) {
            final items = content.split(',');
            for (final item in items) {
              final trimmed = item.trim();
              if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
                list.add(trimmed.substring(1, trimmed.length - 1));
              } else {
                list.add(trimmed);
              }
            }
          }
          return List<String>.from(list);
        } else {
          // Split by comma if not JSON
          return value
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (e) {
        // Fallback to comma-separated
        return value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
    if (value is List) {
      return List<String>.from(value.map((e) => e.toString()));
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'fungsi': fungsi,
      'gambar': gambar,
      'url_video': urlVideo,
      'file_pdf': filePdf,
      'kategori': kategori,
      'category_id': categoryId,
      'category_name': categoryName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tags': tags,
      'is_active': isActive,
      if (isFavorited != null) 'is_favorited': isFavorited,
      'rating': rating,
      'rating_count': ratingCount,
      'view_count': viewCount,
      'created_by': createdBy,
    };
  }

  Tool copyWith({
    String? id,
    String? nama,
    String? deskripsi,
    String? fungsi,
    String? gambar,
    String? urlVideo,
    String? filePdf,
    String? kategori,
    String? categoryId,
    String? categoryName,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    bool? isActive,
    bool? isFavorited,
    double? rating,
    int? ratingCount,
    int? viewCount,
    String? createdBy,
  }) {
    return Tool(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      fungsi: fungsi ?? this.fungsi,
      gambar: gambar ?? this.gambar,
      urlVideo: urlVideo ?? this.urlVideo,
      filePdf: filePdf ?? this.filePdf,
      kategori: kategori ?? this.kategori,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      isFavorited: isFavorited ?? this.isFavorited,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      viewCount: viewCount ?? this.viewCount,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  // Helper getters for display
  String get displayName => nama;
  String get displayDescription => deskripsi;
  String get displayFunction => fungsi;
  String get displayCategory =>
      kategori ?? categoryName ?? 'Tidak ada kategori';
  String get displayCategoryName =>
      categoryName ?? kategori ?? 'Tidak ada kategori';

  // Image URL helper
  String? get imageUrl {
    if (gambar == null || gambar!.isEmpty) return null;
    if (gambar!.startsWith('http')) return gambar;
    // Assuming Laravel storage URL structure
    return 'https://your-api-domain.com/storage/$gambar';
  }

  // PDF URL helper
  String? get pdfUrl {
    if (filePdf == null || filePdf!.isEmpty) return null;
    if (filePdf!.startsWith('http')) return filePdf;
    // Assuming Laravel storage URL structure
    return 'https://your-api-domain.com/storage/$filePdf';
  }

  @override
  String toString() {
    return 'Tool(id: $id, nama: $nama, kategori: $kategori)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tool && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Media availability getters
  bool get hasImage => gambar != null && gambar!.isNotEmpty;
  bool get hasVideo => urlVideo != null && urlVideo!.isNotEmpty;
  bool get hasPdf => filePdf != null && filePdf!.isNotEmpty;
  
  // Display getters
  String? get displayImageUrl => hasImage ? imageUrl : null;
  String? get name => nama;
  String? get description => deskripsi;
  String? get function => fungsi;
  
  // Featured status (can be enhanced with actual data from API)
  bool get isFeatured => rating >= 4.5 || viewCount > 1000;
  
  // Formatted display values
  String get formattedRating => rating.toStringAsFixed(1);
  String get formattedViewCount {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    }
    return viewCount.toString();
  }
  
  // YouTube video ID extraction
  String? get youtubeVideoId {
    if (!hasVideo) return null;
    final RegExp regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(urlVideo!);
    return match?.group(1);
  }
  
  // Short description for cards
  String get shortDescription {
    if (deskripsi.length <= 100) return deskripsi;
    return '${deskripsi.substring(0, 97)}...';
  }

  String get displayPdfUrl => pdfUrl ?? '';
}

// Result wrapper for API responses
class ToolResult {
  final bool success;
  final List<Tool> tools;
  final String? message;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool isFromCache;

  ToolResult({
    required this.success,
    this.tools = const [],
    this.message,
    this.totalCount = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasNextPage = false,
    this.isFromCache = false,
  });

  factory ToolResult.success({
    List<Tool> tools = const [],
    int totalCount = 0,
    int currentPage = 1,
    int totalPages = 1,
    bool hasNextPage = false,
    bool isFromCache = false,
  }) {
    return ToolResult(
      success: true,
      tools: tools,
      totalCount: totalCount,
      currentPage: currentPage,
      totalPages: totalPages,
      hasNextPage: hasNextPage,
      isFromCache: isFromCache,
    );
  }

  factory ToolResult.failure({required String message}) {
    return ToolResult(success: false, message: message);
  }
}
