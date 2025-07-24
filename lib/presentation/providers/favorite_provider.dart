import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import '../../models/tool_model.dart';

class FavoriteProvider extends ChangeNotifier {
  final ApiService _apiService;

  FavoriteProvider(this._apiService);

  // State variables
  List<Tool> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<int, bool> _favoriteStatus = {};

  // Getters
  List<Tool> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasFavorites => _favorites.isNotEmpty;

  // Check if tool is favorited
  bool isFavorited(int toolId) {
    return _favoriteStatus[toolId] ?? false;
  }

  // Load user favorites
  Future<void> loadFavorites() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getFavorites();
      if (response['success'] == true) {
        final List<dynamic> favoritesData = response['data'] ?? [];
        _favorites = favoritesData.map((json) => Tool.fromJson(json)).toList();
        
        // Update favorite status map
        _favoriteStatus.clear();
        for (final tool in _favorites) {
          _favoriteStatus[tool.id] = true;
        }
        
        debugPrint('Loaded ${_favorites.length} favorites');
      } else {
        _errorMessage = response['message'] ?? 'Gagal memuat favorit';
      }
    } catch (e) {
      debugPrint('Exception in loadFavorites: $e');
      _setError('Gagal memuat data favorit: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(int toolId) async {
    try {
      final response = await _apiService.toggleFavorite(toolId);
      if (response['success'] == true) {
        final bool isFavorited = response['is_favorited'] ?? false;
        _favoriteStatus[toolId] = isFavorited;
        
        if (isFavorited) {
          // Add to favorites if not already present
          if (!_favorites.any((tool) => tool.id == toolId)) {
            // Fetch tool details and add to favorites
            await _addToolToFavorites(toolId);
          }
        } else {
          // Remove from favorites
          _favorites.removeWhere((tool) => tool.id == toolId);
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Gagal mengubah status favorit');
        return false;
      }
    } catch (e) {
      debugPrint('Exception in toggleFavorite: $e');
      _setError('Gagal mengubah status favorit: ${e.toString()}');
      return false;
    }
  }

  // Check favorite status from server
  Future<void> checkFavoriteStatus(int toolId) async {
    try {
      final response = await _apiService.checkFavorite(toolId);
      if (response['success'] == true) {
        final bool isFavorited = response['is_favorited'] ?? false;
        _favoriteStatus[toolId] = isFavorited;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Exception in checkFavoriteStatus: $e');
    }
  }

  // Add tool to favorites list
  Future<void> _addToolToFavorites(int toolId) async {
    try {
      final response = await _apiService.getTool(toolId);
      if (response['success'] == true) {
        final tool = Tool.fromJson(response['data']);
        _favorites.add(tool);
      }
    } catch (e) {
      debugPrint('Exception in _addToolToFavorites: $e');
    }
  }

  // Clear all favorites
  void clearFavorites() {
    _favorites.clear();
    _favoriteStatus.clear();
    _clearError();
    notifyListeners();
  }

  // Private helper methods
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
  }
}