class CategoryModel {
  final String id;
  final String nama;
  final String slug;
  final String? deskripsi;
  final String? icon;
  final int? toolsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.nama,
    required this.slug,
    this.deskripsi,
    this.icon,
    this.toolsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      nama: map['nama']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
      deskripsi: map['deskripsi']?.toString(),
      icon: map['icon']?.toString(),
      toolsCount: map['tools_count'],
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel.fromMap(json);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'slug': slug,
      'deskripsi': deskripsi,
      'icon': icon,
      if (toolsCount != null) 'tools_count': toolsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  CategoryModel copyWith({
    String? id,
    String? nama,
    String? slug,
    String? deskripsi,
    String? icon,
    int? toolsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      slug: slug ?? this.slug,
      deskripsi: deskripsi ?? this.deskripsi,
      icon: icon ?? this.icon,
      toolsCount: toolsCount ?? this.toolsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, nama: $nama, slug: $slug)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}