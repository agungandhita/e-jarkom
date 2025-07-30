import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/tool_model.dart';
import '../../models/category_model.dart';
import '../../core/constants/app_constants.dart';

enum ToolSortBy { newest, oldest, name, rating, views, asc }

enum SortOrder { ascending, descending, asc }

class ToolProvider extends ChangeNotifier {
  final ApiService _apiService;

  ToolProvider(this._apiService);

  // State variables
  List<Tool> _tools = [];
  List<Tool> _filteredTools = [];
  List<CategoryModel> _categories = [];

  Tool? _selectedTool;
  String? _selectedCategoryId;
  String _searchQuery = '';
  ToolSortBy _sortBy = ToolSortBy.newest;
  SortOrder _sortOrder = SortOrder.descending;

  bool _isLoading = false;
  final bool _isLoadingMore = false;
  bool _hasMoreData = true;

  String? _errorMessage;
  Map<String, String> _validationErrors = {};

  int _currentPage = 1;
  final int _pageSize = AppConstants.defaultPageSize;

  // Getters
  List<Tool> get tools => _tools;
  List<Tool> get filteredTools => _filteredTools;
  List<CategoryModel> get categories => _categories;

  Tool? get selectedTool => _selectedTool;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  ToolSortBy get sortBy => _sortBy;
  SortOrder get sortOrder => _sortOrder;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  bool get hasMoreTools => _hasMoreData;

  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  Map<String, String> get validationErrors => _validationErrors;

  int get currentPage => _currentPage;
  bool get hasTools => _tools.isNotEmpty;
  bool get hasFilteredTools => _filteredTools.isNotEmpty;
  bool get hasCategories => _categories.isNotEmpty;

  // Initialize data
  Future<void> initialize() async {
    await Future.wait([loadCategories(), loadTools()]);
  }

