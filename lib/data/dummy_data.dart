import '../models/tool_model.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../models/video_model.dart';

class DummyData {
  // Data User Dummy
  static UserModel get dummyUser => UserModel(
    id: '1',
    name: 'Andi',
    className: 'XI TKJ',
    profileImageUrl: 'https://via.placeholder.com/150',
    completedQuizzes: 3,
    totalQuizzes: 10,
  );

  // Data Alat Teknik Dummy
  static List<ToolModel> get dummyTools => [
    ToolModel(
      id: '1',
      name: 'Tang Kombinasi',
      description: 'Alat untuk mencengkeram, memotong, dan memutar benda kerja',
      function: 'Digunakan untuk mencengkeram kabel, memotong kawat, dan memutar mur/baut kecil',
      imageUrl: 'https://via.placeholder.com/300x200?text=Tang+Kombinasi',
      videoUrl: 'dQw4w9WgXcQ',
      category: 'Hand Tools',
    ),
    ToolModel(
      id: '2',
      name: 'Obeng Plus',
      description: 'Alat untuk mengencangkan atau melonggarkan sekrup dengan kepala plus',
      function: 'Memasang dan melepas sekrup dengan kepala berbentuk plus (+)',
      imageUrl: 'https://via.placeholder.com/300x200?text=Obeng+Plus',
      videoUrl: 'dQw4w9WgXcQ',
      category: 'Hand Tools',
    ),
    ToolModel(
      id: '3',
      name: 'Multimeter',
      description: 'Alat ukur listrik untuk mengukur tegangan, arus, dan resistansi',
      function: 'Mengukur tegangan AC/DC, arus listrik, resistansi, dan kontinuitas rangkaian',
      imageUrl: 'https://via.placeholder.com/300x200?text=Multimeter',
      videoUrl: 'dQw4w9WgXcQ',
      category: 'Measuring Tools',
    ),
    ToolModel(
      id: '4',
      name: 'Solder',
      description: 'Alat untuk menyambung komponen elektronik dengan timah',
      function: 'Menyolder komponen elektronik pada PCB atau kabel',
      imageUrl: 'https://via.placeholder.com/300x200?text=Solder',
      videoUrl: 'dQw4w9WgXcQ',
      category: 'Electronic Tools',
    ),
    ToolModel(
      id: '5',
      name: 'Crimping Tool',
      description: 'Alat untuk memasang konektor pada kabel jaringan',
      function: 'Memasang konektor RJ45 pada kabel UTP untuk jaringan komputer',
      imageUrl: 'https://via.placeholder.com/300x200?text=Crimping+Tool',
      videoUrl: 'dQw4w9WgXcQ',
      category: 'Network Tools',
    ),
  ];

  // Data Video Pembelajaran Dummy
  static List<VideoModel> get dummyVideos => [
    VideoModel(
      id: '1',
      title: 'Cara Menggunakan Tang Kombinasi',
      description: 'Tutorial lengkap penggunaan tang kombinasi untuk berbagai keperluan teknik',
      youtubeId: 'dQw4w9WgXcQ',
      thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
      duration: '5:30',
      category: 'Hand Tools',
    ),
    VideoModel(
      id: '2',
      title: 'Penggunaan Multimeter Digital',
      description: 'Panduan menggunakan multimeter untuk mengukur tegangan, arus, dan resistansi',
      youtubeId: 'dQw4w9WgXcQ',
      thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
      duration: '8:15',
      category: 'Measuring Tools',
    ),
    VideoModel(
      id: '3',
      title: 'Teknik Menyolder yang Benar',
      description: 'Tutorial menyolder komponen elektronik dengan teknik yang benar dan aman',
      youtubeId: 'dQw4w9WgXcQ',
      thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
      duration: '12:45',
      category: 'Electronic Tools',
    ),
    VideoModel(
      id: '4',
      title: 'Crimping Kabel UTP RJ45',
      description: 'Cara memasang konektor RJ45 pada kabel UTP untuk jaringan komputer',
      youtubeId: 'dQw4w9WgXcQ',
      thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
      duration: '6:20',
      category: 'Network Tools',
    ),
    VideoModel(
      id: '5',
      title: 'Keselamatan Kerja di Workshop',
      description: 'Panduan keselamatan kerja saat menggunakan alat-alat teknik di workshop',
      youtubeId: 'dQw4w9WgXcQ',
      thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
      duration: '10:30',
      category: 'Safety',
    ),
  ];

