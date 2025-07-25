import '../services/url_service.dart';

class Tool {
  final int id; // Changed from String to int to match Laravel auto-increment
  final String nama;
  final String deskripsi;
  final String fungsi;
  final String? gambar;
  final String? urlVideo;
  final String? filePdf;
  final String? kategori; // Category name as string
  final int? categoryId;
  final String? categoryName; // Nama kategori dari join table
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional computed properties (not in Laravel migration but useful for app)
  final List<String> tags;
  final int viewsCount;
  final bool isFeatured;
  final bool isActive;
  final double rating;
  final int ratingCount;
  final String? createdBy;
  final String? slug;
  final String? metaDescription;
  final String? metaKeywords;
  final int downloadCount;
  final bool isPublished;
  final String? authorName;
  final String? authorEmail;
  final String? version;
  final String? license;
  final List<String> requirements;
  final Map<String, dynamic>? metadata;

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
    // Additional properties with defaults
    this.tags = const [],
    this.viewsCount = 0,
    this.isFeatured = false,
    this.isActive = true,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.createdBy,
    this.slug,
    this.metaDescription,
    this.metaKeywords,
    this.downloadCount = 0,
    this.isPublished = true,
    this.authorName,
    this.authorEmail,
    this.version,
    this.license,
    this.requirements = const [],
    this.metadata,
  });

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      // Core fields from Laravel migration
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nama: json['nama']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      fungsi: json['fungsi']?.toString() ?? '',
      gambar: json['gambar']?.toString(),
      urlVideo: json['url_video']?.toString(),
      filePdf: json['file_pdf']?.toString(),
      kategori: json['kategori']?.toString(),
      categoryId: json['category_id'] != null ? int.tryParse(json['category_id'].toString()) : null,
      categoryName: json['category_name']?.toString() ?? json['category']?['name']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      
      // Additional fields (may not exist in Laravel response)
      tags: json['tags'] != null
          ? (json['tags'] is String
                ? (json['tags'] as String).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                : (json['tags'] is List ? List<String>.from(json['tags']) : []))
          : [],
      viewsCount: int.tryParse(json['views_count']?.toString() ?? '0') ?? 0,
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1 || json['is_featured'] == '1',
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      ratingCount: int.tryParse(json['rating_count']?.toString() ?? '0') ?? 0,
      createdBy: json['created_by']?.toString(),
      slug: json['slug']?.toString(),
      metaDescription: json['meta_description']?.toString(),
      metaKeywords: json['meta_keywords']?.toString(),
      downloadCount: int.tryParse(json['download_count']?.toString() ?? '0') ?? 0,
      isPublished: json['is_published'] == true || json['is_published'] == 1 || json['is_published'] == '1',
      authorName: json['author_name']?.toString(),
      authorEmail: json['author_email']?.toString(),
      version: json['version']?.toString(),
      license: json['license']?.toString(),
      requirements: json['requirements'] != null
          ? (json['requirements'] is String
                ? (json['requirements'] as String).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                : (json['requirements'] is List ? List<String>.from(json['requirements']) : []))
          : [],
      metadata: json['metadata'] is Map<String, dynamic> ? json['metadata'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Core fields matching Laravel migration
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'fungsi': fungsi,
      'gambar': gambar,
      'url_video': urlVideo,
      'file_pdf': filePdf,
      'kategori': kategori,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      
      // Additional fields (may be used by frontend)
      'category_id': categoryId,
      'category_name': categoryName,
      'tags': tags,
      'views_count': viewsCount,
      'is_featured': isFeatured,
      'is_active': isActive,
      'rating': rating,
      'rating_count': ratingCount,
      'created_by': createdBy,
      'slug': slug,
      'meta_description': metaDescription,
      'meta_keywords': metaKeywords,
      'download_count': downloadCount,
      'is_published': isPublished,
      'author_name': authorName,
      'author_email': authorEmail,
      'version': version,
      'license': license,
      'requirements': requirements,
      'metadata': metadata,
    };
  }

  Tool copyWith({
    int? id,
    String? nama,
    String? deskripsi,
    String? fungsi,
    String? gambar,
    String? urlVideo,
    String? filePdf,
    String? kategori,
    int? categoryId,
    String? categoryName,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    int? viewsCount,
    bool? isFeatured,
    bool? isActive,
    double? rating,
    int? ratingCount,
    String? createdBy,
    String? slug,
    String? metaDescription,
    String? metaKeywords,
    int? downloadCount,
    bool? isPublished,
    String? authorName,
    String? authorEmail,
    String? version,
    String? license,
    List<String>? requirements,
    Map<String, dynamic>? metadata,
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
      viewsCount: viewsCount ?? this.viewsCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdBy: createdBy ?? this.createdBy,
      slug: slug ?? this.slug,
      metaDescription: metaDescription ?? this.metaDescription,
      metaKeywords: metaKeywords ?? this.metaKeywords,
      downloadCount: downloadCount ?? this.downloadCount,
      isPublished: isPublished ?? this.isPublished,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      version: version ?? this.version,
      license: license ?? this.license,
      requirements: requirements ?? this.requirements,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'Tool(id: $id, nama: $nama, kategori: $categoryName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tool && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods
  bool get hasImage => gambar != null && gambar!.isNotEmpty;
  bool get hasVideo => urlVideo != null && urlVideo!.isNotEmpty;
  bool get hasPdf => filePdf != null && filePdf!.isNotEmpty;

  String get formattedViewCount {
    if (viewsCount >= 1000000) {
      return '${(viewsCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewsCount >= 1000) {
      return '${(viewsCount / 1000).toStringAsFixed(1)}K';
    }
    return viewsCount.toString();
  }

  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  String get shortDescription {
    if (deskripsi.length <= 100) return deskripsi;
    return '${deskripsi.substring(0, 100)}...';
  }

  String get displayImageUrl {
    // Import UrlService at the top of the file if not already imported
    // Use the centralized URL service for consistent URL handling
    return _getImageUrl();
  }

  String _getImageUrl() {
    if (hasImage && gambar!.isNotEmpty) {
      // If it's already a full URL, return as is
      if (gambar!.startsWith('http')) {
        return gambar!;
      }
      // Use UrlService for consistent URL construction
      return UrlService.constructImageUrl(gambar!);
    }
    // Fallback to placeholder with better styling
    return 'https://via.placeholder.com/400x300/E3F2FD/1976D2?text=${Uri.encodeComponent(nama.length > 20 ? nama.substring(0, 20) + '...' : nama)}';
  }

  String get displayPdfUrl {
    // Use the centralized URL service for consistent URL handling
    return _getPdfUrl();
  }

  String _getPdfUrl() {
    if (hasPdf && filePdf!.isNotEmpty) {
      // If it's already a full URL, return as is
      if (filePdf!.startsWith('http')) {
        return filePdf!;
      }
      // Use UrlService for consistent URL construction
      return UrlService.constructPdfUrl(filePdf!);
    }
    return '';
  }

  String get displayCategoryName {
    return kategori ?? categoryName ?? 'Umum';
  }

  bool get hasRating => rating > 0;

  String get statusText {
    if (!isActive) return 'Nonaktif';
    if (isFeatured) return 'Unggulan';
    return 'Aktif';
  }

  String? get youtubeVideoId {
    if (!hasVideo) return null;

    final regex = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    final match = regex.firstMatch(urlVideo!);
    return match?.group(1);
  }

  String? get youtubeThumbnailUrl {
    final videoId = youtubeVideoId;
    if (videoId == null) return null;
    return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
  }

  // Legacy getters for backward compatibility
  String? get video => urlVideo;
  String? get foto => gambar;
  String? get pdf => filePdf;
  String? get imageUrl => gambar;
  String? get name => nama;
  String? get description => deskripsi;
  String? get function => fungsi;
}

class ToolCategory {
  final String id;
  final String name;
  final String description;
  final String? icon;
  final int toolCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ToolCategory({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    this.toolCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ToolCategory.fromJson(Map<String, dynamic> json) {
    return ToolCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString(),
      toolCount: json['tool_count']?.toInt() ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'tool_count': toolCount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ToolCategory(id: $id, name: $name, toolCount: $toolCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ToolCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ToolFilter {
  final String? categoryId;
  final String? searchQuery;
  final bool? showFeaturedOnly;
  final bool? showWithVideoOnly;
  final bool? showWithPdfOnly;
  final String sortBy;
  final String sortOrder;
  final int page;
  final int limit;

  ToolFilter({
    this.categoryId,
    this.searchQuery,
    this.showFeaturedOnly,
    this.showWithVideoOnly,
    this.showWithPdfOnly,
    this.sortBy = 'name',
    this.sortOrder = 'asc',
    this.page = 1,
    this.limit = 10,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'page': page,
      'limit': limit,
    };

    if (categoryId != null && categoryId!.isNotEmpty) {
      params['category_id'] = categoryId;
    }
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery;
    }
    if (showFeaturedOnly == true) {
      params['featured'] = '1';
    }
    if (showWithVideoOnly == true) {
      params['has_video'] = '1';
    }
    if (showWithPdfOnly == true) {
      params['has_pdf'] = '1';
    }

    return params;
  }

  ToolFilter copyWith({
    String? categoryId,
    String? searchQuery,
    bool? showFeaturedOnly,
    bool? showWithVideoOnly,
    bool? showWithPdfOnly,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? limit,
  }) {
    return ToolFilter(
      categoryId: categoryId ?? this.categoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      showFeaturedOnly: showFeaturedOnly ?? this.showFeaturedOnly,
      showWithVideoOnly: showWithVideoOnly ?? this.showWithVideoOnly,
      showWithPdfOnly: showWithPdfOnly ?? this.showWithPdfOnly,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  String toString() {
    return 'ToolFilter(categoryId: $categoryId, searchQuery: $searchQuery, sortBy: $sortBy, sortOrder: $sortOrder)';
  }
}
