class VideoModel {
  final String id;
  final String title;
  final String description;
  final String youtubeId;
  final String thumbnailUrl;
  final String duration;
  final String category;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeId,
    required this.thumbnailUrl,
    required this.duration,
    required this.category,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$youtubeId';

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      youtubeId: map['youtubeId'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      duration: map['duration'] ?? '',
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'youtubeId': youtubeId,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'category': category,
    };
  }
}