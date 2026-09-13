import 'package:flutter/material.dart';
import 'dart:convert';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final _api = ApiService();

  Future<List<Map<String, dynamic>>> _loadRequests() async {
    final response = await _api.get('/requests');
    if (response.statusCode != 200) throw Exception('No se pudieron cargar solicitudes');
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: Text('Solicitudes', style: AppTextStyles.titleLg),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
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
                    child: Icon(Icons.inbox_outlined, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  Text('No tienes solicitudes pendientes', style: AppTextStyles.headlineMd.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Las solicitudes de servicio aparecerán aquí', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final service = request['service'] as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  tileColor: AppColors.surfaceContainerLowest,
                  title: Text(service['title'] as String? ?? 'Servicio'),
                  subtitle: Text('Estado: ${request['status'] ?? 'pending'}'),
                  leading: const Icon(Icons.assignment_outlined),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
