# Panduan Integrasi API E-Jarkom

## 📋 Overview
Dokumen ini menjelaskan integrasi lengkap endpoint API Laravel backend E-Jarkom ke dalam aplikasi Flutter.

## 🔧 Struktur Integrasi

### 1. ApiService (lib/services/api_service.dart)
Kelas utama yang menangani semua komunikasi dengan backend Laravel:

#### Fitur Utama:
- **Token Management**: Otomatis mengelola token autentikasi
- **Response Handling**: Menggunakan `ApiResponse<T>` untuk konsistensi
- **Error Handling**: Penanganan error yang komprehensif
- **Backward Compatibility**: Method legacy untuk kompatibilitas dengan kode existing

#### Endpoint yang Diintegrasikan:

##### 🔐 Authentication (4 endpoint)
- `register()` - Registrasi user baru
- `login()` - Login user (auto set token)
- `logout()` - Logout user (auto clear token)
- `forgotPassword()` - Lupa password
- `resetPassword()` - Reset password
- `getProfile()` - Ambil profil user
- `updateProfile()` - Update profil user
- `changePassword()` - Ganti password

##### 🛠 Tools Management (5 endpoint)
- `getTools()` - List tools dengan pagination & search
- `getToolById()` - Detail tool berdasarkan ID
- `createTool()` - Tambah tool baru
- `updateTool()` - Update tool
- `deleteTool()` - Hapus tool

##### 🎥 Videos Management (2 endpoint)
- `getVideos()` - List videos dengan pagination & search
- `getVideoById()` - Detail video berdasarkan ID

##### 📝 Quiz Management (2 endpoint)
- `getQuizQuestions()` - Ambil soal quiz berdasarkan level
- `submitQuizAnswers()` - Submit jawaban quiz

##### 📊 Score Management (3 endpoint)
- `getScores()` - History skor user
- `getScoreById()` - Detail skor berdasarkan ID
- `saveScore()` - Simpan skor manual

##### 📈 Dashboard & Statistics (3 endpoint)
- `getDashboardStats()` - Statistik dashboard user
- `getLeaderboard()` - Leaderboard users
- `getAppStats()` - Statistik aplikasi

### 2. DataService (lib/services/data_service.dart)
Tetap kompatibel dengan kode existing melalui method legacy di ApiService.

## 🚀 Cara Penggunaan

### Setup Token Autentikasi
```dart
// Login dan auto-set token
final loginResult = await ApiService.login(
  email: 'user@example.com',
  password: 'password123'
);

if (loginResult.success) {
  // Token sudah otomatis di-set
  print('Login berhasil: ${loginResult.data?.name}');
}
```

### Menggunakan API dengan Pagination
```dart
// Get tools dengan pagination
final toolsResult = await ApiService.getTools(
  page: 1,
  perPage: 10,
  search: 'router'
);

if (toolsResult.success) {
  final tools = toolsResult.data ?? [];
  final meta = toolsResult.meta;
  print('Total tools: ${meta?['total']}');
}
```

### Menggunakan API Quiz
```dart
// Get quiz questions
final quizResult = await ApiService.getQuizQuestions(level: 'mudah');

if (quizResult.success) {
  final questions = quizResult.data ?? [];
  // Tampilkan questions
}

// Submit answers
final submitResult = await ApiService.submitQuizAnswers(
  answers: [
    {'question_id': '1', 'answer': 'A'},
    {'question_id': '2', 'answer': 'B'},
  ],
  level: 'mudah'
);
```

### Error Handling
```dart
try {
  final result = await ApiService.getTools();
  if (result.success) {
    // Handle success
    final tools = result.data ?? [];
  } else {
    // Handle API error
    print('Error: ${result.message}');
  }
} catch (e) {
  // Handle network/other errors
  print('Network error: $e');
}
```

## 🔄 Backward Compatibility

Untuk menjaga kompatibilitas dengan kode existing, tersedia method legacy:

- `getToolsLegacy()` - Mengembalikan `List<ToolModel>`
- `getVideosLegacy()` - Mengembalikan `List<VideoModel>`
- `getQuizQuestionsLegacy()` - Menerima `QuizLevel` enum
- `submitQuizAnswersLegacy()` - Menerima `QuizLevel` enum
- `getUserById()` - Kompatibilitas dengan DataService
- `updateUserProgress()` - Kompatibilitas dengan DataService

## 📝 Konfigurasi

Pastikan `ApiConfig` sudah dikonfigurasi dengan benar:

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://your-laravel-backend.com';
  static const String apiVersion = '/api';
  // ...
}
```

## ✅ Status Integrasi

- ✅ Authentication Endpoints (8/8)
- ✅ Tools Management (5/5)
- ✅ Videos Management (2/2)
- ✅ Quiz Management (2/2)
- ✅ Score Management (3/3)
- ✅ Dashboard & Statistics (3/3)
- ✅ Backward Compatibility
- ✅ Token Management
- ✅ Error Handling
- ✅ Response Standardization

**Total: 23 endpoint terintegrasi dengan sempurna!**

## 🔧 Maintenance

Untuk menambah endpoint baru:
1. Tambahkan method di `ApiService`
2. Gunakan `ApiResponse<T>` untuk konsistensi
3. Tambahkan `requiresAuth: true` jika perlu autentikasi
4. Update dokumentasi ini

## 📞 Support

Jika ada masalah dengan integrasi API, periksa:
1. Koneksi internet
2. Konfigurasi `ApiConfig`
3. Token autentikasi (untuk endpoint protected)
4. Format request sesuai dokumentasi backend