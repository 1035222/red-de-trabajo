import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../models/service.dart';
import '../services/repository_provider.dart';
import '../services/session_service.dart';
import '../services/api_service.dart';

class PublishScreen extends StatefulWidget {
  const PublishScreen({super.key});

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _imageUrl;

  static const _categories = [
    'Plomería',
    'Electricidad',
    'Limpieza',
    'Pintura',
    'Carpintería',
    'Jardinería',
    'Diseño',
    'Fotografía',
  ];

  final _serviceRepository = RepositoryProvider.serviceRepository;
  final _sessionService = SessionService();
  final _imagePicker = ImagePicker();
  final _api = ApiService();

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    try {
      setState(() => _isUploadingImage = true);
      final bytes = await pickedFile.readAsBytes();
      final originalName = pickedFile.name;
      final extension = originalName.contains('.') ? originalName.split('.').last.toLowerCase() : 'jpg';
      final url = await _api.uploadImage(
        bytes: bytes,
        filename: 'service_${DateTime.now().millisecondsSinceEpoch}.$extension',
      );
      if (mounted) setState(() => _imageUrl = url);
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir imagen: ${e.toString().replaceFirst('Exception: ', '')}')));
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final session = await _sessionService.getSession();
      final providerId = session?.user?.id;
      if (providerId == null || providerId.isEmpty) {
        throw Exception('No hay una sesión autenticada');
      }
      await _serviceRepository.createService(Service(
        id: '',
        title: _titleController.text.trim(),
        providerName: 'Usuario Actual',
        providerId: providerId,
        imageUrl: _imageUrl ?? '',
        rating: 0.0,
        price: _priceController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
      ));
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Servicio publicado exitosamente')));
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al publicar: ${e.toString().replaceFirst('Exception: ', '')}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
        title: Text('Publicar servicio', style: AppTextStyles.titleLg),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Título del servicio',
                                border: InputBorder.none,
                                labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
                            ),
                          ),
                          Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: DropdownButtonFormField<String>(
                              initialValue: _categoryController.text.isEmpty ? null : _categoryController.text,
                              decoration: const InputDecoration(labelText: 'Categoría', border: InputBorder.none),
                              items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                              onChanged: (value) => _categoryController.text = value ?? '',
                              validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
                            ),
                          ),
                          Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Precio (ej: \$35/hr)',
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
                              controller: _descriptionController,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText: 'Descripción',
                                border: InputBorder.none,
                                labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                      icon: _isUploadingImage ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(_imageUrl == null ? 'Agregar imagen' : 'Imagen cargada'),
                    ),
                    const SizedBox(height: 16),
                    RTPrimaryButton(text: 'Publicar', onPressed: _handlePublish, isLoading: _isLoading),
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
