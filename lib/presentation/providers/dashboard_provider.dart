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
      debugPrint('DashboardProvider: Starting to load dashboard stats...');
      final response = await _apiService.getDashboardStats();
      
      debugPrint('DashboardProvider: API Response: $response');
      debugPrint('DashboardProvider: Response success: ${response['success']}');
      debugPrint('DashboardProvider: Response data: ${response['data']}');
      
      if (response['success'] == true && response['data'] != null) {
        _userStatistics = UserStatistics.fromJson(response['data']);
        debugPrint('DashboardProvider: Successfully parsed UserStatistics: $_userStatistics');
      } else {
        _errorMessage = response['message'] ?? 'Gagal memuat statistik';
        debugPrint('DashboardProvider: API returned error: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      debugPrint('DashboardProvider: Exception occurred: $e');
      debugPrint('DashboardProvider: Exception type: ${e.runtimeType}');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('DashboardProvider: Loading completed. Statistics: $_userStatistics');
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}