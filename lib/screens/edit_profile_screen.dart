import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:healtime_app/models/auth_provider.dart';
import 'package:healtime_app/theme/app_theme.dart';
import 'package:healtime_app/utils/api_service.dart';
import 'package:healtime_app/widgets/safe_image_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _specialtyController;
  late TextEditingController _clinicController;
  late TextEditingController _experienceController;
  late TextEditingController _priceController;
  bool _isLoading = false;
  String? _base64Image;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.user?.name ?? '');
    _currentImageUrl = auth.user?.imageUrl;
    _specialtyController = TextEditingController(
      text: auth.user?.specialty ?? '',
    );
    _clinicController = TextEditingController(text: auth.user?.clinic ?? '');
    _experienceController = TextEditingController(
      text: auth.user?.experience?.toString() ?? '',
    );
    _priceController = TextEditingController(text: auth.user?.price ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _clinicController.dispose();
    _experienceController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      setState(() {
        _base64Image = 'data:image/jpeg;base64,$base64String';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    final data = {
      'name': _nameController.text,
      'imageUrl': _base64Image ?? _currentImageUrl,
    };

    if (auth.role == UserRole.doctor) {
      data['specialty'] = _specialtyController.text;
      data['clinic'] = _clinicController.text;
      data['experience'] = _experienceController.text;
      data['price'] = _priceController.text;
    }

    final response = await ApiService.updateUser(auth.userId!, data);

    setState(() => _isLoading = false);

    if (response != null && mounted) {
      // Re-fetch user session or manually update provider memory if needed.
      final updatedUser = auth.user!.copyWith(
        name: data['name'],
        imageUrl: data['imageUrl'],
        specialty: data['specialty'],
        clinic: data['clinic'],
        experience: data['experience'] != null
            ? int.tryParse(data['experience']!)
            : auth.user!.experience,
        price: data['price'],
      );
      auth.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = context.read<AuthProvider>().role == UserRole.doctor;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    SafeImageWidget(
                      image: _base64Image ?? _currentImageUrl,
                      width: 100,
                      height: 100,
                      borderRadius: 50,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (isDoctor) ...[
                const Divider(height: 32),
                const Text(
                  'Doctor Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _specialtyController,
                  decoration: InputDecoration(
                    labelText: 'Specialty',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clinicController,
                  decoration: InputDecoration(
                    labelText: 'Clinic / Hospital Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Years of Experience',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Consultation Fee (e.g. \$100)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
