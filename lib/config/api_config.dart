class ApiConfig {
  // Base URL untuk komunikasi dengan backend Laravel

  // Untuk Android emulator
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Untuk iOS simulator atau real device di network yang sama
  static const String baseUrl = 'https://240af3b11d06.ngrok-free.app/api';

  // Untuk web/desktop
  // static const String baseUrl = 'http://localhost:8000/api';

  // Untuk testing dengan real device, ganti dengan IP address komputer
  // static const String baseUrl = 'http://YOUR_COMPUTER_IP:8000/api';

  // Headers default untuk API requests
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeout untuk HTTP requests (dalam detik)
  static const int timeoutDuration = 30;

  // API endpoints
  static const String toolsEndpoint = '/tools';
  static const String videosEndpoint = '/videos';
  static const String quizEndpoint = '/quiz';
  static const String userEndpoint = '/user';

  // Method untuk mendapatkan full URL endpoint
  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