  // Data Soal Kuis Dummy
  static List<QuizQuestion> get dummyQuizQuestions => [
    // Soal Level Mudah
    QuizQuestion(
      id: '1',
      question: 'Apa fungsi utama dari tang kombinasi?',
      options: [
        'Memotong kayu',
        'Mencengkeram dan memotong kawat',
        'Mengukur tegangan',
        'Menyolder komponen'
      ],
      correctAnswerIndex: 1,
      level: QuizLevel.easy,
      explanation: 'Tang kombinasi digunakan untuk mencengkeram, memotong kawat, dan memutar benda kerja kecil.',
    ),
    QuizQuestion(
      id: '2',
      question: 'Alat apa yang digunakan untuk mengukur tegangan listrik?',
      options: [
        'Tang ampere',
        'Multimeter',
        'Obeng tester',
        'Crimping tool'
      ],
      correctAnswerIndex: 1,
      level: QuizLevel.easy,
      explanation: 'Multimeter adalah alat ukur listrik yang dapat mengukur tegangan, arus, dan resistansi.',
    ),
    QuizQuestion(
      id: '3',
      question: 'Konektor apa yang biasa digunakan untuk kabel jaringan UTP?',
      options: [
        'RJ11',
        'RJ45',
        'USB',
        'HDMI'
      ],
      correctAnswerIndex: 1,
      level: QuizLevel.easy,
      explanation: 'RJ45 adalah konektor standar yang digunakan untuk kabel jaringan UTP.',
    ),
    
    // Soal Level Sedang
    QuizQuestion(
      id: '4',
      question: 'Berapa suhu ideal untuk menyolder komponen elektronik?',
      options: [
        '200-250°C',
        '300-350°C',
        '400-450°C',
        '500-550°C'
      ],
      correctAnswerIndex: 1,
      level: QuizLevel.medium,
      explanation: 'Suhu ideal untuk menyolder komponen elektronik adalah 300-350°C untuk menghindari kerusakan komponen.',
    ),
    QuizQuestion(
      id: '5',
      question: 'Apa kepanjangan dari UTP dalam kabel jaringan?',
      options: [
        'Unshielded Twisted Pair',
        'Universal Transmission Protocol',
        'Unified Terminal Point',
        'Ultra Thin Plastic'
      ],
      correctAnswerIndex: 0,
      level: QuizLevel.medium,
      explanation: 'UTP adalah singkatan dari Unshielded Twisted Pair, jenis kabel jaringan yang tidak memiliki pelindung.',
    ),
    
    // Soal Level Sulit
    QuizQuestion(
      id: '6',
      question: 'Pada multimeter, apa yang terjadi jika kita mengukur tegangan AC dengan setting DC?',
      options: [
        'Hasil pengukuran akan akurat',
        'Multimeter akan rusak',
        'Hasil pengukuran tidak akurat atau nol',
        'Tidak ada pengaruh'
      ],
      correctAnswerIndex: 2,
      level: QuizLevel.hard,
      explanation: 'Mengukur tegangan AC dengan setting DC akan memberikan hasil yang tidak akurat karena perbedaan karakteristik sinyal.',
    ),
    QuizQuestion(
      id: '7',
      question: 'Urutan warna kabel UTP standar T568B untuk pin 1-4 adalah?',
      options: [
        'Putih Orange, Orange, Putih Hijau, Biru',
        'Putih Hijau, Hijau, Putih Orange, Biru',
        'Orange, Putih Orange, Hijau, Putih Hijau',
        'Biru, Putih Biru, Orange, Putih Orange'
      ],
      correctAnswerIndex: 0,
      level: QuizLevel.hard,
      explanation: 'Standar T568B: Pin 1=Putih Orange, Pin 2=Orange, Pin 3=Putih Hijau, Pin 4=Biru.',
    ),
  ];
}