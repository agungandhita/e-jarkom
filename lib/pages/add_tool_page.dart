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

  String _selectedCategory = AppConstants.toolCategories.first;
  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _functionController.dispose();
    _videoUrlController.dispose();
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
                                child: Image.network(
                                  _selectedImage!.path,
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

                    // Category dropdown
                    const Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: AppConstants.toolCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
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
      // Get YouTube video ID if URL is provided
      String videoId = '';
      if (_videoUrlController.text.isNotEmpty) {
        videoId = AppHelpers.getYouTubeVideoId(_videoUrlController.text) ?? '';
      }

      // Create new tool
      final newTool = ToolModel(
        id: AppHelpers.generateId(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        function: _functionController.text.trim(),
        imageUrl: _selectedImage?.path ?? '',
        videoUrl: videoId,
        category: _selectedCategory,
      );

      // Add tool to provider
      context.read<AppProvider>().addTool(newTool);

      // Show success message
      AppHelpers.showSnackBar(context, 'Alat berhasil ditambahkan!');

      // Navigate back
      Navigator.of(context).pop();
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
