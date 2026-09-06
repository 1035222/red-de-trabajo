import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/service.dart';
import '../services/repository_provider.dart';
import '../widgets/category_icon.dart';
import '../widgets/service_card.dart';
import '../widgets/publish_fab.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/search_screen.dart';
import '../screens/publish_screen.dart';
import '../screens/chat_list_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/my_profile_screen.dart';
import '../screens/chat_detail_screen.dart';
import '../screens/service_detail_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';
import '../screens/terms_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/requests_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _serviceRepository = RepositoryProvider.serviceRepository;
  List<Service> _featuredServices = [];
  List<Service> _categoriesServices = [];
  List<Service> _recentServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final services = await _serviceRepository.getFeaturedServices();
      final categories = await _serviceRepository.getAllServices();
      if (mounted) {
        setState(() {
          _featuredServices = services;
          _categoriesServices = categories;
          _recentServices = categories.take(4).toList();
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar datos: ${e.toString().replaceFirst('Exception: ', '')}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.primary, AppColors.primaryContainer]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.handshake_rounded, size: 48, color: AppColors.onPrimary),
                  const SizedBox(height: 16),
                  Text('Red de Trabajo', style: AppTextStyles.headlineMd.copyWith(color: AppColors.onPrimary)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_rounded, color: AppColors.primary),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search_rounded, color: AppColors.primary),
              title: const Text('Buscar'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
              title: const Text('Mensajes'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded, color: AppColors.primary),
              title: const Text('Mi perfil'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.favorite_border_rounded, color: AppColors.primary),
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_rounded, color: AppColors.primary),
              title: const Text('Solicitudes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outlined, color: AppColors.onSurfaceVariant),
              title: const Text('Acerca de'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined, color: AppColors.onSurfaceVariant),
              title: const Text('Términos y condiciones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()));
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            featuredServices: _featuredServices,
            categories: _categoriesServices,
            recentServices: _recentServices,
            isLoading: _isLoading,
            onCategoryTap: (category) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(initialCategory: category)));
            },
            onServiceTap: (service) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service)));
            },
            onProfileTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProfileScreen()));
            },
          ),
          SearchScreen(fullScreen: true, onServiceTap: (service) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service)));
          }, onBack: () {
            setState(() => _currentIndex = 0);
          }),
          ChatListScreen(fullScreen: true, onChatTap: (conversationId) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(conversationId: conversationId)));
          }, onBack: () {
            setState(() => _currentIndex = 0);
          }),
          ProfileScreen(onBack: () {
            setState(() => _currentIndex = 0);
          }),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? RTPublishFab(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PublishScreen()));
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: RTBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final List<Service> featuredServices;
  final List<Service> categories;
  final List<Service> recentServices;
  final bool isLoading;
  final ValueChanged<String> onCategoryTap;
  final ValueChanged<Service> onServiceTap;
  final VoidCallback onProfileTap;

  const _HomeTab({
    required this.featuredServices,
    required this.categories,
    required this.recentServices,
    required this.isLoading,
    required this.onCategoryTap,
    required this.onServiceTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final uniqueCategories = <String>{'Todos'};
    for (final s in categories) {
      uniqueCategories.add(s.category);
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 120,
          backgroundColor: AppColors.primary,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_rounded),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_rounded),
              onPressed: onProfileTap,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            title: Text('Red de Trabajo', style: AppTextStyles.titleLg.copyWith(color: AppColors.onPrimary)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¡Bienvenido!', style: AppTextStyles.headlineMd),
                const SizedBox(height: 6),
                Text('¿Qué servicio necesitas hoy?', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(onServiceTap: onServiceTap)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: 'Buscar servicios...',
                        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text('Categorías', style: AppTextStyles.headlineMd),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(onServiceTap: onServiceTap)));
                      },
                      child: Text('Ver todo', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: uniqueCategories.length,
                    itemBuilder: (context, index) {
                      final category = uniqueCategories.elementAt(index);
                      final icon = index == 0 ? Icons.grid_view_rounded : Icons.category_rounded;
                      final color = index == 0 ? AppColors.primary : AppColors.secondary;
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: RTCategoryIcon(icon: icon, color: color, label: category, onTap: () => onCategoryTap(category)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text('Servicios destacados', style: AppTextStyles.headlineMd),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(onServiceTap: onServiceTap)));
                      },
                      child: Text('Ver todo', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: featuredServices.length,
                  itemBuilder: (context, index) {
                    final service = featuredServices[index];
                    return RTServiceCard(
                      imageUrl: service.imageUrl,
                      serviceName: service.title,
                      providerName: service.providerName,
                      rating: service.rating,
                      price: service.price,
                      onTap: () => onServiceTap(service),
                    );
                  },
                ),
                if (recentServices.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Servicios recientes', style: AppTextStyles.headlineMd),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: recentServices.length,
                    itemBuilder: (context, index) {
                      final service = recentServices[index];
                      return RTServiceCard(
                        imageUrl: service.imageUrl,
                        serviceName: service.title,
                        providerName: service.providerName,
                        rating: service.rating,
                        price: service.price,
                        onTap: () => onServiceTap(service),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


