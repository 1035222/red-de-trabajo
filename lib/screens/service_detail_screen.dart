import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/service.dart';
import '../models/review.dart';
import '../services/api_service.dart';
import 'chat_detail_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Service service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final _api = ApiService();
  bool _isFavorite = false;
  bool _isBusy = false;
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final response = await _api.get('/reviews/service/${widget.service.id}');
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body) as List;
        setState(() => _reviews = data.map((item) => Review.fromJson(item as Map<String, dynamic>)).toList());
      }
    } catch (_) {}
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final response = await _api.get('/favorites/${widget.service.id}');
      if (response.statusCode == 200 && mounted) {
        setState(() => _isFavorite = (jsonDecode(response.body)['favorite'] as bool?) ?? false);
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final response = await _api.post('/favorites/${widget.service.id}/toggle', {});
      if (response.statusCode == 200 && mounted) {
        setState(() => _isFavorite = jsonDecode(response.body)['favorite'] as bool);
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _requestService() async {
    final messageController = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitar servicio'),
        content: TextField(controller: messageController, maxLines: 3, decoration: const InputDecoration(hintText: 'Escribe un mensaje para el proveedor')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, messageController.text.trim()), child: const Text('Enviar solicitud')),
        ],
      ),
    );
    messageController.dispose();
    if (message == null) return;
    final response = await _api.post('/services/${widget.service.id}/requests', {'message': message});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.statusCode == 201 || response.statusCode == 200 ? 'Solicitud enviada' : 'No se pudo enviar la solicitud')));
  }

  Future<void> _openChat() async {
    final response = await _api.post('/chat/conversations', {'participantId': widget.service.providerId});
    if (!mounted) return;
    if (response.statusCode == 200 || response.statusCode == 201) {
      final id = (jsonDecode(response.body) as Map<String, dynamic>)['id'] as String;
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(conversationId: id)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir el chat')));
    }
  }

  Future<void> _writeReview() async {
    var rating = 5.0;
    final commentController = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        title: const Text('Calificar servicio'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (index) => IconButton(onPressed: () => setDialogState(() => rating = index + 1.0), icon: Icon(index < rating ? Icons.star : Icons.star_border, color: AppColors.secondary)))),
          TextField(controller: commentController, maxLines: 3, decoration: const InputDecoration(hintText: 'Escribe un comentario')),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Publicar'))],
      )),
    );
    if (submitted != true || commentController.text.trim().isEmpty) return;
    final response = await _api.post('/reviews', {'serviceId': widget.service.id, 'rating': rating, 'comment': commentController.text.trim()});
    commentController.dispose();
    await _loadReviews();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.statusCode == 201 ? 'Reseña publicada' : 'No se pudo publicar la reseña')));
  }

  Future<void> _shareService() async {
    final text = '${widget.service.title}\n${widget.service.description}\nPrecio: ${widget.service.price}';
    try {
      final response = await http.get(Uri.parse(widget.service.imageUrl));
      final image = XFile.fromData(response.bodyBytes, name: 'servicio-${widget.service.id}.jpg', mimeType: 'image/jpeg');
      await SharePlus.instance.share(ShareParams(text: text, files: [image]));
    } catch (_) {
      await SharePlus.instance.share(ShareParams(text: text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: AppColors.surface,
            leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
            actions: [
              IconButton(
                icon: Icon(_isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: _isFavorite ? Colors.red : null),
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {
                  _shareService();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.service.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported_outlined, size: 64, color: AppColors.outline),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(widget.service.title, style: AppTextStyles.headlineLg)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(widget.service.rating.toString(), style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.secondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.service.providerName, style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('Ciudad de México', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(widget.service.price, style: AppTextStyles.headlineMd.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 24),
                  Text('Descripción', style: AppTextStyles.headlineMd),
                  const SizedBox(height: 8),
                  Text(widget.service.description, style: AppTextStyles.bodyMd),
                  const SizedBox(height: 24),
                  Text('Categoría', style: AppTextStyles.headlineMd),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: Text(widget.service.category, style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                  ),
                  const SizedBox(height: 24),
                  Text('Reseñas', style: AppTextStyles.headlineMd),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                            index < widget.service.rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 20,
                          color: AppColors.secondary,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text('${widget.service.rating} (${widget.service.reviewsCount} reseñas)', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_reviews.isEmpty)
                    Text('Aún no hay comentarios.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant))
                  else
                    ..._reviews.take(5).map((review) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(child: Text(review.userName.isEmpty ? 'U' : review.userName[0].toUpperCase())),
                            title: Row(children: [Text(review.userName), const SizedBox(width: 8), Text('${review.rating}/5')]),
                            subtitle: Text(review.comment),
                          ),
                        )),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _openChat();
                          },
                          icon: const Icon(Icons.message_rounded),
                          label: const Text('Enviar mensaje'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.onSecondary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _requestService();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
                          child: const Text('Solicitar servicio'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(onPressed: _writeReview, icon: const Icon(Icons.rate_review_outlined), label: const Text('Escribir reseña')),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
