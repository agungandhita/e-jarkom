import 'package:flutter/material.dart';
import '../models/tool_model.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../models/video_model.dart';
import '../data/dummy_data.dart';
import '../services/data_service.dart';

class AppProvider with ChangeNotifier {
  // User data
  UserModel _currentUser = DummyData.dummyUser;
  UserModel get currentUser => _currentUser;

  // Tools data
  List<ToolModel> _tools = [];
  List<ToolModel> get tools => _tools;
  List<ToolModel> _filteredTools = [];
  List<ToolModel> get filteredTools => _filteredTools;

  // Videos data
  List<VideoModel> _videos = [];
  List<VideoModel> get videos => _videos;

  // Quiz data
  List<QuizQuestion> _quizQuestions = [];
  List<QuizQuestion> get quizQuestions => _quizQuestions;
  
  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Connection status
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  String _connectionStatus = 'Checking connection...';
  String get connectionStatus => _connectionStatus;
  
  QuizLevel _selectedQuizLevel = QuizLevel.easy;
  QuizLevel get selectedQuizLevel => _selectedQuizLevel;
  
  List<QuizQuestion> get filteredQuizQuestions => 
      _quizQuestions.where((q) => q.level == _selectedQuizLevel).toList();

  // Search functionality
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void searchTools(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();
    
    try {
      if (query.isEmpty) {
        _filteredTools = _tools;
      } else {
        _filteredTools = await DataService.searchTools(query);
      }
    } catch (e) {
      _filteredTools = _tools.where((tool) {
        return tool.name.toLowerCase().contains(query.toLowerCase()) ||
               tool.description.toLowerCase().contains(query.toLowerCase()) ||
               tool.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredTools = _tools;
    notifyListeners();
  }

  // Add new tool
  Future<bool> addTool(ToolModel tool) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final createdTool = await DataService.createTool(tool);
      if (createdTool != null) {
        _tools.add(createdTool);
        _filteredTools = _tools;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Fallback: add to local list
      _tools.add(tool);
      _filteredTools = _tools;
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Quiz level selection
  void setQuizLevel(QuizLevel level) {
    _selectedQuizLevel = level;
    notifyListeners();
  }

  // Update user progress
  Future<void> updateUserProgress() async {
    try {
      final updatedUser = await DataService.updateUserProgress(
        _currentUser.id,
        completedQuizzes: _currentUser.completedQuizzes + 1,
      );
      
      if (updatedUser != null) {
        _currentUser = updatedUser;
      } else {
        // Fallback: update locally
        _currentUser = UserModel(
          id: _currentUser.id,
          name: _currentUser.name,
          className: _currentUser.className,
          profileImageUrl: _currentUser.profileImageUrl,
          completedQuizzes: _currentUser.completedQuizzes + 1,
          totalQuizzes: _currentUser.totalQuizzes,
        );
      }
    } catch (e) {
      // Fallback: update locally
      _currentUser = UserModel(
        id: _currentUser.id,
        name: _currentUser.name,
        className: _currentUser.className,
        profileImageUrl: _currentUser.profileImageUrl,
        completedQuizzes: _currentUser.completedQuizzes + 1,
        totalQuizzes: _currentUser.totalQuizzes,
      );
    }
    notifyListeners();
  }

  // Get tool by ID
  Future<ToolModel?> getToolById(String id) async {
    try {
      return await DataService.getToolById(id);
    } catch (e) {
      return null;
    }
  }

  // Get video by ID
  Future<VideoModel?> getVideoById(String id) async {
    try {
      return await DataService.getVideoById(id);
    } catch (e) {
      return null;
    }
  }

  // Get questions by level
  Future<List<QuizQuestion>> getQuestionsByLevel(String level) async {
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
    
    try {
      return await DataService.getQuizQuestions(quizLevel);
    } catch (e) {
      return _quizQuestions.where((q) => q.level == quizLevel).toList();
    }
  }
  
  // Initialize data from API or fallback to dummy
  Future<void> initializeData() async {
    _isLoading = true;
    _connectionStatus = 'Initializing...';
    notifyListeners();
    
    try {
      // Initialize DataService
      await DataService.initialize();
      
      _isConnected = DataService.isConnected;
      _connectionStatus = _isConnected 
          ? 'Connected to server' 
          : 'Using offline data';
      
      // Load initial data
      await loadTools();
      await loadVideos();
      await loadUser();
      
    } catch (e) {
      _isConnected = false;
      _connectionStatus = 'Connection failed - using offline data';
      
      // Fallback to dummy data
      _tools = DummyData.dummyTools;
      _filteredTools = DummyData.dummyTools;
      _videos = DummyData.dummyVideos;
      _currentUser = DummyData.dummyUser;
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Load tools from data service
  Future<void> loadTools() async {
    try {
      _tools = await DataService.getTools();
      _filteredTools = _tools;
    } catch (e) {
      _tools = DummyData.dummyTools;
      _filteredTools = DummyData.dummyTools;
    }
  }
  
  // Load videos from data service
  Future<void> loadVideos() async {
    try {
      _videos = await DataService.getVideos();
    } catch (e) {
      _videos = DummyData.dummyVideos;
    }
  }
  
  // Load user from data service
  Future<void> loadUser() async {
    try {
      _currentUser = await DataService.getUserById('1');
    } catch (e) {
      _currentUser = DummyData.dummyUser;
    }
  }
  
  // Refresh data
  Future<void> refreshData() async {
    await DataService.refreshConnection();
    await initializeData();
  }
  
  // Submit quiz answers
  Future<Map<String, dynamic>?> submitQuizAnswers({
    required List<Map<String, dynamic>> answers,
    required QuizLevel level,
  }) async {
    try {
      return await DataService.submitQuizAnswers(
        userId: _currentUser.id,
        answers: answers,
        level: level,
      );
    } catch (e) {
      return null;
    }
  }
  
  // Toggle data source (for testing)
  void toggleDataSource() {
    DataService.toggleDataSource();
    initializeData();
  }
  
  // Get connection status info
  Map<String, dynamic> getConnectionInfo() {
    return DataService.getStatus();
  }
}