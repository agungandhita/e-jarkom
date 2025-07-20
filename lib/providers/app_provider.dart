import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/tool_model.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../models/video_model.dart';
import '../services/data_service.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  // User data
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

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
  
  // Constructor
  AppProvider() {
    // Initialize data from API
    initializeData();
  }
  
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
      // If API fails, show empty results
      _filteredTools = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredTools = _tools;
    notifyListeners();
  }

  // Add new tool with image upload
  Future<bool> addTool(ToolModel tool, {File? imageFile}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final createdTool = await DataService.createTool(tool, imageFile: imageFile);
      if (createdTool != null) {
        _tools.add(createdTool);
        _filteredTools = _tools;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
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
    if (_currentUser == null) return;
    
    try {
      final updatedUser = await DataService.updateUserProgress(
        _currentUser!.id,
        completedQuizzes: _currentUser!.completedQuizzes + 1,
      );
      
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      // If API fails, don't update anything
      if (kDebugMode) {
        print('Failed to update user progress: $e');
      }
    }
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
      return [];
    }
  }
  
  // Initialize data from API
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
          : 'Connection failed';
      
      if (_isConnected) {
        // Load initial data only if connected
        await loadTools();
        await loadVideos();
        await loadUser();
      }
      
    } catch (e) {
      _isConnected = false;
      _connectionStatus = 'Connection failed';
      
      if (kDebugMode) {
        print('Failed to initialize data: $e');
      }
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
      _tools = [];
      _filteredTools = [];
      if (kDebugMode) {
        print('Failed to load tools: $e');
      }
    }
  }
  
  // Load videos from data service
  Future<void> loadVideos() async {
    try {
      _videos = await DataService.getVideos();
    } catch (e) {
      _videos = [];
      if (kDebugMode) {
        print('Failed to load videos: $e');
      }
    }
  }
  
  // Load user from data service
  Future<void> loadUser() async {
    try {
      // First try to load from local storage
      final savedUserData = await ApiService.getSavedUserData();
      if (savedUserData != null) {
        _currentUser = UserModel.fromMap(savedUserData);
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _currentUser = null;
      if (kDebugMode) {
        print('Failed to load user: $e');
      }
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
    if (_currentUser == null) return null;
    
    try {
      return await DataService.submitQuizAnswers(
        userId: _currentUser!.id,
        answers: answers,
        level: level,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to submit quiz answers: $e');
      }
      return null;
    }
  }
  
  // Get connection status info
  Map<String, dynamic> getConnectionInfo() {
    return DataService.getStatus();
  }
}