  // Load all tools
  Future<void> loadTools({
    bool refresh = false,
    String? categoryId,
    String? search,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _tools.clear();
    }

    if (_isLoading || (!_hasMoreData && !refresh)) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getTools(
        search: search ?? _searchQuery,
        categoryId: categoryId != null
            ? int.tryParse(categoryId)
            : (_selectedCategoryId != null
                  ? int.tryParse(_selectedCategoryId!)
                  : null),
        // sort: _getSortParameter(), // Temporarily disabled to avoid backend error
        perPage: _pageSize,
      );

      if (response['success'] == true) {
        final dynamic responseData = response['data'];

        // Handle different response structures
        List<dynamic> toolsData = [];
        if (responseData is Map<String, dynamic>) {
          // Laravel pagination response
          toolsData = responseData['data'] ?? responseData['tools'] ?? [];
        } else if (responseData is List) {
          // Direct array response
          toolsData = responseData;
        }

        final List<Tool> newTools = toolsData
            .map((json) => Tool.fromJson(json))
            .toList();

        if (refresh) {
          _tools = newTools;
        } else {
          _tools.addAll(newTools);
        }

        _hasMoreData = newTools.length == _pageSize;
        _currentPage++;
        _applyFilters();

        debugPrint('Loaded ${newTools.length} tools, total: ${_tools.length}');
      } else {
        _errorMessage = response['message'] ?? 'Gagal memuat tools';
        debugPrint('API Error: $_errorMessage');
      }
    } catch (e) {
      debugPrint('Exception in loadTools: $e');
      String errorMessage = 'Gagal memuat data alat';

      // Handle specific error types
      final errorString = e.toString();
      if (errorString.contains('401')) {
        errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
      } else if (errorString.contains('500') || errorString.contains('Server Error')) {
        errorMessage = 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
      } else if (errorString.contains('network') || errorString.contains('Network Error')) {
        errorMessage = 'Tidak ada koneksi internet. Periksa koneksi Anda.';
      } else if (errorString.contains('timeout')) {
        errorMessage = 'Koneksi timeout. Coba lagi nanti.';
      } else if (errorString.contains('404')) {
        errorMessage = 'Data tidak ditemukan.';
      } else {
        errorMessage = 'Terjadi kesalahan: ${errorString}';
      }

      _setError(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Load more tools (pagination)
  Future<void> loadMoreTools() async {
    if (_isLoadingMore || !_hasMoreData) return;
    await loadTools();
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      final response = await _apiService.getCategories();
      if (response['success'] == true) {
        final List<dynamic> categoriesData = response['data'] ?? [];
        _categories = categoriesData
            .map((json) => CategoryModel.fromMap(json))
            .toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      _setError('Gagal memuat kategori');
    }
  }

  // Get tool by ID
  Future<Tool?> getToolById(dynamic id) async {
    _setLoading(true);
    _clearError();

    try {
      // Handle both String and int ID types
      final int toolId = id is int ? id : int.parse(id.toString());
      final response = await _apiService.getTool(toolId);
      if (response['success'] == true) {
        final tool = Tool.fromJson(response['data']);
        _selectedTool = tool;
        notifyListeners();
        return tool;
      } else {
        _setError(response['message'] ?? 'Gagal memuat detail alat');
        return null;
      }
    } catch (e) {
      _setError('Gagal memuat detail alat: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Search tools
  void searchTools(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Filter by category
  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    _currentPage = 1;
    _hasMoreData = true;
    loadTools(
      refresh: true,
      categoryId: categoryId,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
  }

  // Sort tools
  void sortTools(ToolSortBy sortBy, [SortOrder? sortOrder]) {
    _sortBy = sortBy;
    if (sortOrder != null) {
      _sortOrder = sortOrder;
    }
    _currentPage = 1;
    _hasMoreData = true;
    loadTools(
      refresh: true,
      categoryId: _selectedCategoryId,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
  }

  // Clear filters

  // Apply filters to tools list
  void _applyFilters() {
    // Show all tools without any filtering
    _filteredTools = List.from(_tools);
    notifyListeners();
  }

  // Refresh all data
  Future<void> refresh() async {
    _currentPage = 1;
    _hasMoreData = true;
    await Future.wait([loadTools(refresh: true), loadCategories()]);
  }

  // Set selected tool
  void setSelectedTool(Tool? tool) {
    _selectedTool = tool;
    notifyListeners();
  }

  // Clear selected tool
  void clearSelectedTool() {
    _selectedTool = null;
    notifyListeners();
  }

  // Get tools by category
  List<Tool> getToolsByCategory(String categoryId) {
    return _tools
        .where((tool) => tool.categoryId.toString() == categoryId)
        .toList();
  }

  // Get tools by tag
  List<Tool> getToolsByTag(String tag) {
    return _tools.where((tool) => tool.tags.contains(tag)).toList();
  }

  // Get all unique tags
  List<String> getAllTags() {
    final Set<String> allTags = {};
    for (final tool in _tools) {
      allTags.addAll(tool.tags);
    }
    return allTags.toList()..sort();
  }

  // Helper methods
  String _getSortParameter() {
    switch (_sortBy) {
      case ToolSortBy.newest:
        return 'latest';
      case ToolSortBy.oldest:
        return 'oldest';
      case ToolSortBy.name:
        return 'name';
      case ToolSortBy.rating:
        return 'rating';
      case ToolSortBy.views:
        return 'views';
      default:
        return 'latest';
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Public method to set error
  void setError(String error) {
    _setError(error);
  }

  // Public method to clear error
  void clearError() {
    _clearError();
  }

  void _clearValidationErrors() {
    _validationErrors.clear();
    notifyListeners();
  }

  // Validation helpers
  bool get hasValidationErrors => _validationErrors.isNotEmpty;

  String? getValidationError(String field) {
    return _validationErrors[field];
  }

  // Loading state helpers
  bool get isLoadingTools => _isLoading;

  // Filter toggles

  // Get category by ID
  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category name by ID
  String getCategoryName(String id) {
    final category = getCategoryById(id);
    return category?.nama ?? 'Unknown Category';
  }

  // Clear all data
  void clearData() {
    _tools.clear();
    _filteredTools.clear();
    _categories.clear();
    _selectedTool = null;
    _selectedCategoryId = null;
    _searchQuery = '';
    _currentPage = 1;
    _hasMoreData = true;
    _clearError();
    _clearValidationErrors();
    notifyListeners();
  }

  bool get isLoadingCategories => _isLoading && _categories.isEmpty;

  Future<void> refreshTools() async {
    _currentPage = 1;
    _hasMoreData = true;
    await loadTools(
      refresh: true,
      categoryId: _selectedCategoryId,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
  }

  void setSortBy(ToolSortBy name) {
    _sortBy = name;
    _currentPage = 1;
    _hasMoreData = true;
    loadTools(
      refresh: true,
      categoryId: _selectedCategoryId,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    _applyFilters();
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    _currentPage = 1;
    _hasMoreData = true;
    loadTools(
      refresh: true,
      categoryId: categoryId,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
  }

  // Favorite functionality
  Future<bool> toggleFavorite(Tool tool) async {
    try {
      final toolId = int.parse(tool.id);
      Map<String, dynamic> response;
      
      if (tool.isFavorited == true) {
        response = await _apiService.removeFromFavorites(toolId);
      } else {
        response = await _apiService.addToFavorites(toolId);
      }
      
      if (response['success'] == true) {
        // Update the tool in the list
        final updatedTool = tool.copyWith(
          isFavorited: !(tool.isFavorited ?? false),
        );
        
        // Update in tools list
        final index = _tools.indexWhere((t) => t.id == tool.id);
        if (index != -1) {
          _tools[index] = updatedTool;
        }
        
        // Update in filtered tools list
        final filteredIndex = _filteredTools.indexWhere((t) => t.id == tool.id);
        if (filteredIndex != -1) {
          _filteredTools[filteredIndex] = updatedTool;
        }
        
        // Update selected tool if it's the same
        if (_selectedTool?.id == tool.id) {
          _selectedTool = updatedTool;
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      _setError('Gagal mengubah status favorit');
      return false;
    }
  }

  // Get favorite tools
  Future<List<Tool>> getFavoriteTools() async {
    try {
      final response = await _apiService.getFavoriteTools();
      if (response['success'] == true) {
        final List<dynamic> favoritesData = response['data'] ?? [];
        return favoritesData
            .map((json) => Tool.fromJson(json['tool'] ?? json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error loading favorite tools: $e');
      return [];
    }
  }

  // Rate a tool
  Future<bool> rateTool(Tool tool, double rating) async {
    try {
      final toolId = int.parse(tool.id);
      final response = await _apiService.rateTool(toolId, rating);
      
      if (response['success'] == true) {
        // Update the tool with new rating data
        final newRating = response['data']?['average_rating']?.toDouble() ?? rating;
        final newRatingCount = response['data']?['rating_count'] ?? (tool.ratingCount + 1);
        
        final updatedTool = tool.copyWith(
          rating: newRating,
          ratingCount: newRatingCount,
        );
        
        // Update in tools list
        final index = _tools.indexWhere((t) => t.id == tool.id);
        if (index != -1) {
          _tools[index] = updatedTool;
        }
        
        // Update in filtered tools list
        final filteredIndex = _filteredTools.indexWhere((t) => t.id == tool.id);
        if (filteredIndex != -1) {
          _filteredTools[filteredIndex] = updatedTool;
        }
        
        // Update selected tool if it's the same
        if (_selectedTool?.id == tool.id) {
          _selectedTool = updatedTool;
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error rating tool: $e');
      _setError('Gagal memberikan rating');
      return false;
    }
  }
}
