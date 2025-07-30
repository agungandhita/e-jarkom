import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/category_model.dart';
import '../datasources/local_storage.dart';

class CategoryRepository {
  final http.Client _client = http.Client();
  
  // Get authentication headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await LocalStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Get all categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.categories}'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> categoriesData = data['data'] ?? [];
          final categories = categoriesData.map((json) => CategoryModel.fromJson(json)).toList();
          
          // Cache the results
          await _cacheCategories(categories);
          
          return categories;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch categories');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Try to get cached data if available
      final cachedCategories = await _getCachedCategories();
      if (cachedCategories.isNotEmpty) {
        return cachedCategories;
      }
      
      throw Exception('Failed to fetch categories: $e');
    }
  }
  
  // Get category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.categories}/$id'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final categoryData = data['data'];
          final category = CategoryModel.fromJson(categoryData);
          
          return category;
        } else {
          throw Exception(data['message'] ?? 'Category not found');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }
  
  // Cache methods
  Future<void> _cacheCategories(List<CategoryModel> categories) async {
    final cacheData = {
      'categories': categories.map((category) => category.toJson()).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await LocalStorage.saveCache('categories', cacheData);
  }
  
  Future<List<CategoryModel>> _getCachedCategories() async {
    final cacheData = await LocalStorage.getCache('categories');
    if (cacheData != null) {
      final categoriesData = cacheData['categories'] as List?;
      if (categoriesData != null) {
        return categoriesData.map((json) => CategoryModel.fromJson(json)).toList();
      }
    }
    return [];
  }
  
  // Clear cache
  Future<void> clearCache() async {
    await LocalStorage.removeCache('categories');
  }
}