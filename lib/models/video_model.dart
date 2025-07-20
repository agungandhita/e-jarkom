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
    String youtubeUrl = map['youtube_url'] ?? map['youtubeUrl'] ?? '';
    String extractedId = '';
    
    // Extract YouTube ID from URL if needed
    if (youtubeUrl.isNotEmpty) {
      final regex = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]+)');
      final match = regex.firstMatch(youtubeUrl);
      extractedId = match?.group(1) ?? youtubeUrl;
    }
    
    return VideoModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? map['judul'] ?? '',
      description: map['description'] ?? map['deskripsi'] ?? '',
      youtubeId: map['youtubeId'] ?? extractedId,
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