import 'package:flutter/material.dart';

class AppConstants {
  // ==================== GRADIENTS ====================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== APP INFO ====================
  static const String appName = 'Ensiklopedia Alat SMK';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Aplikasi ensiklopedia alat SMK dengan fitur quiz interaktif';

  // ==================== API CONFIGURATION ====================
  static const String baseUrl = 'https://api.example.com/api';
  static const Duration apiTimeout = Duration(seconds: 30);

  // ==================== STORAGE KEYS ====================
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingKey = 'onboarding_completed';

  // ==================== ERROR MESSAGES ====================
  static const String networkError = 'Tidak ada koneksi internet';
  static const String unknownError = 'Terjadi kesalahan yang tidak diketahui';
  static const String serverError = 'Terjadi kesalahan pada server';
  static const String timeoutError = 'Koneksi timeout';

  // ==================== SPACING ====================
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // ==================== PADDING ====================
  static const EdgeInsets paddingSmall = EdgeInsets.all(8.0);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16.0);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24.0);

  // Padding values as double for direct use
  static const double paddingSmallValue = 8.0;
  static const double paddingMediumValue = 16.0;
  static const double paddingLargeValue = 24.0;

  // ==================== COLORS ====================
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF38A169);
  static const Color warningColor = Color(0xFFED8936);

  // ==================== ANIMATIONS ====================
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Validation constants
  static const int minPasswordLength = 6;

  // Short aliases for spacing
  static const double spacingS = spacingSmall;
  static const double spacingM = spacingMedium;
  static const double spacingL = spacingLarge;
  static const double spacingXL = spacingXLarge;

  // ==================== BORDER RADIUS ====================
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;
  static const double borderRadiusCircular = 50.0;

  // Short aliases for border radius
  static const double borderRadiusS = borderRadiusSmall;
  static const double borderRadiusM = borderRadiusMedium;
  static const double borderRadiusL = borderRadiusLarge;
  static const double borderRadiusXL = borderRadiusXLarge;

  // Additional aliases for consistency
  static const double radiusLarge = borderRadiusLarge;
  static const double radiusSmall = borderRadiusSmall;
  static const double radiusMedium = borderRadiusMedium;

  // ==================== ELEVATION ====================
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  static const double elevationXLarge = 16.0;

  // ==================== ICON SIZES ====================
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // ==================== FONT SIZES ====================
  static const double fontSizeCaption = 12.0;
  static const double fontSizeBody = 14.0;
  static const double fontSizeSubtitle = 16.0;
  static const double fontSizeTitle = 18.0;
  static const double fontSizeHeadline = 20.0;
  static const double fontSizeDisplay = 24.0;

  // ==================== BUTTON SIZES ====================
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  // ==================== CARD SIZES ====================
  static const double cardElevation = 4.0;
  static const double cardBorderRadius = 12.0;

  // ==================== ANIMATION DURATIONS ====================
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // ==================== TIMEOUTS ====================
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 1);
  static const Duration splashDuration = Duration(seconds: 3);

  // ==================== LIMITS ====================
  static const int maxSearchHistory = 20;
  static const int maxImageSizeMB = 5;
  static const int maxPdfSizeMB = 10;
  static const int maxCacheSizeMB = 100;
  static const int itemsPerPage = 10;
  static const int maxQuizQuestions = 20;
  static const int quizTimePerQuestion = 30; // seconds

  // ==================== ASSET PATHS ====================
  static const String logoPath = 'assets/images/logo.png';
  static const String splashLogoPath = 'assets/images/splash_logo.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';
  static const String noDataImagePath = 'assets/images/no_data.png';
  static const String errorImagePath = 'assets/images/error.png';

  // Lottie animations
  static const String loadingAnimationPath = 'assets/animations/loading.json';
  static const String successAnimationPath = 'assets/animations/success.json';
  static const String errorAnimationPath = 'assets/animations/error.json';
  static const String emptyAnimationPath = 'assets/animations/empty.json';

  // ==================== QUIZ CONSTANTS ====================
  static const List<String> quizLevels = ['mudah', 'sedang', 'sulit'];
  static const Map<String, String> quizLevelNames = {
    'mudah': 'Mudah',
    'sedang': 'Sedang',
    'sulit': 'Sulit',
  };

  static const Map<String, int> quizLevelColors = {
    'mudah': 0xFF4CAF50, // Green
    'sedang': 0xFFFF9800, // Orange
    'sulit': 0xFFF44336, // Red
  };

  // ==================== TOOL CATEGORIES ====================
  static const List<String> toolCategories = [
    'Alat Ukur',
    'Alat Potong',
    'Alat Bengkel',
    'Alat Listrik',
    'Alat Mesin',
    'Alat Keselamatan',
    'Alat Pneumatik',
    'Alat Hidrolik',
  ];

  // ==================== SORT OPTIONS ====================
  static const List<String> sortOptions = [
    'name',
    'rating',
    'views',
    'created_at',
    'updated_at',
  ];

  static const Map<String, String> sortOptionNames = {
    'name': 'Nama',
    'rating': 'Rating',
    'views': 'Dilihat',
    'created_at': 'Terbaru',
    'updated_at': 'Diperbarui',
  };

  static const List<String> sortOrders = ['asc', 'desc'];

  static const Map<String, String> sortOrderNames = {
    'asc': 'A-Z',
    'desc': 'Z-A',
  };

  // ==================== USER ROLES ====================
  static const String roleStudent = 'student';
  static const String roleTeacher = 'teacher';
  static const String roleAdmin = 'admin';

  static const List<String> userRoles = [roleStudent, roleTeacher, roleAdmin];

  static const Map<String, String> roleNames = {
    roleStudent: 'Siswa',
    roleTeacher: 'Guru',
    roleAdmin: 'Admin',
  };

  // ==================== NOTIFICATION TYPES ====================
  static const String notificationTypeQuiz = 'quiz';
  static const String notificationTypeTool = 'tool';
  static const String notificationTypeVideo = 'video';
  static const String notificationTypeSystem = 'system';

  // ==================== THEME MODES ====================
  static const String themeModeLight = 'light';
  static const String themeModeDark = 'dark';
  static const String themeModeSystem = 'system';

  static const List<String> themeModes = [
    themeModeLight,
    themeModeDark,
    themeModeSystem,
  ];

  static const Map<String, String> themeModeNames = {
    themeModeLight: 'Terang',
    themeModeDark: 'Gelap',
    themeModeSystem: 'Sistem',
  };

  // ==================== LANGUAGES ====================
  static const String languageIndonesian = 'id';
  static const String languageEnglish = 'en';

  static const List<String> supportedLanguages = [
    languageIndonesian,
    languageEnglish,
  ];

  static const Map<String, String> languageNames = {
    languageIndonesian: 'Bahasa Indonesia',
    languageEnglish: 'English',
  };

  // ==================== ADDITIONAL ERROR MESSAGES ====================
  static const String errorNotFound = 'Data tidak ditemukan';
  static const String errorUnauthorized =
      'Sesi telah berakhir, silakan login kembali';
  static const String errorForbidden = 'Anda tidak memiliki akses';
  static const String errorValidation = 'Data yang dimasukkan tidak valid';

  // ==================== SUCCESS MESSAGES ====================
  static const String successLogin = 'Login berhasil';
  static const String successRegister = 'Registrasi berhasil';
  static const String successLogout = 'Logout berhasil';
  static const String successSave = 'Data berhasil disimpan';
  static const String successUpdate = 'Data berhasil diperbarui';
  static const String successDelete = 'Data berhasil dihapus';
  static const String successUpload = 'File berhasil diupload';

  // ==================== VALIDATION MESSAGES ====================
  static const String validationRequired = 'Field ini wajib diisi';
  static const String validationEmail = 'Format email tidak valid';
  static const String validationPassword = 'Password minimal 8 karakter';
  static const String validationPasswordConfirm =
      'Konfirmasi password tidak sama';
  static const String validationMinLength = 'Minimal {min} karakter';
  static const String validationMaxLength = 'Maksimal {max} karakter';
  static const String validationNumeric = 'Hanya boleh angka';
  static const String validationAlpha = 'Hanya boleh huruf';
  static const String validationAlphaNumeric = 'Hanya boleh huruf dan angka';

  // ==================== REGEX PATTERNS ====================
  static const String regexEmail =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String regexPassword =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  static const String regexPhone = r'^[0-9]{10,15}$';
  static const String regexYouTubeUrl =
      r'^https?:\/\/(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11}).*$';

  // ==================== VALIDATION PATTERNS ====================
  static const String phoneRegex = r'^[+]?[0-9]{10,15}$';
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String passwordRegex =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';

  // ==================== FILE EXTENSIONS ====================
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];
  static const List<String> videoExtensions = [
    'mp4',
    'avi',
    'mov',
    'wmv',
    'flv',
  ];
  static const List<String> documentExtensions = ['pdf', 'doc', 'docx', 'txt'];

  // ==================== MIME TYPES ====================
  static const List<String> imageMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
  ];

  static const List<String> pdfMimeTypes = ['application/pdf'];

  // ==================== CACHE KEYS ====================
  static const String cacheKeyTools = 'tools';
  static const String cacheKeyCategories = 'categories';
  static const String cacheKeyVideos = 'videos';
  static const String cacheKeyQuizzes = 'quizzes';
  static const String cacheKeyUserStats = 'user_stats';
  static const String cacheKeyDashboardStats = 'dashboard_stats';
  static const String cacheKeyLeaderboard = 'leaderboard';
  static const String cacheKeyUserProfile = 'user_profile';
  static const String cacheKeySettings = 'app_settings';
  static const String cacheKeyTheme = 'theme_mode';
  static const String cacheKeyLanguage = 'app_language';
  static const String cacheKeyOnboarding = 'onboarding_completed';
  static const String cacheKeyVideoCategories = 'video_categories';

  // ==================== SHARED PREFERENCES KEYS ====================
  static const String prefKeyFirstLaunch = 'first_launch';
  static const String prefKeyLastSync = 'last_sync';
  static const String prefKeyNotificationSettings = 'notification_settings';
  static const String prefKeyAppSettings = 'app_settings';

  // ==================== BOTTOM NAVIGATION ====================
  static const int bottomNavDashboard = 0;
  static const int bottomNavTools = 1;
  static const int bottomNavQuiz = 2;
  static const int bottomNavVideo = 3;
  static const int bottomNavProfile = 4;

  // ==================== GRID SETTINGS ====================
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.8;
  static const double gridSpacing = 16.0;

  // ==================== LIST SETTINGS ====================
  static const double listItemHeight = 80.0;
  static const double listItemSpacing = 8.0;

  // ==================== SEARCH SETTINGS ====================
  static const int searchDebounceMs = 500;
  static const int minSearchLength = 2;

  // ==================== RATING SETTINGS ====================
  static const double maxRating = 5.0;
  static const double minRating = 1.0;
  static const double ratingStep = 0.5;

  // ==================== QUIZ SETTINGS ====================
  static const int minQuizQuestions = 5;
  static const int maxQuizTime = 1800; // 30 minutes
  static const int minQuizTime = 300; // 5 minutes

  // ==================== SCORE SETTINGS ====================
  static const int maxScore = 100;
  static const int passingScore = 70;

  // ==================== PAGINATION ====================
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // ==================== MAIN MENU ITEMS ====================
  static const List<Map<String, dynamic>> mainMenuItems = [
    {
      'title': 'Ensiklopedia Alat',
      'subtitle': 'Jelajahi berbagai alat SMK',
      'icon': Icons.build,
      'color': Colors.blue,
      'route': '/encyclopedia',
    },
    {
      'title': 'Video Pembelajaran',
      'subtitle': 'Tonton video edukatif',
      'icon': Icons.play_circle,
      'color': Colors.red,
      'route': '/videos',
    },
    {
      'title': 'Kuis Interaktif',
      'subtitle': 'Uji pengetahuan Anda',
      'icon': Icons.quiz,
      'color': Colors.green,
      'route': '/quiz',
    },
    {
      'title': 'Tentang Aplikasi',
      'subtitle': 'Informasi aplikasi',
      'icon': Icons.info,
      'color': Colors.orange,
      'route': '/about',
    },
  ];

  // ==================== URL PATTERNS ====================
  static const String urlPatternHttp =
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)';

  // ==================== DATE FORMATS ====================
  static const String dateFormatDisplay = 'dd MMMM yyyy';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String dateTimeFormatDisplay = 'dd MMMM yyyy HH:mm';
  static const String dateTimeFormatApi = 'yyyy-MM-dd HH:mm:ss';
  static const String timeFormatDisplay = 'HH:mm';

  // ==================== FEATURE FLAGS ====================
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  static const bool enableBiometricAuth = false;
  static const bool enableDarkMode = true;
  static const bool enableMultiLanguage = true;

  // ==================== DEVELOPMENT FLAGS ====================
  static const bool isDebugMode = true;
  static const bool showDebugInfo = false;
  static const bool enableLogging = true;
  static const bool mockApiResponses = false;

  static Color infoColor = Colors.blue;

  static int bottomNavHome = bottomNavDashboard;

  static var borderRadius;
}
