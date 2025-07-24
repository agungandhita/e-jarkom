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
  List<Tool> _featuredTools = [];
  List<Tool> _popularTools = [];
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
  List<Tool> get featuredTools => _featuredTools;
  List<Tool> get popularTools => _popularTools;
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
    await Future.wait([
      loadCategories(),
      loadTools(),
      loadFeaturedTools(),
      loadPopularTools(),
    ]);
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
        sort: _getSortParameter(),
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
      String errorMessage = 'Gagal memuat data alat: ${e.toString()}';

      // Handle specific error types
      if (e.toString().contains('401')) {
        errorMessage = '401: Sesi Anda telah berakhir. Silakan login kembali.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Tidak ada koneksi internet. Periksa koneksi Anda.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Koneksi timeout. Coba lagi nanti.';
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

  // Load featured tools
  Future<void> loadFeaturedTools() async {
    try {
      final response = await _apiService.getFeaturedTools();
      if (response['success'] == true) {
        final List<dynamic> toolsData = response['data'] ?? [];
        _featuredTools = toolsData.map((json) => Tool.fromJson(json)).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading featured tools: $e');
    }
  }

  // Load popular tools
  Future<void> loadPopularTools() async {
    try {
      final response = await _apiService.getPopularTools();
      if (response['success'] == true) {
        final List<dynamic> toolsData = response['data'] ?? [];
        _popularTools = toolsData.map((json) => Tool.fromJson(json)).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading popular tools: $e');
    }
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
    await Future.wait([
      loadTools(refresh: true),
      loadFeaturedTools(),
      loadPopularTools(),
      loadCategories(),
    ]);
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
        return 'latest'; // Will be handled by sort order
      case ToolSortBy.name:
        return 'name';
      case ToolSortBy.rating:
        return 'popular'; // Assuming rating relates to popularity
      case ToolSortBy.views:
        return 'popular';
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
    _featuredTools.clear();
    _popularTools.clear();
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
  bool get isLoadingFeatured => _featuredTools.isEmpty;
  bool get isLoadingPopular => _popularTools.isEmpty;

  Future<void> incrementToolViewCount(String toolId) async {
    try {
      // Convert string ID to int for API call
      final int id = int.parse(toolId);
      await _apiService.incrementToolView(id);
    } catch (e) {
      debugPrint('Error incrementing tool view count: $e');
    }
  }

  Future<void> refreshTools() async {}

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
}
