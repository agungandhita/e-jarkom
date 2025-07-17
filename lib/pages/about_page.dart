import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(maxLines: 1, title: 'Tentang Aplikasi'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                gradient: AppConstants.primaryGradient,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Column(
                children: [
                  // App icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.build,
                      size: 40,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // App name and version
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Versi ${AppConstants.appVersion}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),

            // Description section
            _buildSection(
              'Deskripsi Aplikasi',
              Icons.description,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'E-Jarkom adalah aplikasi ensiklopedia alat teknik interaktif yang dirancang khusus untuk siswa SMK. Aplikasi ini menyediakan informasi lengkap tentang berbagai alat teknik yang digunakan dalam dunia industri dan pendidikan kejuruan.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'Dengan antarmuka yang user-friendly dan konten yang mudah dipahami, aplikasi ini membantu siswa untuk:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  ..._buildBulletPoints([
                    'Mempelajari berbagai jenis alat teknik',
                    'Memahami fungsi dan cara penggunaan alat',
                    'Menonton video tutorial pembelajaran',
                    'Mengikuti kuis untuk menguji pemahaman',
                    'Menambahkan alat baru ke dalam database',
                  ]),
                ],
              ),
            ),

            // Features section
            _buildSection(
              'Fitur Utama',
              Icons.star,
              Column(
                children: [
                  _buildFeatureItem(
                    Icons.book,
                    'Ensiklopedia Alat',
                    'Database lengkap alat teknik dengan gambar dan deskripsi detail',
                  ),
                  _buildFeatureItem(
                    Icons.video_library,
                    'Video Pembelajaran',
                    'Koleksi video tutorial untuk memahami penggunaan alat',
                  ),
                  _buildFeatureItem(
                    Icons.quiz,
                    'Kuis Interaktif',
                    'Sistem kuis dengan berbagai tingkat kesulitan',
                  ),
                  _buildFeatureItem(
                    Icons.search,
                    'Pencarian Cerdas',
                    'Fitur pencarian untuk menemukan alat dengan mudah',
                  ),
                  _buildFeatureItem(
                    Icons.add_circle,
                    'Tambah Alat',
                    'Kemampuan untuk menambahkan alat baru ke database',
                  ),
                ],
              ),
            ),

            // Target users section
            _buildSection(
              'Target Pengguna',
              Icons.people,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aplikasi ini dirancang khusus untuk:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  ..._buildBulletPoints([
                    'Siswa SMK jurusan teknik',
                    'Guru dan instruktur teknik',
                    'Mahasiswa teknik',
                    'Praktisi industri',
                    'Siapa saja yang ingin belajar tentang alat teknik',
                  ]),
                ],
              ),
            ),

            // Developer section
            _buildSection(
              'Pengembang',
              Icons.code,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppConstants.primaryColor.withOpacity(
                          0.1,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tim Pengembang SMK',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Dikembangkan dengan ❤️ untuk pendidikan',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMedium,
                      ),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.email, size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Kontak:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ejarkom.smk@gmail.com',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        const Row(
                          children: [
                            Icon(Icons.school, size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Institusi:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SMK Negeri 1 Teknologi',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Technology section
            _buildSection(
              'Teknologi',
              Icons.settings,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aplikasi ini dibangun menggunakan:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  ..._buildTechItems([
                    {'name': 'Flutter', 'desc': 'Framework UI cross-platform'},
                    {'name': 'Dart', 'desc': 'Bahasa pemrograman'},
                    {'name': 'Material Design 3', 'desc': 'Sistem desain UI'},
                    {'name': 'Provider', 'desc': 'State management'},
                  ]),
                ],
              ),
            ),

            // Copyright
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              margin: const EdgeInsets.only(top: AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Column(
                children: [
                  Text(
                    '© 2024 E-Jarkom SMK',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Semua hak cipta dilindungi',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.radiusMedium),
                topRight: Radius.circular(AppConstants.radiusMedium),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppConstants.primaryColor, size: 24),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: content,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBulletPoints(List<String> points) {
    return points
        .map(
          (point) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 20),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTechItems(List<Map<String, String>> techs) {
    return techs
        .map(
          (tech) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2, right: 8),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: '${tech['name']}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        TextSpan(text: tech['desc']),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
