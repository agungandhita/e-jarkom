class ToolModel {
  final String id;
  final String name;
  final String description;
  final String function;
  final String imageUrl;
  final String videoUrl;
  final String category;

  ToolModel({
    required this.id,
    required this.name,
    required this.description,
    required this.function,
    required this.imageUrl,
    required this.videoUrl,
    required this.category,
  });

  factory ToolModel.fromMap(Map<String, dynamic> map) {
    return ToolModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      function: map['function'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'function': function,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'category': category,
    };
  }
}