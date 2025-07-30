class ApiConfig {
  // Base URL for the API
  static const String baseUrl = 'https://815c13b82613.ngrok-free.app/api';

  // Alternative base URL for development (using ngrok or similar)
  static const String devBaseUrl = 'https://815c13b82613.ngrok-free.app/api';

  // Current environment
  static const bool isDevelopment = true;

  // Get the current base URL based on environment
  static String get currentBaseUrl => isDevelopment ? devBaseUrl : baseUrl;

  // Headers default untuk API requests
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
    'User-Agent': 'Flutter-App/1.0',
  };

  // Additional headers for ngrok compatibility
  static const Map<String, String> ngrokHeaders = {
    'ngrok-skip-browser-warning': 'true',
    'User-Agent': 'Flutter-App/1.0',
    'Accept': 'application/json, image/*, application/pdf',
    'Cache-Control': 'no-cache',
  };

  // Timeout untuk HTTP requests (dalam detik)
  static const int timeoutDuration = 30;

  // Authentication endpoints
  static const String auth = '/auth';
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String forgotPassword = '/forgot-password';

  // Categories endpoints
  static const String categories = '/categories';

  // Tools endpoints
  static const String tools = '/tools';
  static const String toolsSearch = '/tools/search';
  static const String toolsFavorites = '/tools/favorites';

  // Videos endpoints
  static const String videos = '/videos';
  static const String videosSearch = '/videos/search';

  // Quizzes endpoints
  static const String quizzes = '/quizzes';
  static const String quizStart = '/quiz/start';
  static const String quizSubmit = '/quiz/submit';
  static const String quizResults = '/quiz/results';

  // Scores endpoints
  static const String scores = '/scores';
  static const String userScores = '/user/scores';
  static const String leaderboard = '/leaderboard';

  // User endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';

  // System endpoints
  static const String csrfCookieEndpoint = '/sanctum/csrf-cookie';

  // Method untuk mendapatkan full URL endpoint
  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }

  // Method untuk mendapatkan tool detail URL
  static String getToolDetailUrl(String toolId) {
    return '$baseUrl/tools/$toolId';
  }

  // Method untuk mendapatkan video detail URL
  static String getVideoDetailUrl(String videoId) {
    return '$baseUrl/videos/$videoId';
  }

  // Method untuk mendapatkan quiz by level URL
  static String getQuizByLevelUrl(String level) {
    return '$baseUrl/quizzes/$level';
  }

  // Method untuk mendapatkan category detail URL
  static String getCategoryDetailUrl(String categoryId) {
    return '$baseUrl/categories/$categoryId';
  }

  // Method untuk mendapatkan score detail URL
  static String getScoreDetailUrl(String scoreId) {
    return '$baseUrl/scores/$scoreId';
  }
}
