class CategoryModel {
  final String id;
  final String nama;
  final String slug;
  final String? deskripsi;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.nama,
    required this.slug,
    this.deskripsi,
    this.icon,
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
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'slug': slug,
      'deskripsi': deskripsi,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}