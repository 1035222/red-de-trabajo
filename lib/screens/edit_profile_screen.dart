import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../widgets/avatar.dart';
import '../models/app_user.dart';
import '../services/repository_provider.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final AppUser user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.user.name);
  late final _emailController = TextEditingController(text: widget.user.email);
  late final _bioController = TextEditingController(text: widget.user.bio ?? '');
  late final _locationController = TextEditingController(text: widget.user.location ?? '');
  String? _avatarUrl;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  final _profileRepository = RepositoryProvider.profileRepository;
  final _imagePicker = ImagePicker();
  final _api = ApiService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      final bytes = await pickedFile.readAsBytes();
      final originalName = pickedFile.name;
      final extension = originalName.contains('.') ? originalName.split('.').last.toLowerCase() : 'jpg';
      final downloadUrl = await _api.uploadImage(
        bytes: bytes,
        filename: 'avatar_${widget.user.id}_${DateTime.now().millisecondsSinceEpoch}.$extension',
      );

      if (mounted) setState(() => _avatarUrl = downloadUrl);
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final updated = widget.user.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        avatarUrl: _avatarUrl ?? widget.user.avatarUrl,
      );
      await _profileRepository.updateUserProfile(updated);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar perfil: ${e.toString().replaceFirst('Exception: ', '')}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayAvatarUrl = _avatarUrl ?? widget.user.avatarUrl;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: Text('Editar perfil', style: AppTextStyles.titleLg),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AvatarEditor(
                      avatarUrl: displayAvatarUrl,
                      isUploading: _isUploadingImage,
                      onEditTap: _pickAndUploadImage,
                      fallbackInitial: widget.user.name.isNotEmpty ? widget.user.name[0] : 'U',
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre completo',
                                border: InputBorder.none,
                                labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
                            ),
                          ),
                          Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextFormField(
                              readOnly: true,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                border: InputBorder.none,
                                labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ),
                          Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextFormField(
                              controller: _bioController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Biografía',
                                border: InputBorder.none,
                                labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ),
                          Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Ubicación',
                                border: InputBorder.none,
                                labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    RTPrimaryButton(text: 'Guardar cambios', onPressed: _handleSave, isLoading: _isLoading),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarEditor extends StatelessWidget {
  final String? avatarUrl;
  final bool isUploading;
  final VoidCallback onEditTap;
  final String fallbackInitial;

  const _AvatarEditor({
    required this.avatarUrl,
    required this.isUploading,
    required this.onEditTap,
    required this.fallbackInitial,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: isUploading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : RTAvatar(
                    imageUrl: avatarUrl,
                    size: 100,
                    fallbackInitial: fallbackInitial,
                  ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                    )
                  : IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.onPrimary),
                      onPressed: onEditTap,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
