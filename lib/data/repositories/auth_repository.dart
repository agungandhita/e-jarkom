import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart';
import '../datasources/local_storage.dart';

class AuthRepository {
  final http.Client _client = http.Client();
  
  // Base headers for API requests
  Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Headers with authentication token
  Map<String, String> get _authHeaders {
    final token = LocalStorage.getToken();
    return {
      ..._baseHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Login user
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseUrl}/login'),
        headers: _baseHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(AppConstants.apiTimeout);
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']['token'] as String;
        final userData = data['data']['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        
        // Save token and user data locally
        await LocalStorage.saveToken(token);
        await LocalStorage.saveUser(user);
        
        return AuthResult.success(user: user, token: token);
      } else {
        return AuthResult.failure(
          message: data['message'] ?? 'Login failed',
        );
      }
    } on SocketException {
      return AuthResult.failure(message: AppConstants.networkError);
    } on http.ClientException {
      return AuthResult.failure(message: AppConstants.networkError);
    } catch (e) {
      return AuthResult.failure(message: AppConstants.unknownError);
    }
  }
  
  // Register user
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? kelas,
    String? phone,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseUrl}/register'),
        headers: _baseHeaders,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
          'kelas': kelas,
          'phone': phone,
        }),
      ).timeout(AppConstants.apiTimeout);
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 201 && data['success'] == true) {
        final token = data['data']['token'] as String;
        final userData = data['data']['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        
        // Save token and user data locally
        await LocalStorage.saveToken(token);
        await LocalStorage.saveUser(user);
        
        return AuthResult.success(user: user, token: token);
      } else {
        return AuthResult.failure(
          message: data['message'] ?? 'Registration failed',
          errors: data['errors'] != null 
              ? Map<String, List<String>>.from(
                  data['errors'].map((key, value) => MapEntry(
                    key,
                    List<String>.from(value),
                  )),
                )
              : null,
        );
      }
    } on SocketException {
      return AuthResult.failure(message: AppConstants.networkError);
    } on http.ClientException {
      return AuthResult.failure(message: AppConstants.networkError);
    } catch (e) {
      return AuthResult.failure(message: AppConstants.unknownError);
    }
  }
  
  // Logout user
  Future<AuthResult> logout() async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseUrl}/logout'),
        headers: _authHeaders,
      ).timeout(AppConstants.apiTimeout);
      
      // Clear local data regardless of API response
      await LocalStorage.removeToken();
      await LocalStorage.removeUser();
      
      if (response.statusCode == 200) {
        return AuthResult.success();
      } else {
        // Still return success since local data is cleared
        return AuthResult.success();
      }
    } catch (e) {
      // Clear local data even if API call fails
      await LocalStorage.removeToken();
      await LocalStorage.removeUser();
      return AuthResult.success();
    }
  }
  
  // Get current user profile
  Future<AuthResult> getCurrentUser() async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}/profile'),
        headers: _authHeaders,
      ).timeout(AppConstants.apiTimeout);
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['success'] == true) {
        final userData = data['data'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        
        // Update local user data
        await LocalStorage.saveUser(user);
        
        return AuthResult.success(user: user);
      } else {
        return AuthResult.failure(
          message: data['message'] ?? 'Failed to get user profile',
        );
      }
    } on SocketException {
      return AuthResult.failure(message: AppConstants.networkError);
    } on http.ClientException {
      return AuthResult.failure(message: AppConstants.networkError);
    } catch (e) {
      return AuthResult.failure(message: AppConstants.unknownError);
    }
  }
  
  // Update user profile
  Future<AuthResult> updateProfile({
    String? name,
    String? phone,
    String? className,
    File? profileImage,
  }) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${AppConstants.baseUrl}/profile'),
      );
      
      // Add headers
      request.headers.addAll(_authHeaders);
      
      // Add fields
      if (name != null) request.fields['name'] = name;
      if (phone != null) request.fields['phone'] = phone;
      if (className != null) request.fields['class_name'] = className;
      
      // Add profile image if provided
      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            profileImage.path,
          ),
        );
      }
      
      final streamedResponse = await request.send().timeout(AppConstants.apiTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['success'] == true) {
        final userData = data['data'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        
        // Update local user data
        await LocalStorage.saveUser(user);
        
        return AuthResult.success(user: user);
      } else {
        return AuthResult.failure(
          message: data['message'] ?? 'Failed to update profile',
          errors: data['errors'] != null 
              ? Map<String, List<String>>.from(
                  data['errors'].map((key, value) => MapEntry(
                    key,
                    List<String>.from(value),
                  )),
                )
              : null,
        );
      }
    } on SocketException {
      return AuthResult.failure(message: AppConstants.networkError);
    } on http.ClientException {
      return AuthResult.failure(message: AppConstants.networkError);
    } catch (e) {
      return AuthResult.failure(message: AppConstants.unknownError);
    }
  }
  
  // Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('${AppConstants.baseUrl}/change-password'),
        headers: _authHeaders,
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      ).timeout(AppConstants.apiTimeout);
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['success'] == true) {
        return AuthResult.success();
      } else {
        return AuthResult.failure(
          message: data['message'] ?? 'Failed to change password',
          errors: data['errors'] != null 
              ? Map<String, List<String>>.from(
                  data['errors'].map((key, value) => MapEntry(
                    key,
                    List<String>.from(value),
                  )),
                )
              : null,
        );
      }
    } on SocketException {
      return AuthResult.failure(message: AppConstants.networkError);
    } on http.ClientException {
      return AuthResult.failure(message: AppConstants.networkError);
    } catch (e) {
      return AuthResult.failure(message: AppConstants.unknownError);
    }
  }
  
  // Forgot password
  Future<AuthResult> forgotPassword(String email) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseUrl}/forgot-password'),
        headers: _baseHeaders,
        body: jsonEncode({
          'email': email,
        }),
      ).timeout(AppConstants.apiTimeout);
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['success'] == true) {
        return AuthResult.success();
      } else {
        return AuthResult.failure(
          message: data['message'] ?? 'Failed to send reset email',
        );
      }
    } on SocketException {
      return AuthResult.failure(message: AppConstants.networkError);
    } on http.ClientException {
      return AuthResult.failure(message: AppConstants.networkError);
    } catch (e) {
      return AuthResult.failure(message: AppConstants.unknownError);
    }
  }
  
  // Check if user is authenticated
  bool isAuthenticated() {
    return LocalStorage.hasToken() && LocalStorage.hasUser();
  }
  
  // Get local user data
  User? getLocalUser() {
    return LocalStorage.getUser();
  }
  
  // Get local token
  String? getLocalToken() {
    return LocalStorage.getToken();
  }
  
  // Clear local auth data
  Future<void> clearLocalAuth() async {
    await LocalStorage.removeToken();
    await LocalStorage.removeUser();
  }
}

// Auth result class
class AuthResult {
  final bool isSuccess;
  final String? message;
  final User? user;
  final String? token;
  final Map<String, List<String>>? errors;
  
  AuthResult._(
    this.isSuccess,
    this.message,
    this.user,
    this.token,
    this.errors,
  );
  
  factory AuthResult.success({User? user, String? token}) {
    return AuthResult._(true, null, user, token, null);
  }
  
  factory AuthResult.failure({
    required String message,
    Map<String, List<String>>? errors,
  }) {
    return AuthResult._(false, message, null, null, errors);
  }
  
  // Get first error message for a field
  String? getFieldError(String field) {
    if (errors != null && errors!.containsKey(field)) {
      final fieldErrors = errors![field]!;
      return fieldErrors.isNotEmpty ? fieldErrors.first : null;
    }
    return null;
  }
  
  // Get all error messages as a single string
  String? get allErrors {
    if (errors != null && errors!.isNotEmpty) {
      final allMessages = <String>[];
      errors!.forEach((field, messages) {
        allMessages.addAll(messages);
      });
      return allMessages.join('\n');
    }
    return message;
  }
}