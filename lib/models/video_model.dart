// Note: Video class moved to domain/entities/video.dart to avoid conflicts

class VideoCategory {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final int videoCount;
  final bool isActive;

  VideoCategory({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    this.videoCount = 0,
    this.isActive = true,
  });

  factory VideoCategory.fromJson(Map<String, dynamic> json) {
    return VideoCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconUrl: json['icon_url']?.toString(),
      videoCount: json['video_count']?.toInt() ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'video_count': videoCount,
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return 'VideoCategory(id: $id, name: $name, videoCount: $videoCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class VideoFilter {
  final String? category;
  final String? searchQuery;
  final String sortBy;
  final String sortOrder;
  final int? minDuration; // in seconds
  final int? maxDuration; // in seconds
  final List<String> tags;

  VideoFilter({
    this.category,
    this.searchQuery,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
    this.minDuration,
    this.maxDuration,
    this.tags = const [],
  });

  VideoFilter copyWith({
    String? category,
    String? searchQuery,
    String? sortBy,
    String? sortOrder,
    int? minDuration,
    int? maxDuration,
    List<String>? tags,
  }) {
    return VideoFilter(
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      minDuration: minDuration ?? this.minDuration,
      maxDuration: maxDuration ?? this.maxDuration,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (category != null && category!.isNotEmpty) {
      params['category'] = category;
    }
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery;
    }
    params['sort_by'] = sortBy;
    params['sort_order'] = sortOrder;
    if (minDuration != null) {
      params['min_duration'] = minDuration;
    }
    if (maxDuration != null) {
      params['max_duration'] = maxDuration;
    }
    if (tags.isNotEmpty) {
      params['tags'] = tags.join(',');
    }
    
    return params;
  }

  @override
  String toString() {
    return 'VideoFilter(category: $category, searchQuery: $searchQuery, sortBy: $sortBy)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoFilter &&
        other.category == category &&
        other.searchQuery == searchQuery &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder &&
        other.minDuration == minDuration &&
        other.maxDuration == maxDuration;
  }

  @override
  int get hashCode {
    return Object.hash(
      category,
      searchQuery,
      sortBy,
      sortOrder,
      minDuration,
      maxDuration,
    );
  }

  // Helper methods
  bool get hasActiveFilters {
    return category != null ||
           (searchQuery != null && searchQuery!.isNotEmpty) ||
           minDuration != null ||
           maxDuration != null ||
           tags.isNotEmpty;
  }

  void clearFilters() {
    // This would be implemented in a mutable version or through copyWith
  }
}