class ToolModel {
  final String id;
  final String name;
  final String description;
  final String function;
  final String imageUrl;
  final String videoUrl;
  final String pdfUrl;

  ToolModel({
    required this.id,
    required this.name,
    required this.description,
    required this.function,
    required this.imageUrl,
    required this.videoUrl,
    required this.pdfUrl,
  });

  factory ToolModel.fromMap(Map<String, dynamic> map) {
    return ToolModel(
      id: map['id']?.toString() ?? '',
      name: map['nama'] ?? map['name'] ?? '',
      description: map['deskripsi'] ?? map['description'] ?? '',
      function: map['fungsi'] ?? map['function'] ?? '',
      imageUrl: map['gambar'] ?? map['imageUrl'] ?? '',
      videoUrl: map['url_video'] ?? map['videoUrl'] ?? '',
      pdfUrl: map['file_pdf'] ?? map['pdfUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': name,
      'deskripsi': description,
      'fungsi': function,
      'gambar': imageUrl,
      'url_video': videoUrl,
      'file_pdf': pdfUrl,
    };
  }
}