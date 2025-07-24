import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final Color color;
  final int toolCount;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    this.color = const Color(0xFF2196F3),
    this.toolCount = 0,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  // Create Category from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconUrl: json['icon_url']?.toString() ?? json['iconUrl']?.toString(),
      color: json['color'] != null ? _parseColor(json['color'].toString()) : const Color(0xFF2196F3),
      toolCount: json['tool_count'] ?? json['toolCount'] ?? 0,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      sortOrder: json['sort_order'] ?? json['sortOrder'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert Category to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'color': '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
      'tool_count': toolCount,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Copy with method for updating category data
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    Color? color,
    int? toolCount,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      color: color ?? this.color,
      toolCount: toolCount ?? this.toolCount,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get display icon URL
  String? get displayIconUrl {
    if (iconUrl != null && iconUrl!.isNotEmpty) {
      // If it's already a full URL, return as is
      if (iconUrl!.startsWith('http')) {
        return iconUrl;
      }
      // Otherwise, construct the full URL
      return iconUrl;
    }
    return null;
  }

  // Parse color from string
  static Color _parseColor(String colorString) {
    try {
      // Remove # if present
      String cleanColor = colorString.replaceAll('#', '');
      
      // Add alpha if not present
      if (cleanColor.length == 6) {
        cleanColor = 'FF$cleanColor';
      }
      
      return Color(int.parse(cleanColor, radix: 16));
    } catch (e) {
      return const Color(0xFF2196F3); // Default blue color
    }
  }

  // Get formatted tool count
  String get formattedToolCount {
    if (toolCount == 0) {
      return 'Belum ada alat';
    } else if (toolCount == 1) {
      return '1 alat';
    } else {
      return '$toolCount alat';
    }
  }

  // Get short description (for cards)
  String get shortDescription {
    if (description.length <= 80) return description;
    return '${description.substring(0, 77)}...';
  }

  // Search in category content
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
           description.toLowerCase().contains(lowerQuery);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.iconUrl == iconUrl &&
        other.color.value == color.value;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      iconUrl,
      color.value,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, toolCount: $toolCount)';
  }

  // Get sample categories for testing/demo
  static List<Category> getSampleCategories() {
    return [
      Category(
        id: '1',
        name: 'Networking',
        description: 'Alat-alat untuk analisis dan monitoring jaringan komputer',
        iconUrl: 'https://example.com/networking.png',
        color: const Color(0xFF2196F3),
        toolCount: 15,
        isActive: true,
        sortOrder: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Category(
        id: '2',
        name: 'Security',
        description: 'Tools untuk keamanan jaringan dan penetration testing',
        iconUrl: 'https://example.com/security.png',
        color: const Color(0xFFF44336),
        toolCount: 22,
        isActive: true,
        sortOrder: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Category(
        id: '3',
        name: 'Monitoring',
        description: 'Alat monitoring dan observability untuk infrastruktur',
        iconUrl: 'https://example.com/monitoring.png',
        color: const Color(0xFF4CAF50),
        toolCount: 8,
        isActive: true,
        sortOrder: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Category(
        id: '4',
        name: 'Analysis',
        description: 'Tools untuk analisis data dan traffic jaringan',
        iconUrl: 'https://example.com/analysis.png',
        color: const Color(0xFFFF9800),
        toolCount: 12,
        isActive: true,
        sortOrder: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Category(
        id: '5',
        name: 'Development',
        description: 'Tools untuk development dan debugging aplikasi',
        iconUrl: 'https://example.com/development.png',
        color: const Color(0xFF9C27B0),
        toolCount: 6,
        isActive: false,
        sortOrder: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

// Default categories for offline/fallback use
class DefaultCategories {
  static const List<Map<String, dynamic>> categories = [
    {
      'id': '1',
      'name': 'Alat Ukur',
      'description': 'Berbagai alat untuk mengukur dimensi, berat, dan besaran lainnya',
      'color': '#2196F3',
      'tool_count': 0,
      'is_active': true,
      'sort_order': 1,
      'created_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': '2',
      'name': 'Alat Potong',
      'description': 'Alat-alat untuk memotong berbagai material',
      'color': '#FF5722',
      'tool_count': 0,
      'is_active': true,
      'sort_order': 2,
      'created_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': '3',
      'name': 'Alat Las',
      'description': 'Peralatan untuk pengelasan dan penyambungan logam',
      'color': '#FF9800',
      'tool_count': 0,
      'is_active': true,
      'sort_order': 3,
      'created_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': '4',
      'name': 'Alat Listrik',
      'description': 'Peralatan untuk instalasi dan perbaikan listrik',
      'color': '#4CAF50',
      'tool_count': 0,
      'is_active': true,
      'sort_order': 4,
      'created_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': '5',
      'name': 'Alat Mesin',
      'description': 'Peralatan untuk pemesinan dan manufaktur',
      'color': '#9C27B0',
      'tool_count': 0,
      'is_active': true,
      'sort_order': 5,
      'created_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': '6',
      'name': 'Alat Keselamatan',
      'description': 'Peralatan keselamatan kerja dan APD',
      'color': '#F44336',
      'tool_count': 0,
      'is_active': true,
      'sort_order': 6,
      'created_at': '2024-01-01T00:00:00Z',
    },
  ];
  
  static List<Category> getDefaultCategories() {
    return categories.map((json) => Category.fromJson(json)).toList();
  }
}