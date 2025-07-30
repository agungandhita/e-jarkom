import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';
  static const String _quizScoresKey = 'quiz_scores';
  static const String _toolsKey = 'tools_cache';
  static const String _videosKey = 'videos_cache';
  static const String _categoriesKey = 'categories_cache';

  // Auth Token
  Future<void> setAuthToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getAuthToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove(_tokenKey);
  }

  // User Data
  Future<void> setUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(_userKey, json.encode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final userDataString = _prefs.getString(_userKey);
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }

  Future<void> clearUserData() async {
    await _prefs.remove(_userKey);
  }

  // Theme
  Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString(_themeKey, themeMode);
  }

  String? getThemeMode() {
    return _prefs.getString(_themeKey);
  }

  // Language
  Future<void> setLanguage(String language) async {
    await _prefs.setString(_languageKey, language);
  }

  String? getLanguage() {
    return _prefs.getString(_languageKey);
  }

  // Onboarding
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingKey, completed);
  }

  bool getOnboardingCompleted() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  // Remember Me
  Future<void> setRememberMe(bool remember) async {
    await _prefs.setBool(_rememberMeKey, remember);
  }

  bool getRememberMe() {
    return _prefs.getBool(_rememberMeKey) ?? false;
  }

  // Saved Credentials
  Future<void> setSavedEmail(String email) async {
    await _prefs.setString(_savedEmailKey, email);
  }

  String? getSavedEmail() {
    return _prefs.getString(_savedEmailKey);
  }

  Future<void> setSavedPassword(String password) async {
    await _prefs.setString(_savedPasswordKey, password);
  }

  String? getSavedPassword() {
    return _prefs.getString(_savedPasswordKey);
  }

  Future<void> clearSavedCredentials() async {
    await _prefs.remove(_savedEmailKey);
    await _prefs.remove(_savedPasswordKey);
    await _prefs.remove(_rememberMeKey);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Generic methods
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Quiz Scores Cache
  Future<void> setQuizScores(List<Map<String, dynamic>> scores) async {
    await _prefs.setString(_quizScoresKey, json.encode(scores));
  }

  List<Map<String, dynamic>>? getQuizScores() {
    final scoresString = _prefs.getString(_quizScoresKey);
    if (scoresString != null) {
      final List<dynamic> scoresList = json.decode(scoresString);
      return scoresList.cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> clearQuizScores() async {
    await _prefs.remove(_quizScoresKey);
  }

  // Tools Cache
  Future<void> setToolsCache(List<Map<String, dynamic>> tools) async {
    await _prefs.setString(_toolsKey, json.encode(tools));
  }

  List<Map<String, dynamic>>? getToolsCache() {
    final toolsString = _prefs.getString(_toolsKey);
    if (toolsString != null) {
      final List<dynamic> toolsList = json.decode(toolsString);
      return toolsList.cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> clearToolsCache() async {
    await _prefs.remove(_toolsKey);
  }

  // Videos Cache
  Future<void> setVideosCache(List<Map<String, dynamic>> videos) async {
    await _prefs.setString(_videosKey, json.encode(videos));
  }

  List<Map<String, dynamic>>? getVideosCache() {
    final videosString = _prefs.getString(_videosKey);
    if (videosString != null) {
      final List<dynamic> videosList = json.decode(videosString);
      return videosList.cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> clearVideosCache() async {
    await _prefs.remove(_videosKey);
  }

  // Categories Cache
  Future<void> setCategoriesCache(List<Map<String, dynamic>> categories) async {
    await _prefs.setString(_categoriesKey, json.encode(categories));
  }

  List<Map<String, dynamic>>? getCategoriesCache() {
    final categoriesString = _prefs.getString(_categoriesKey);
    if (categoriesString != null) {
      final List<dynamic> categoriesList = json.decode(categoriesString);
      return categoriesList.cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> clearCategoriesCache() async {
    await _prefs.remove(_categoriesKey);
  }
}
