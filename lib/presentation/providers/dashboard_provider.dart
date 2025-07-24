import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService;
  
  DashboardProvider(this._apiService);
  
  UserStatistics? _userStatistics;
  bool _isLoading = false;
  String? _errorMessage;
  
  UserStatistics? get userStatistics => _userStatistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadDashboardStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.getDashboardStats();
      
      if (response['success'] == true && response['data'] != null) {
        _userStatistics = UserStatistics.fromJson(response['data']);
      } else {
        _errorMessage = response['message'] ?? 'Gagal memuat statistik';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      debugPrint('Error loading dashboard stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}