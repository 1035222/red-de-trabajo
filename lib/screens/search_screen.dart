import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/service.dart';
import '../services/repository_provider.dart';
import '../widgets/service_card.dart';
import '../screens/service_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialCategory;
  final ValueChanged<Service>? onServiceTap;
  final bool fullScreen;
  final VoidCallback? onBack;

  const SearchScreen({super.key, this.initialCategory, this.onServiceTap, this.fullScreen = true, this.onBack});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Todos';
  String _sortBy = 'relevancia';
  final _serviceRepository = RepositoryProvider.serviceRepository;
  List<Service> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Todos';
    _searchController.addListener(() => setState(() {}));
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      final results = await _serviceRepository.searchServices(_searchController.text, _selectedCategory);
      if (_sortBy == 'precio_asc') {
        results.sort((a, b) => a.price.compareTo(b.price));
      } else if (_sortBy == 'precio_desc') {
        results.sort((a, b) => b.price.compareTo(a.price));
      } else if (_sortBy == 'calificacion') {
        results.sort((a, b) => b.rating.compareTo(a.rating));
      }
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error en la búsqueda: ${e.toString().replaceFirst('Exception: ', '')}')));
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar servicios...',
                      hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => _searchController.clear())
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                    onChanged: (_) => _loadResults(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.sort_rounded, color: AppColors.onSurface),
                  onSelected: (value) {
                    setState(() => _sortBy = value);
                    _loadResults();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'relevancia', child: Text('Relevancia')),
                    const PopupMenuItem(value: 'precio_asc', child: Text('Precio: menor a mayor')),
                    const PopupMenuItem(value: 'precio_desc', child: Text('Precio: mayor a menor')),
                    const PopupMenuItem(value: 'calificacion', child: Text('Mejor calificados')),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 7,
            itemBuilder: (context, index) {
              final categories = ['Todos', 'Plomería', 'Electricidad', 'Limpieza', 'Pintura', 'Carpintería', 'Jardinería'];
              final label = categories[index];
              final isSelected = _selectedCategory == label;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  label: Text(label, style: TextStyle(color: isSelected ? AppColors.onPrimary : AppColors.onSurface)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = label);
                    _loadResults();
                  },
                  backgroundColor: AppColors.surfaceContainerLowest,
                  selectedColor: AppColors.primary,
                  checkmarkColor: AppColors.onPrimary,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: AppColors.outline),
                          const SizedBox(height: 16),
                          Text('No se encontraron resultados', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final service = _results[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RTServiceCard(
                            imageUrl: service.imageUrl,
                            serviceName: service.title,
                            providerName: service.providerName,
                            rating: service.rating,
                            price: service.price,
                            onTap: () {
                              if (widget.onServiceTap != null) {
                                widget.onServiceTap!(service);
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service)));
                              }
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );

    if (!widget.fullScreen) return body;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          ),
        ),
        title: Text('Buscar', style: AppTextStyles.titleLg),
      ),
      body: body,
    );
  }
}
