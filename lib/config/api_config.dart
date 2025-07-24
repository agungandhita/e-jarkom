class ApiConfig {
  // Base URL untuk komunikasi dengan backend Laravel
  static const String baseUrl = 'https://c199ade72ebd.ngrok-free.app/api';

  // Headers default untuk API requests
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // Timeout untuk HTTP requests (dalam detik)
  static const int timeoutDuration = 30;

  // Authentication endpoints
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';
  static const String forgotPasswordEndpoint = '/forgot-password';
  static const String resetPasswordEndpoint = '/reset-password';

  // User Profile endpoints
  static const String profileEndpoint = '/profile';

  // Dashboard endpoints
  static const String dashboardStatsEndpoint = '/dashboard/stats';

  // Categories endpoints
  static const String categoriesEndpoint = '/categories';

  // Tools endpoints
  static const String toolsEndpoint = '/tools';
  static const String toolsFeaturedEndpoint = '/tools/featured/list';
  static const String toolsPopularEndpoint = '/tools/popular/list';

  // Videos endpoints
  static const String videosEndpoint = '/videos';

  // Quizzes endpoints
  static const String quizzesEndpoint = '/quizzes';
  static const String quizzesSubmitEndpoint = '/quizzes/submit';
  static const String quizzesHistoryEndpoint = '/quizzes/history/user';
  static const String quizzesStatsEndpoint = '/quizzes/stats/user';

  // Scores endpoints
  static const String scoresEndpoint = '/scores';

  // Favorites endpoints
  static const String favoritesEndpoint = '/favorites';

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

  // Method untuk toggle favorite tool
  static String getToggleFavoriteUrl(String toolId) {
    return '$baseUrl/tools/$toolId/favorite';
  }
}
