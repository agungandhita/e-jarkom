import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import '../../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final ApiService _apiService;

  CategoryProvider(this._apiService);

  // State variables
  List<CategoryModel> _categories = [];
  List<CategoryModel> _filteredCategories = [];
  CategoryModel? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, String> _validationErrors = {};

  // Getters
  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get filteredCategories => _filteredCategories;
  CategoryModel? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  Map<String, String> get validationErrors => _validationErrors;
  bool get hasCategories => _categories.isNotEmpty;

  // Load all categories
  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getCategories();
      if (response['success'] == true) {
        final List<dynamic> categoriesData = response['data'] ?? [];
        _categories = categoriesData
            .map((json) => CategoryModel.fromMap(json))
            .toList();
        _filteredCategories = List.from(_categories);
      } else {
        _setError(response['message'] ?? 'Gagal memuat kategori');
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      _setError('Gagal memuat kategori: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Search categories
  void searchCategories(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredCategories = List.from(_categories);
    } else {
      _filteredCategories = _categories
          .where(
            (category) =>
                category.nama.toLowerCase().contains(query.toLowerCase()) ||
                (category.deskripsi?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }
    notifyListeners();
  }

  // Get category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // For now, find from local list since API endpoint is not implemented
      final category = _categories.firstWhere(
        (cat) => cat.id == id,
        orElse: () => throw Exception('Kategori tidak ditemukan'),
      );
      _selectedCategory = category;
      notifyListeners();
      return category;
    } catch (e) {
      _setError('Gagal memuat detail kategori: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Create new category (admin only)
  Future<bool> createCategory(Map<String, dynamic> categoryData) async {
    _setLoading(true);
    _clearError();
    _clearValidationErrors();

    try {
      // Since API endpoint is not implemented, simulate creation
      final newCategory = CategoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: categoryData['nama'] ?? '',
        slug: _generateSlug(categoryData['nama'] ?? ''),
        deskripsi: categoryData['deskripsi'],
        icon: categoryData['icon'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _categories.add(newCategory);
      searchCategories(_searchQuery); // Refresh filtered list

      return true;
    } catch (e) {
      _setError('Gagal membuat kategori: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update category (admin only)
  Future<bool> updateCategory(
    String id,
    Map<String, dynamic> categoryData,
  ) async {
    _setLoading(true);
    _clearError();
    _clearValidationErrors();

    try {
      // Since API endpoint is not implemented, simulate update
      final index = _categories.indexWhere((cat) => cat.id == id);
      if (index == -1) {
        _setError('Kategori tidak ditemukan');
        return false;
      }

      final updatedCategory = CategoryModel(
        id: id,
        nama: categoryData['nama'] ?? _categories[index].nama,
        slug: _generateSlug(categoryData['nama'] ?? _categories[index].nama),
        deskripsi: categoryData['deskripsi'] ?? _categories[index].deskripsi,
        icon: categoryData['icon'] ?? _categories[index].icon,
        createdAt: _categories[index].createdAt,
        updatedAt: DateTime.now(),
      );

      _categories[index] = updatedCategory;
      searchCategories(_searchQuery); // Refresh filtered list

      return true;
    } catch (e) {
      _setError('Gagal mengupdate kategori: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete category (admin only)
  Future<bool> deleteCategory(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Since API endpoint is not implemented, simulate deletion
      final index = _categories.indexWhere((cat) => cat.id == id);
      if (index == -1) {
        _setError('Kategori tidak ditemukan');
        return false;
      }

      _categories.removeAt(index);
      searchCategories(_searchQuery); // Refresh filtered list

      return true;
    } catch (e) {
      _setError('Gagal menghapus kategori: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get statistics
  Map<String, int> getStatistics() {
    return {
      'totalCategories': _categories.length,
      'activeCategories': _categories
          .where((cat) => true)
          .length, // Assuming all are active for now
    };
  }

  // Helper methods
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

  void _clearValidationErrors() {
    _validationErrors.clear();
    notifyListeners();
  }

  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .trim();
  }

  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  void setSelectedCategory(CategoryModel? category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
