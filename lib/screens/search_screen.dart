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

  const SearchScreen({
    super.key,
    this.initialCategory,
    this.onServiceTap,
    this.fullScreen = true,
    this.onBack,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _locationController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  String _selectedCategory = 'Todos';
  String _sortBy = 'relevancia';
  double? _minPrice;
  double? _maxPrice;
  String? _location;
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
      final results = await _serviceRepository.searchServices(
        _searchController.text,
        _selectedCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        location: _location,
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error en la búsqueda: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    _locationController.text = _location ?? '';
    _minPriceController.text = _minPrice?.toStringAsFixed(0) ?? '';
    _maxPriceController.text = _maxPrice?.toStringAsFixed(0) ?? '';

    final filters =
        await showModalBottomSheet<
          ({double? minPrice, double? maxPrice, String? location})
        >(
          context: context,
          isScrollControlled: true,
          builder: (context) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text('Filtrar servicios', style: AppTextStyles.titleLg),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Precio mínimo',
                          prefixText: '\$ ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Precio máximo',
                          prefixText: '\$ ',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    final minPrice = double.tryParse(
                      _minPriceController.text.trim(),
                    );
                    final maxPrice = double.tryParse(
                      _maxPriceController.text.trim(),
                    );
                    if (minPrice != null &&
                        maxPrice != null &&
                        minPrice > maxPrice) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'El precio mínimo no puede superar al máximo',
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context, (
                      minPrice: minPrice,
                      maxPrice: maxPrice,
                      location: _locationController.text.trim().isEmpty
                          ? null
                          : _locationController.text.trim(),
                    ));
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Aplicar filtros'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, (
                    minPrice: null,
                    maxPrice: null,
                    location: null,
                  )),
                  child: const Text('Limpiar filtros'),
                ),
              ],
            ),
          ),
        );

    if (filters == null || !mounted) return;
    setState(() {
      _minPrice = filters.minPrice;
      _maxPrice = filters.maxPrice;
      _location = filters.location;
      _isLoading = true;
    });
    _loadResults();
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
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar servicios...',
                      hintStyle: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.onSurfaceVariant,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
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
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.sort_rounded,
                    color: AppColors.onSurface,
                  ),
                  onSelected: (value) {
                    setState(() => _sortBy = value);
                    _loadResults();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'relevancia',
                      child: Text('Relevancia'),
                    ),
                    const PopupMenuItem(
                      value: 'precio_asc',
                      child: Text('Precio: menor a mayor'),
                    ),
                    const PopupMenuItem(
                      value: 'precio_desc',
                      child: Text('Precio: mayor a menor'),
                    ),
                    const PopupMenuItem(
                      value: 'calificacion',
                      child: Text('Mejor calificados'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible:
                    _minPrice != null || _maxPrice != null || _location != null,
                label: const Text(''),
                child: IconButton(
                  tooltip: 'Filtros',
                  onPressed: _openFilters,
                  icon: const Icon(Icons.tune_rounded),
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
              final categories = [
                'Todos',
                'Plomería',
                'Electricidad',
                'Limpieza',
                'Pintura',
                'Carpintería',
                'Jardinería',
              ];
              final label = categories[index];
              final isSelected = _selectedCategory == label;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  label: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.onSurface,
                    ),
                  ),
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
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: AppColors.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron resultados',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ServiceDetailScreen(service: service),
                              ),
                            );
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
