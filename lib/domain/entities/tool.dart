class Tool {
  final String id;
  final String name;
  final String description;
  final String function;
  final String? imageUrl;
  final String? videoUrl;
  final String? pdfUrl;
  final String categoryId;
  final String categoryName;
  final List<String> tags;
  final int viewCount;
  final double rating;
  final int ratingCount;
  final bool isFeatured;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const Tool({
    required this.id,
    required this.name,
    required this.description,
    required this.function,
    this.imageUrl,
    this.videoUrl,
    this.pdfUrl,
    required this.categoryId,
    required this.categoryName,
    this.tags = const [],
    this.viewCount = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.isFeatured = false,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  // Create Tool from JSON
  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      function: json['function']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      videoUrl: json['video_url']?.toString() ?? json['videoUrl']?.toString(),
      pdfUrl: json['pdf_url']?.toString() ?? json['pdfUrl']?.toString(),
      categoryId: json['category_id']?.toString() ?? json['categoryId']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? json['categoryName']?.toString() ?? '',
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'])
          : [],
      viewCount: json['view_count'] ?? json['viewCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['rating_count'] ?? json['ratingCount'] ?? 0,
      isFeatured: json['is_featured'] ?? json['isFeatured'] ?? false,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdBy: json['created_by']?.toString() ?? json['createdBy']?.toString() ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert Tool to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'function': function,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'pdf_url': pdfUrl,
      'category_id': categoryId,
      'category_name': categoryName,
      'tags': tags,
      'view_count': viewCount,
      'rating': rating,
      'rating_count': ratingCount,
      'is_featured': isFeatured,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Copy with method for updating tool data
  Tool copyWith({
    String? id,
    String? name,
    String? description,
    String? function,
    String? imageUrl,
    String? videoUrl,
    String? pdfUrl,
    String? categoryId,
    String? categoryName,
    List<String>? tags,
    int? viewCount,
    double? rating,
    int? ratingCount,
    bool? isFeatured,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Tool(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      function: function ?? this.function,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get display image URL
  String? get displayImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // If it's already a full URL, return as is
      if (imageUrl!.startsWith('http')) {
        return imageUrl;
      }
      // Otherwise, construct the full URL
      return imageUrl;
    }
    return null;
  }

  // Get YouTube video ID from URL
  String? get youtubeVideoId {
    if (videoUrl == null || videoUrl!.isEmpty) return null;
    
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    
    final match = regExp.firstMatch(videoUrl!);
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

  // Check if tool has video
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  // Check if tool has PDF
  bool get hasPdf => pdfUrl != null && pdfUrl!.isNotEmpty;

  // Check if tool has image
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  // Get formatted rating
  String get formattedRating {
    if (ratingCount == 0) return 'Belum ada rating';
    return '${rating.toStringAsFixed(1)} (${ratingCount} rating)';
  }

  // Get formatted view count
  String get formattedViewCount {
    if (viewCount < 1000) {
      return '$viewCount views';
    } else if (viewCount < 1000000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K views';
    } else {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M views';
    }
  }

  // Get short description (for cards)
  String get shortDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 97)}...';
  }

  // Search in tool content
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
           description.toLowerCase().contains(lowerQuery) ||
           function.toLowerCase().contains(lowerQuery) ||
           categoryName.toLowerCase().contains(lowerQuery) ||
           tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tool &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.function == function &&
        other.imageUrl == imageUrl &&
        other.videoUrl == videoUrl &&
        other.pdfUrl == pdfUrl &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      function,
      imageUrl,
      videoUrl,
      pdfUrl,
      categoryId,
      categoryName,
    );
  }

  @override
  String toString() {
    return 'Tool(id: $id, name: $name, category: $categoryName)';
  }
}

// Tool sorting options
enum ToolSortBy {
  name('name'),
  createdAt('created_at'),
  updatedAt('updated_at'),
  viewCount('view_count'),
  rating('rating');

  const ToolSortBy(this.value);
  final String value;

  static ToolSortBy fromString(String sort) {
    switch (sort.toLowerCase()) {
      case 'name':
        return ToolSortBy.name;
      case 'created_at':
        return ToolSortBy.createdAt;
      case 'updated_at':
        return ToolSortBy.updatedAt;
      case 'view_count':
        return ToolSortBy.viewCount;
      case 'rating':
        return ToolSortBy.rating;
      default:
        return ToolSortBy.createdAt;
    }
  }
}

// Sort order options
enum SortOrder {
  asc('asc'),
  desc('desc');

  const SortOrder(this.value);
  final String value;

  static SortOrder fromString(String order) {
    switch (order.toLowerCase()) {
      case 'asc':
        return SortOrder.asc;
      case 'desc':
      default:
        return SortOrder.desc;
    }
  }
}