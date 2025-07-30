import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/themes/app_theme.dart';
import 'data/repositories/video_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/tool_provider.dart';
import 'presentation/providers/quiz_provider.dart';
import 'presentation/providers/video_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  final apiService = ApiService();

  runApp(MyApp(storageService: storageService, apiService: apiService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final ApiService apiService;

  const MyApp({
    super.key,
    required this.storageService,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiService, storageService),
        ),
        ChangeNotifierProvider(create: (_) => ToolProvider(apiService)),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(apiService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              VideoProvider(VideoRepository.fromApiService(apiService)),
        ),
        ChangeNotifierProvider(create: (_) => CategoryProvider(apiService)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(apiService)),
      ],
      child: MaterialApp(
        title: 'Ensiklopedia Alat SMK',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
