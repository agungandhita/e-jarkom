import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_provider.dart';
import '../models/tool_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/custom_app_bar.dart';

class AddToolPage extends StatefulWidget {
  const AddToolPage({super.key});

  @override
  State<AddToolPage> createState() => _AddToolPageState();
}

class _AddToolPageState extends State<AddToolPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _functionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _pdfUrlController = TextEditingController();

  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _functionController.dispose();
    _videoUrlController.dispose();
    _pdfUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(maxLines: 1, title: 'Tambah Alat Baru'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gambar Alat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    GestureDetector(
                      onTap: () {
                        AppHelpers.showImagePickerOptions(context, (image) {
                          setState(() {
                            _selectedImage = image;
                          });
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium,
                          ),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMedium,
                                ),
                                child: Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildImagePlaceholder();
                                  },
                                ),
                              )
                            : _buildImagePlaceholder(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Form fields
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tool name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nama Alat',
                      hint: 'Masukkan nama alat',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama alat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.paddingLarge),

                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Deskripsi',
                      hint: 'Masukkan deskripsi alat',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.paddingLarge),

                    // Function
                    _buildTextField(
                      controller: _functionController,
                      label: 'Fungsi',
                      hint: 'Masukkan fungsi alat',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Fungsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.paddingLarge),

                    // Video URL
                    _buildTextField(
                      controller: _videoUrlController,
                      label: 'URL Video (Opsional)',
                      hint: 'Masukkan URL video YouTube',
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final videoId = AppHelpers.getYouTubeVideoId(value);
                          if (videoId == null) {
                            return 'URL YouTube tidak valid';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    // PDF URL
                    _buildTextField(
                      controller: _pdfUrlController,
                      label: 'URL File PDF (Opsional)',
                      hint: 'Masukkan URL file PDF',
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!value.toLowerCase().endsWith('.pdf') &&
                              !value.contains('pdf')) {
                            return 'URL harus mengarah ke file PDF';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.paddingLarge,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMedium,
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Tambah Alat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
        SizedBox(height: AppConstants.paddingSmall),
        Text(
          'Tap untuk menambah gambar',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate required fields
      if (_nameController.text.trim().isEmpty) {
        throw Exception('Nama alat tidak boleh kosong');
      }
      if (_descriptionController.text.trim().isEmpty) {
        throw Exception('Deskripsi tidak boleh kosong');
      }
      if (_functionController.text.trim().isEmpty) {
        throw Exception('Fungsi tidak boleh kosong');
      }

      // Process video URL - store full URL, not just video ID
      String processedVideoUrl = '';
      if (_videoUrlController.text.isNotEmpty) {
        final videoId = AppHelpers.getYouTubeVideoId(_videoUrlController.text);
        if (videoId != null) {
          // Store the original URL or create a standard YouTube URL
          processedVideoUrl = _videoUrlController.text.trim();
        } else {
          throw Exception('URL YouTube tidak valid');
        }
      }

      // Prepare image file for upload
      File? imageFile;
      if (_selectedImage != null) {
        imageFile = File(_selectedImage!.path);
      }

      // Create new tool with proper field mapping for database
      final newTool = ToolModel(
        id: AppHelpers.generateId(),
        name: _nameController.text.trim(), // Maps to 'nama' in database
        description: _descriptionController.text
            .trim(), // Maps to 'deskripsi' in database
        function: _functionController.text
            .trim(), // Maps to 'fungsi' in database
        imageUrl: '', // Will be set by server after upload
        videoUrl: processedVideoUrl, // Maps to 'url_video' in database
        pdfUrl: _pdfUrlController.text.trim(), // Maps to 'file_pdf' in database
      );

      // Add tool via provider (which uses API) with image file
      final success = await context.read<AppProvider>().addTool(
        newTool,
        imageFile: imageFile,
      );

      if (success) {
        // Show success message
        AppHelpers.showSnackBar(context, 'Alat berhasil ditambahkan!');

        // Navigate back
        Navigator.of(context).pop();
      } else {
        throw Exception('Gagal menyimpan data ke server');
      }
    } catch (e) {
      AppHelpers.showSnackBar(
        context,
        'Gagal menambahkan alat: $e',
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
