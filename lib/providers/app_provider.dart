import 'package:flutter/material.dart';
import '../models/tool_model.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../models/video_model.dart';
import '../data/dummy_data.dart';

class AppProvider with ChangeNotifier {
  // User data
  UserModel _currentUser = DummyData.dummyUser;
  UserModel get currentUser => _currentUser;

  // Tools data
  List<ToolModel> _tools = DummyData.dummyTools;
  List<ToolModel> get tools => _tools;
  List<ToolModel> _filteredTools = DummyData.dummyTools;
  List<ToolModel> get filteredTools => _filteredTools;

  // Videos data
  List<VideoModel> _videos = DummyData.dummyVideos;
  List<VideoModel> get videos => _videos;

  // Quiz data
  List<QuizQuestion> _quizQuestions = DummyData.dummyQuizQuestions;
  List<QuizQuestion> get quizQuestions => _quizQuestions;
  
  QuizLevel _selectedQuizLevel = QuizLevel.easy;
  QuizLevel get selectedQuizLevel => _selectedQuizLevel;
  
  List<QuizQuestion> get filteredQuizQuestions => 
      _quizQuestions.where((q) => q.level == _selectedQuizLevel).toList();

  // Search functionality
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void searchTools(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredTools = _tools;
    } else {
      _filteredTools = _tools.where((tool) {
        return tool.name.toLowerCase().contains(query.toLowerCase()) ||
               tool.description.toLowerCase().contains(query.toLowerCase()) ||
               tool.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredTools = _tools;
    notifyListeners();
  }

  // Add new tool
  void addTool(ToolModel tool) {
    _tools.add(tool);
    _filteredTools = _tools;
    notifyListeners();
  }

  // Quiz level selection
  void setQuizLevel(QuizLevel level) {
    _selectedQuizLevel = level;
    notifyListeners();
  }

  // Update user progress
  void updateUserProgress() {
    _currentUser = UserModel(
      id: _currentUser.id,
      name: _currentUser.name,
      className: _currentUser.className,
      profileImageUrl: _currentUser.profileImageUrl,
      completedQuizzes: _currentUser.completedQuizzes + 1,
      totalQuizzes: _currentUser.totalQuizzes,
    );
    notifyListeners();
  }

  // Get tool by ID
  ToolModel? getToolById(String id) {
    try {
      return _tools.firstWhere((tool) => tool.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get video by ID
  VideoModel? getVideoById(String id) {
    try {
      return _videos.firstWhere((video) => video.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get questions by level
  List<QuizQuestion> getQuestionsByLevel(String level) {
    QuizLevel quizLevel;
    switch (level.toLowerCase()) {
      case 'mudah':
      case 'easy':
        quizLevel = QuizLevel.easy;
        break;
      case 'sedang':
      case 'medium':
        quizLevel = QuizLevel.medium;
        break;
      case 'sulit':
      case 'hard':
        quizLevel = QuizLevel.hard;
        break;
      default:
        quizLevel = QuizLevel.easy;
    }
    return _quizQuestions.where((q) => q.level == quizLevel).toList();
  }
}