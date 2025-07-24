import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../domain/entities/tool.dart';
import '../../domain/entities/category.dart';
import '../datasources/local_storage.dart';

class ToolRepository {
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
  
  // Get all tools with pagination and filters
  Future<ToolResult> getTools({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null && categoryId.isNotEmpty) 'category_id': categoryId,
        if (sortBy != null) 'sort_by': sortBy,
        if (sortOrder != null) 'sort_order': sortOrder,
      };
      
      final uri = Uri.parse('${AppConstants.baseUrl}/tools').replace(
        queryParameters: queryParams,
      );
      
      final response = await _client.get(
        uri,
        headers: _authHeaders,
      ).timeout(AppConstants.apiTimeout);
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['success'] == true) {
        final toolsData = data['data']['tools'] as List;
        final tools = toolsData.map((json) => Tool.fromJson(json)).toList();
        
        final meta = data['data']['meta'] as Map<String, dynamic>?;
        
        // Cache the data for offline access
        await _cacheTools(tools, page);
        
        return ToolResult.success(
          tools: tools,
          totalCount: meta?['total'] ?? tools.length,
          currentPage: meta?['current_page'] ?? page,
          totalPages: meta?['total_pages'] ?? 1,
          hasNextPage: meta?['has_next_page'] ?? false,
        );
      } else {
        return ToolResult.failure(
          message: data['message'] ?? 'Failed to fetch tools',
        );
      }
    } on SocketException {
      // Try to get cached data
      final cachedTools = await _getCachedTools(page);
      if (cachedTools.isNotEmpty) {
        return ToolResult.success(
          tools: cachedTools,
          totalCount: cachedTools.length,
          currentPage: page,
          totalPages: 1,
          hasNextPage: false,
          isFromCache: true,
        );
      }
      return ToolResult.failure(message: AppConstants.networkError);
    } on http.ClientException {
      return ToolResult.failure(message: AppConstants.networkError);
    } catch (e) {
      return ToolResult.failure(message: AppConstants.unknownError);
    }
  }
  
  // Get tool by ID
  Future<ToolResult> getToolById(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}/tools/$id'),
        headers: _authHeaders,
      ).timeout(AppConstants.apiTimeout);
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['success'] == true) {
        final toolData = data['data'] as Map<String, dynamic>;
        final tool = Tool.fromJson(toolData);
        
        // Cache the tool
        await _cacheTool(tool);
        
        return ToolResult.success(tools: [tool]);
      } else {
        return ToolResult.failure(
          message: data['message'] ?? 'Tool not found',
        );
      }
    } on SocketException {
      // Try to get cached tool
      final cachedTool = await _getCachedTool(id);
      if (cachedTool != null) {
        return ToolResult.success(
          tools: [cachedTool],
          isFromCache: true,
        );
      }
      return ToolResult.failure(message: AppConstants.networkError);
    } on http.ClientException {
      return ToolResult.failure(message: AppConstants.networkError);
    } catch (e) {
      return ToolResult.failure(message: AppConstants.unknownError);
    }
  }
  
  // Create new tool (admin/teacher only)
  Future<ToolResult> createTool({
    required String name,
    required String description,
    required String function,
    required String categoryId,
    File? image,
    String? videoUrl,
    File? pdfFile,
    List<String>? tags,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.baseUrl}/tools'),
      );
      
      // Add headers
      request.headers.addAll(_authHeaders);
      
      // Add fields
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['function'] = function;
      request.fields['category_id'] = categoryId;
      
      if (videoUrl != null && videoUrl.isNotEmpty) {
        request.fields['video_url'] = videoUrl;
      }
      
      if (tags != null && tags.isNotEmpty) {
        request.fields['tags'] = jsonEncode(tags);
      }
      
      // Add image file
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
          ),
        );
      }
      
      // Add PDF file
      if (pdfFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'pdf_file',
            pdfFile.path,
          ),
        );
      }
      
      final streamedResponse = await request.send().timeout(AppConstants.apiTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 201 && data['success'] == true) {
        final toolData = data['data'] as Map<String, dynamic>;
        final tool = Tool.fromJson(toolData);
        
        return ToolResult.success(tools: [tool]);
      } else {
        return ToolResult.failure(
          message: data['message'] ?? 'Failed to create tool',
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
      return ToolResult.failure(message: AppConstants.networkError);
    } on http.ClientException {
      return ToolResult.failure(message: AppConstants.networkError);
    } catch (e) {
      return ToolResult.failure(message: AppConstants.unknownError);
    }
  }
  
  // Update tool (admin/teacher only)
  Future<ToolResult> updateTool({
    required String id,
    String? name,
    String? description,
    String? function,
    String? categoryId,
    File? image,
    String? videoUrl,
    File? pdfFile,
    List<String>? tags,
  }) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${AppConstants.baseUrl}/tools/$id'),
      );
      
      // Add headers
      request.headers.addAll(_authHeaders);
      
      // Add fields
      if (name != null) request.fields['name'] = name;
      if (description != null) request.fields['description'] = description;
      if (function != null) request.fields['function'] = function;
      if (categoryId != null) request.fields['category_id'] = categoryId;
      if (videoUrl != null) request.fields['video_url'] = videoUrl;
      
      if (tags != null) {
        request.fields['tags'] = jsonEncode(tags);
      }
      
      // Add image file
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
          ),
        );
      }
      
      // Add PDF file
      if (pdfFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'pdf_file',
            pdfFile.path,
          ),
        );
      }
      
      final streamedResponse = await request.send().timeout(AppConstants.apiTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['success'] == true) {
        final toolData = data['data'] as Map<String, dynamic>;
        final tool = Tool.fromJson(toolData);
        
        return ToolResult.success(tools: [tool]);
      } else {
        return ToolResult.failure(
          message: data['message'] ?? 'Failed to update tool',
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
      return ToolResult.failure(message: AppConstants.networkError);
    } on http.ClientException {
      return ToolResult.failure(message: AppConstants.networkError);
    } catch (e) {
      return ToolResult.failure(message: AppConstants.unknownError);
    }
  }
  
  // Delete tool (admin/teacher only)
  Future<ToolResult> deleteTool(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse('${AppConstants.baseUrl}/tools/$id'),
        headers: _authHeaders,
      ).timeout(AppConstants.apiTimeout);
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['success'] == true) {
        // Remove from cache
        await _removeCachedTool(id);
        
        return ToolResult.success();
      } else {
        return ToolResult.failure(
          message: data['message'] ?? 'Failed to delete tool',
        );
      }
    } on SocketException {
      return ToolResult.failure(message: AppConstants.networkError);
    } on http.ClientException {
      return ToolResult.failure(message: AppConstants.networkError);
    } catch (e) {
      return ToolResult.failure(message: AppConstants.unknownError);
    }
  }
  
  // Get categories
  Future<CategoryResult> getCategories() async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}/categories'),
        headers: _authHeaders,
      ).timeout(AppConstants.apiTimeout);
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['success'] == true) {
        final categoriesData = data['data'] as List;
        final categories = categoriesData.map((json) => Category.fromJson(json)).toList();
        
        // Cache categories
        await _cacheCategories(categories);
        
        return CategoryResult.success(categories: categories);
      } else {
        return CategoryResult.failure(
          message: data['message'] ?? 'Failed to fetch categories',
        );
      }
    } on SocketException {
      // Try to get cached categories
      final cachedCategories = await _getCachedCategories();
      if (cachedCategories.isNotEmpty) {
        return CategoryResult.success(
          categories: cachedCategories,
          isFromCache: true,
        );
      }
      return CategoryResult.failure(message: AppConstants.networkError);
    } on http.ClientException {
      return CategoryResult.failure(message: AppConstants.networkError);
    } catch (e) {
      return CategoryResult.failure(message: AppConstants.unknownError);
    }
  }
  
  // Cache methods
  Future<void> _cacheTools(List<Tool> tools, int page) async {
    final cacheData = {
      'tools': tools.map((tool) => tool.toJson()).toList(),
      'page': page,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await LocalStorage.saveCache('tools_page_$page', cacheData);
  }
  
  Future<List<Tool>> _getCachedTools(int page) async {
    final cacheData = LocalStorage.getCache('tools_page_$page');
    if (cacheData != null) {
      final toolsData = cacheData['tools'] as List?;
      if (toolsData != null) {
        return toolsData.map((json) => Tool.fromJson(json)).toList();
      }
    }
    return [];
  }
  
  Future<void> _cacheTool(Tool tool) async {
    final cacheData = {
      'tool': tool.toJson(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await LocalStorage.saveCache('tool_${tool.id}', cacheData);
  }
  
  Future<Tool?> _getCachedTool(String id) async {
    final cacheData = LocalStorage.getCache('tool_$id');
    if (cacheData != null) {
      final toolData = cacheData['tool'] as Map<String, dynamic>?;
      if (toolData != null) {
        return Tool.fromJson(toolData);
      }
    }
    return null;
  }
  
  Future<void> _removeCachedTool(String id) async {
    await LocalStorage.removeCache('tool_$id');
  }
  
  Future<void> _cacheCategories(List<Category> categories) async {
    final cacheData = {
      'categories': categories.map((category) => category.toJson()).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await LocalStorage.saveCache('categories', cacheData);
  }
  
  Future<List<Category>> _getCachedCategories() async {
    final cacheData = LocalStorage.getCache('categories');
    if (cacheData != null) {
      final categoriesData = cacheData['categories'] as List?;
      if (categoriesData != null) {
        return categoriesData.map((json) => Category.fromJson(json)).toList();
      }
    }
    return [];
  }
}

// Tool result class
class ToolResult {
  final bool isSuccess;
  final String? message;
  final List<Tool>? tools;
  final int? totalCount;
  final int? currentPage;
  final int? totalPages;
  final bool? hasNextPage;
  final Map<String, List<String>>? errors;
  final bool isFromCache;
  
  ToolResult._(
    this.isSuccess,
    this.message,
    this.tools,
    this.totalCount,
    this.currentPage,
    this.totalPages,
    this.hasNextPage,
    this.errors,
    this.isFromCache,
  );
  
  factory ToolResult.success({
    List<Tool>? tools,
    int? totalCount,
    int? currentPage,
    int? totalPages,
    bool? hasNextPage,
    bool isFromCache = false,
  }) {
    return ToolResult._(
      true,
      null,
      tools,
      totalCount,
      currentPage,
      totalPages,
      hasNextPage,
      null,
      isFromCache,
    );
  }
  
  factory ToolResult.failure({
    required String message,
    Map<String, List<String>>? errors,
  }) {
    return ToolResult._(false, message, null, null, null, null, null, errors, false);
  }
}

// Category result class
class CategoryResult {
  final bool isSuccess;
  final String? message;
  final List<Category>? categories;
  final bool isFromCache;
  
  CategoryResult._(this.isSuccess, this.message, this.categories, this.isFromCache);
  
  factory CategoryResult.success({
    List<Category>? categories,
    bool isFromCache = false,
  }) {
    return CategoryResult._(true, null, categories, isFromCache);
  }
  
  factory CategoryResult.failure({required String message}) {
    return CategoryResult._(false, message, null, false);
  }
}