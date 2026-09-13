import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';
import '../models/service.dart';
import '../services/repository_provider.dart';
import '../services/api_service.dart';

class EditServiceScreen extends StatefulWidget {
  final Service service;

  const EditServiceScreen({super.key, required this.service});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(text: widget.service.title);
  late final _categoryController = TextEditingController(text: widget.service.category);
  late final _priceController = TextEditingController(text: widget.service.price);
  late final _descriptionController = TextEditingController(text: widget.service.description);
  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _imageUrl;

  final _serviceRepository = RepositoryProvider.serviceRepository;
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
        filename: 'service_${widget.service.id}_${DateTime.now().millisecondsSinceEpoch}.$extension',
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

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _serviceRepository.updateService(Service(
        id: widget.service.id,
        title: _titleController.text.trim(),
        providerName: widget.service.providerName,
        providerId: widget.service.providerId,
        imageUrl: _imageUrl ?? widget.service.imageUrl,
        rating: widget.service.rating,
        price: _priceController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
      ));
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Servicio actualizado exitosamente')));
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar: ${e.toString().replaceFirst('Exception: ', '')}')));
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: Text('Editar servicio', style: AppTextStyles.titleLg),
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
                            child: TextFormField(
                              controller: _categoryController,
                              decoration: const InputDecoration(
                                labelText: 'Categoría',
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
                      label: Text(_imageUrl == null ? 'Cambiar imagen' : 'Imagen cargada'),
                    ),
                    const SizedBox(height: 16),
                    RTPrimaryButton(text: 'Guardar cambios', onPressed: _handleUpdate, isLoading: _isLoading),
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
