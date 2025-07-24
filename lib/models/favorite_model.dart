import 'tool_model.dart';

class FavoriteModel {
  final String id;
  final String userId;
  final String toolId;
  final DateTime createdAt;
  final Tool? tool; // Optional tool data

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.toolId,
    required this.createdAt,
    this.tool,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      toolId: map['tool_id']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      tool: map['tool'] != null ? Tool.fromJson(map['tool']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'tool_id': toolId,
      'created_at': createdAt.toIso8601String(),
      if (tool != null) 'tool': tool!.toJson(),
    };
  }
}
