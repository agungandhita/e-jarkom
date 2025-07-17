import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Ensiklopedia Alat Teknik';
  static const String appVersion = '1.0.0';
  static const String appDescription = 
      'Aplikasi ensiklopedia alat teknik interaktif untuk siswa SMK. '
      'Berisi informasi lengkap tentang berbagai alat teknik, video pembelajaran, '
      'dan kuis interaktif untuk meningkatkan pemahaman.';
  
  static const String developerName = 'Tim Pengembang SMK';
  static const String developerEmail = 'developer@smk.edu';
  static const String developerPhone = '+62 812-3456-7890';

  // Colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF03DAC6), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  // Border Radius for UI Components
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(radiusMedium));

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 3);

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  // Menu Items
  static const List<Map<String, dynamic>> mainMenuItems = [
    {
      'title': 'Ensiklopedia',
      'subtitle': 'Jelajahi alat teknik',
      'icon': Icons.book,
      'route': '/encyclopedia',
      'color': Color(0xFF1976D2),
    },
    {
      'title': 'Video Pembelajaran',
      'subtitle': 'Tutorial dan panduan',
      'icon': Icons.play_circle_fill,
      'route': '/videos',
      'color': Color(0xFFE91E63),
    },
    {
      'title': 'Kuis Interaktif',
      'subtitle': 'Uji pengetahuan Anda',
      'icon': Icons.quiz,
      'route': '/quiz',
      'color': Color(0xFF4CAF50),
    },
    {
      'title': 'Tentang Aplikasi',
      'subtitle': 'Info dan kontak',
      'icon': Icons.info,
      'route': '/about',
      'color': Color(0xFFFF9800),
    },
  ];

  // Quiz Levels
  static const List<String> quizLevels = ['easy', 'medium', 'hard'];
  
  static const Map<String, Color> quizLevelColors = {
    'easy': Color(0xFF4CAF50),
    'medium': Color(0xFFFF9800),
    'hard': Color(0xFFE91E63),
  };

  // Tool Categories
  static const List<String> toolCategories = [
    'Hand Tools',
    'Measuring Tools',
    'Electronic Tools',
    'Network Tools',
    'Power Tools',
    'Safety Equipment',
  ];
}