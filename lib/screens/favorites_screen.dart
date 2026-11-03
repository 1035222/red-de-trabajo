import '../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/service.dart';
import '../services/api_service.dart';
import '../widgets/service_card.dart';
import '../screens/service_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _api = ApiService();

  Future<List<Service>> _loadFavorites() async {
    final response = await _api.get('/favorites');
    if (response.statusCode != 200) throw Exception('No se pudieron cargar favoritos');
    final data = jsonDecode(response.body) as List;
    return data.map((item) => Service.fromJson(item['service'] as Map<String, dynamic>)).toList();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: LocalizedText('Favoritos', style: AppTextStyles.titleLg),
      ),
      body: FutureBuilder<List<Service>>(
        future: _loadFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary.withValues(alpha: 0.12), AppColors.primaryContainer.withValues(alpha: 0.06)]),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.favorite_border_rounded, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  LocalizedText('No tienes favoritos guardados', style: AppTextStyles.headlineMd.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  LocalizedText('Explora servicios y guarda tus favoritos', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final service = favorites[index];
              return RTServiceCard(
                imageUrl: service.imageUrl,
                serviceName: service.title,
                providerName: service.providerName,
                rating: service.rating,
                price: service.price,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service)));
                },
              );
            },
          );
        },
      ),
    );
  }
}
