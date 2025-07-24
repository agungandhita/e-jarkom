class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }
  
  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    
    return null;
  }
  
  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    
    if (value != password) {
      return 'Password tidak sama';
    }
    
    return null;
  }
  
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    
    if (value.length < 2) {
      return 'Nama minimal 2 karakter';
    }
    
    if (value.length > 50) {
      return 'Nama maksimal 50 karakter';
    }
    
    return null;
  }
  
  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    final phoneRegex = RegExp(r'^[\+]?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'Format nomor telepon tidak valid';
    }
    
    return null;
  }
  
  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }
  
  // Tool name validation
  static String? validateToolName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama alat tidak boleh kosong';
    }
    
    if (value.length < 3) {
      return 'Nama alat minimal 3 karakter';
    }
    
    if (value.length > 100) {
      return 'Nama alat maksimal 100 karakter';
    }
    
    return null;
  }
  
  // Description validation
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Deskripsi tidak boleh kosong';
    }
    
    if (value.length < 10) {
      return 'Deskripsi minimal 10 karakter';
    }
    
    if (value.length > 1000) {
      return 'Deskripsi maksimal 1000 karakter';
    }
    
    return null;
  }
  
  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Format URL tidak valid';
    }
    
    return null;
  }
  
  // YouTube URL validation
  static String? validateYouTubeUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // YouTube URL is optional
    }
    
    final youtubeRegex = RegExp(
      r'^https?:\/\/(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})'
    );
    
    if (!youtubeRegex.hasMatch(value)) {
      return 'Format URL YouTube tidak valid';
    }
    
    return null;
  }
  
  // Quiz level validation
  static String? validateQuizLevel(String? value) {
    if (value == null || value.isEmpty) {
      return 'Level tidak boleh kosong';
    }
    
    final validLevels = ['mudah', 'sedang', 'sulit'];
    if (!validLevels.contains(value.toLowerCase())) {
      return 'Level harus mudah, sedang, atau sulit';
    }
    
    return null;
  }
  
  // Quiz answer validation
  static String? validateQuizAnswer(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jawaban tidak boleh kosong';
    }
    
    final validAnswers = ['A', 'B', 'C', 'D'];
    if (!validAnswers.contains(value.toUpperCase())) {
      return 'Jawaban harus A, B, C, atau D';
    }
    
    return null;
  }
}