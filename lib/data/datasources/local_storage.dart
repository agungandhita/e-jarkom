import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart';

class LocalStorage {
  static SharedPreferences? _prefs;
  
  // Initialize SharedPreferences
  static Future<void> initialize(SharedPreferences prefs) async {
    _prefs = prefs;
  }
  
  // Get SharedPreferences instance
  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw Exception('LocalStorage not initialized. Call initialize() first.');
    }
    return _prefs!;
  }
  
  // Auth Token Methods
  static Future<bool> saveToken(String token) async {
    return await _instance.setString(AppConstants.tokenKey, token);
  }
  
  static String? getToken() {
    return _instance.getString(AppConstants.tokenKey);
  }
  
  static Future<bool> removeToken() async {
    return await _instance.remove(AppConstants.tokenKey);
  }
  
  static bool hasToken() {
    return _instance.containsKey(AppConstants.tokenKey);
  }
  
  // User Data Methods
  static Future<bool> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    return await _instance.setString(AppConstants.userKey, userJson);
  }
  
  static User? getUser() {
    final userJson = _instance.getString(AppConstants.userKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  static Future<bool> removeUser() async {
    return await _instance.remove(AppConstants.userKey);
  }
  
  static bool hasUser() {
    return _instance.containsKey(AppConstants.userKey);
  }
  
  // Theme Methods
  static Future<bool> saveThemeMode(String themeMode) async {
    return await _instance.setString(AppConstants.themeKey, themeMode);
  }
  
  static String getThemeMode() {
    return _instance.getString(AppConstants.themeKey) ?? 'system';
  }
  
  // Language Methods
  static Future<bool> saveLanguage(String language) async {
    return await _instance.setString(AppConstants.languageKey, language);
  }
  
  static String getLanguage() {
    return _instance.getString(AppConstants.languageKey) ?? 'id';
  }
  
  // Onboarding Methods
  static Future<bool> setOnboardingCompleted() async {
    return await _instance.setBool(AppConstants.onboardingKey, true);
  }
  
  static bool isOnboardingCompleted() {
    return _instance.getBool(AppConstants.onboardingKey) ?? false;
  }
  
  // Generic Methods
  static Future<bool> saveString(String key, String value) async {
    return await _instance.setString(key, value);
  }
  
  static String? getString(String key) {
    return _instance.getString(key);
  }
  
  static Future<bool> saveInt(String key, int value) async {
    return await _instance.setInt(key, value);
  }
  
  static int? getInt(String key) {
    return _instance.getInt(key);
  }
  
  static Future<bool> saveBool(String key, bool value) async {
    return await _instance.setBool(key, value);
  }
  
  static bool? getBool(String key) {
    return _instance.getBool(key);
  }
  
  static Future<bool> saveDouble(String key, double value) async {
    return await _instance.setDouble(key, value);
  }
  
  static double? getDouble(String key) {
    return _instance.getDouble(key);
  }
  
  static Future<bool> saveStringList(String key, List<String> value) async {
    return await _instance.setStringList(key, value);
  }
  
  static List<String>? getStringList(String key) {
    return _instance.getStringList(key);
  }
  
  static Future<bool> remove(String key) async {
    return await _instance.remove(key);
  }
  
  static bool containsKey(String key) {
    return _instance.containsKey(key);
  }
  
  static Future<bool> clear() async {
    return await _instance.clear();
  }
  
  static Set<String> getKeys() {
    return _instance.getKeys();
  }
  
  // Cache Methods for Offline Support
  static Future<bool> saveCache(String key, Map<String, dynamic> data) async {
    final cacheJson = jsonEncode(data);
    return await _instance.setString('cache_$key', cacheJson);
  }
  
  static Map<String, dynamic>? getCache(String key) {
    final cacheJson = _instance.getString('cache_$key');
    if (cacheJson != null) {
      try {
        return jsonDecode(cacheJson) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  static Future<bool> removeCache(String key) async {
    return await _instance.remove('cache_$key');
  }
  
  // Instance methods for compatibility with repositories
  Future<bool> cacheData(String key, dynamic data) async {
    final cacheJson = jsonEncode(data);
    return await _instance.setString('cache_$key', cacheJson);
  }
  
  Future<dynamic> getCachedData(String key) async {
    final cacheJson = _instance.getString('cache_$key');
    if (cacheJson != null) {
      try {
        return jsonDecode(cacheJson);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  Future<bool> removeData(String key) async {
    return await _instance.remove('cache_$key');
  }
  
  static Future<bool> clearCache() async {
    final keys = _instance.getKeys();
    final cacheKeys = keys.where((key) => key.startsWith('cache_')).toList();
    
    for (final key in cacheKeys) {
      await _instance.remove(key);
    }
    
    return true;
  }
  
  // Search History Methods
  static Future<bool> addSearchHistory(String query) async {
    final history = getSearchHistory();
    
    // Remove if already exists
    history.remove(query);
    
    // Add to beginning
    history.insert(0, query);
    
    // Keep only last 10 searches
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }
    
    return await saveStringList('search_history', history);
  }
  
  static List<String> getSearchHistory() {
    return getStringList('search_history') ?? [];
  }
  
  static Future<bool> clearSearchHistory() async {
    return await remove('search_history');
  }
  
  // Favorites Methods
  static Future<bool> addFavorite(String type, String id) async {
    final favorites = getFavorites(type);
    if (!favorites.contains(id)) {
      favorites.add(id);
      return await saveStringList('favorites_$type', favorites);
    }
    return true;
  }
  
  static Future<bool> removeFavorite(String type, String id) async {
    final favorites = getFavorites(type);
    favorites.remove(id);
    return await saveStringList('favorites_$type', favorites);
  }
  
  static List<String> getFavorites(String type) {
    return getStringList('favorites_$type') ?? [];
  }
  
  static bool isFavorite(String type, String id) {
    return getFavorites(type).contains(id);
  }
  
  static Future<bool> clearFavorites(String type) async {
    return await remove('favorites_$type');
  }
}