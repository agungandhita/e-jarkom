import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../models/user_model.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthProvider(this._apiService, this._storageService) {
    _initializeAuth();
  }

  // Initialize authentication on startup
  Future<void> _initializeAuth() async {
    await _checkAuthStatus();
  }

  // State variables
  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;
  Map<String, List<String>>? _validationErrors;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  User? get currentUser => _currentUser;
  User? get user =>
      _currentUser; // Alias for currentUser to match dashboard usage
  String? get errorMessage => _errorMessage;
  Map<String, List<String>>? get validationErrors => _validationErrors;
  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _state == AuthState.authenticated && _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isTeacher => _currentUser?.role == 'teacher';
  bool get isStudent => _currentUser?.role == 'student';

  // Check authentication status on app start
  Future<void> _checkAuthStatus() async {
    final token = _storageService.getAuthToken();
    print(
      'DEBUG AuthProvider: Token from storage: ${token != null ? "[TOKEN_EXISTS]" : "null"}',
    );

    if (token != null) {
      _apiService.setToken(token);
      print('DEBUG AuthProvider: Token set in ApiService');

      final userData = _storageService.getUserData();
      if (userData != null) {
        _currentUser = User.fromJson(userData);
        _state = AuthState.authenticated;
        print('DEBUG AuthProvider: User authenticated - ${_currentUser?.name}');
        notifyListeners();

        // Refresh user data from server
        await refreshUser();
      } else {
        print(
          'DEBUG AuthProvider: No user data found, setting unauthenticated',
        );
        _state = AuthState.unauthenticated;
        notifyListeners();
      }
    } else {
      print('DEBUG AuthProvider: No token found, setting unauthenticated');
      _state = AuthState.unauthenticated;
      notifyListeners();
    }
  }

  // Login method
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearErrors();

    try {
      final response = await _apiService.login(email, password);

      if (response['success'] == true) {
        // Safe null checking for response data
        final responseData = response['data'];
        if (responseData == null) {
          _errorMessage = 'Data response tidak valid dari server';
          _state = AuthState.error;
          _setLoading(false);
          return false;
        }

        final userData = responseData['user'];
        final token = responseData['token'];

        if (userData == null || token == null) {
          _errorMessage = 'Data login tidak lengkap dari server';
          _state = AuthState.error;
          _setLoading(false);
          return false;
        }

        _currentUser = User.fromJson(userData);
        await _storageService.setAuthToken(token);
        await _storageService.setUserData(userData);
        _apiService.setToken(token);

        if (rememberMe) {
          await _storageService.setRememberMe(true);
          await _storageService.setSavedEmail(email);
        }

        _state = AuthState.authenticated;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Login gagal';
        _state = AuthState.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.error;
      _setLoading(false);
      return false;
    }
  }

  // Register method
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String kelas,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _clearErrors();

    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        phone: phone,
        kelas: kelas,
        password: password,
        passwordConfirmation: passwordConfirmation,
        bio: null, // Optional bio field
      );

      print('Register response: $response'); // Debug log

      // Safe null checking for response
      if (response == null) {
        _errorMessage = 'Response tidak valid dari server';
        _state = AuthState.error;
        _setLoading(false);
        return false;
      }

      final bool isSuccess = response['success'] == true;
      if (isSuccess) {
        // Safe extraction of data
        final Map<String, dynamic>? responseData =
            response['data'] as Map<String, dynamic>?;

        dynamic userData;
        String? token;

        if (responseData != null) {
          // Check if user data is nested in data.user or directly in data
          if (responseData.containsKey('user') &&
              responseData['user'] != null) {
            userData = responseData['user'];
          } else {
            userData = responseData;
          }

          // Safe token extraction
          token = responseData['token'] as String?;
        } else {
          // Fallback: check if user data is directly in response
          userData = response['user'];
          token = response['token'] as String?;
        }

        print('UserData: $userData'); // Debug log
        print('Token: $token'); // Debug log

        if (userData != null && token != null && token.isNotEmpty) {
          try {
            _currentUser = User.fromJson(userData);
            await _storageService.setAuthToken(token);
            await _storageService.setUserData(userData);
            _apiService.setToken(token);

            _state = AuthState.authenticated;
            _setLoading(false);
            return true;
          } catch (parseError) {
            print('Error parsing user data: $parseError');
            _errorMessage = 'Gagal memproses data pengguna';
            _state = AuthState.error;
            _setLoading(false);
            return false;
          }
        } else {
          // More detailed error message
          List<String> missingData = [];
          if (userData == null) missingData.add('data pengguna');
          if (token == null || token.isEmpty)
            missingData.add('token autentikasi');

          _errorMessage =
              'Registrasi berhasil tetapi ${missingData.join(' dan ')} tidak ditemukan';
          print('Missing data: ${missingData.join(', ')}'); // Debug log
          _state = AuthState.error;
          _setLoading(false);
          return false;
        }
      } else {
        final String errorMsg =
            response['message'] as String? ?? 'Registrasi gagal';
        _errorMessage = errorMsg;
        _state = AuthState.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('Register error: $e'); // Debug log

      // Handle specific error types
      String errorMessage = 'Registrasi gagal';

      if (e.toString().contains('422')) {
        errorMessage =
            'Data registrasi tidak valid. Periksa kembali data yang dimasukkan.';
      } else if (e.toString().contains('409')) {
        errorMessage = 'Email sudah terdaftar. Silakan gunakan email lain.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Terjadi kesalahan pada server. Silakan coba lagi.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        errorMessage = 'Tidak ada koneksi internet. Periksa koneksi Anda.';
      } else {
        errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      }

      _errorMessage = errorMessage;
      _state = AuthState.error;
      _setLoading(false);
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }

    await _storageService.clearAuthToken();
    await _storageService.clearUserData();

    _currentUser = null;
    _state = AuthState.unauthenticated;
    _clearErrors();
    _setLoading(false);
  }

  // Refresh user data
  Future<bool> refreshUser() async {
    if (!isAuthenticated) return false;

    try {
      final response = await _apiService.getProfile();

      if (response['success'] == true) {
        final userData = response['data'];
        if (userData != null) {
          _currentUser = User.fromJson(userData);
          await _storageService.setUserData(userData);
          notifyListeners();
          return true;
        } else {
          return false;
        }
      } else {
        // If refresh fails, user might be logged out
        if (response['message']?.contains('Unauthorized') == true ||
            response['message']?.contains('Token') == true) {
          await logout();
        }
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Update profile method
  Future<bool> updateProfile({
    required String nama,
    required String kelas,
    File? profileImage,
  }) async {
    _setLoading(true);
    _clearErrors();

    try {
      final response = await _apiService.updateProfile(
        nama: nama,
        kelas: kelas,
        profileImage: profileImage,
      );

      if (response['success'] == true) {
        final userData = response['data'];
        _currentUser = User.fromJson(userData);
        await _storageService.setUserData(userData);
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Update profil gagal';
        _state = AuthState.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = AuthState.error;
      _setLoading(false);
      return false;
    }
  }

  // Change password method
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _clearErrors();

    try {
      final response = await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        passwordConfirmation: passwordConfirmation,
      );

      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Ubah password gagal';
        _state = AuthState.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan yang tidak diketahui';
      _state = AuthState.error;
      _setLoading(false);
      return false;
    }
  }

  // Forgot password method
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearErrors();

    try {
      final response = await _apiService.forgotPassword(email);

      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Reset password gagal';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearErrors() {
    _errorMessage = null;
    _validationErrors = null;
    if (_state == AuthState.error) {
      _state = _currentUser != null
          ? AuthState.authenticated
          : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // Clear all errors manually
  void clearErrors() {
    _clearErrors();
  }

  // Get validation error for specific field
  String? getFieldError(String field) {
    if (_validationErrors != null && _validationErrors!.containsKey(field)) {
      final fieldErrors = _validationErrors![field]!;
      return fieldErrors.isNotEmpty ? fieldErrors.first : null;
    }
    return null;
  }

  // Get all validation errors as a single string
  String? get allValidationErrors {
    if (_validationErrors != null && _validationErrors!.isNotEmpty) {
      final allMessages = <String>[];
      _validationErrors!.forEach((field, messages) {
        allMessages.addAll(messages);
      });
      return allMessages.join('\n');
    }
    return null;
  }

  // Check if user has specific permission
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;

    // Admin has all permissions
    if (_currentUser!.isAdmin) return true;

    // Add specific permission logic here based on your requirements
    switch (permission) {
      case 'manage_tools':
        return _currentUser!.isAdmin || _currentUser!.isTeacher;
      case 'manage_quizzes':
        return _currentUser!.isAdmin || _currentUser!.isTeacher;
      case 'manage_videos':
        return _currentUser!.isAdmin || _currentUser!.isTeacher;
      case 'view_analytics':
        return _currentUser!.isAdmin || _currentUser!.isTeacher;
      default:
        return false;
    }
  }

  // Force logout (for token expiration, etc.)
  Future<void> forceLogout() async {
    await _storageService.clearAuthToken();
    await _storageService.clearUserData();
    _currentUser = null;
    _state = AuthState.unauthenticated;
    _clearErrors();
  }

  // Get saved credentials for remember me functionality
  Map<String, dynamic> getSavedCredentials() {
    return {
      'email': _storageService.getSavedEmail() ?? '',
      'rememberMe': _storageService.getRememberMe(),
    };
  }

  // Clear saved credentials
  Future<void> clearSavedCredentials() async {
    await _storageService.clearSavedCredentials();
  }

  Future<String?> getSavedEmail() async {
    return _storageService.getSavedEmail();
  }
}
