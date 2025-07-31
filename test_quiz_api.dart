import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();

  // Configure Dio with the same settings as the app
  dio.options.baseUrl = 'https://538785daec69.ngrok-free.app/api';
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
    'User-Agent': 'Flutter-App/1.0',
  };
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);

  try {
    print('Testing quiz API endpoint...');
    print('Making request to: /quizzes/sulit');

    final response = await dio.get('/quizzes/sulit');

    print('\n=== API Response ===');
    print('Status Code: ${response.statusCode}');
    print('Status Message: ${response.statusMessage}');
    print('Headers: ${response.headers}');
    print('\n=== Response Data ===');
    print('Data Type: ${response.data.runtimeType}');
    print('Raw Data: ${response.data}');

    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      print('\n=== Parsed Response ===');
      print('Success: ${data['success']}');
      print('Message: ${data['message']}');
      print('Data: ${data['data']}');
      print('Data Type: ${data['data']?.runtimeType}');

      if (data['data'] != null) {
        if (data['data'] is List) {
          final list = data['data'] as List;
          print('Data is List with ${list.length} items');
          if (list.isNotEmpty) {
            print('First item: ${list.first}');
          }
        } else if (data['data'] is Map) {
          final map = data['data'] as Map;
          print('Data is Map with keys: ${map.keys}');
          if (map.containsKey('data')) {
            final innerData = map['data'];
            print('Inner data type: ${innerData.runtimeType}');
            if (innerData is List) {
              print('Inner data is List with ${innerData.length} items');
              if (innerData.isNotEmpty) {
                print('First inner item: ${innerData.first}');
              }
            }
          }
        }
      }
    }
  } catch (e) {
    print('\n=== Error ===');
    print('Error: $e');
    if (e is DioException) {
      print('DioException Type: ${e.type}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Headers: ${e.response?.headers}');
    }
  }
}
