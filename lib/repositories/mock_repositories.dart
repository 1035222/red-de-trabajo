import '../models/app_user.dart';
import '../models/service.dart';
import '../models/message.dart';
import '../models/chat_message.dart';
import '../models/review.dart';
import '../models/notification.dart';
import '../models/portfolio_item.dart';
import 'auth_repository.dart';
import 'service_repository.dart';
import 'chat_repository.dart';
import 'notification_repository.dart';
import 'profile_repository.dart';

class MockAuthRepository implements AuthRepository {
  AppUser? _currentUser;

  @override
  Future<AppUser?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (email.contains('@') && password.length >= 6) {
      _currentUser = AppUser(
        id: 'user_1',
        name: 'Carlos Méndez',
        email: email,
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      );
      return _currentUser;
    }
    return null;
  }

  @override
  Future<AppUser> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }
}

class MockServiceRepository implements ServiceRepository {
  final List<Service> _services = [
    Service(
      id: '1',
      title: 'Reparación de tuberías',
      providerName: 'Carlos Méndez',
      providerId: 'user_1',
      imageUrl: 'https://images.unsplash.com/photo-1581578731438-314f53f6f7f5?w=400',
      rating: 4.8,
      price: '\$35/hr',
      description: 'Servicio profesional de plomería para reparaciones, instalaciones y mantenimiento.',
      category: 'Plomería',
      reviewsCount: 24,
      featured: true,
    ),
    Service(
      id: '2',
      title: 'Instalación eléctrica',
      providerName: 'Ana Ruiz',
      providerId: 'user_2',
      imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a2692?w=400',
      rating: 4.9,
      price: '\$45/hr',
      description: 'Electricista certificada para proyectos residenciales y comerciales.',
      category: 'Electricidad',
      reviewsCount: 18,
      featured: true,
    ),
    Service(
      id: '3',
      title: 'Limpieza profunda',
      providerName: 'María Torres',
      providerId: 'user_3',
      imageUrl: 'https://images.unsplash.com/photo-1584820927498-cfe5211fd8bf?w=400',
      rating: 4.7,
      price: '\$28/hr',
      description: 'Limpieza integral de hogares y oficinas con productos ecológicos.',
      category: 'Limpieza',
      reviewsCount: 31,
      featured: false,
    ),
    Service(
      id: '4',
      title: 'Pintura interior',
      providerName: 'Luis García',
      providerId: 'user_4',
      imageUrl: 'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=400',
      rating: 4.6,
      price: '\$30/hr',
      description: 'Pintura profesional para interiores con acabados de alta calidad.',
      category: 'Pintura',
      reviewsCount: 15,
      featured: false,
    ),
    Service(
      id: '5',
      title: 'Muebles a medida',
      providerName: 'Roberto Díaz',
      providerId: 'user_5',
      imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400',
      rating: 4.9,
      price: '\$120',
      description: 'Diseño y fabricación de muebles personalizados en madera.',
      category: 'Carpintería',
      reviewsCount: 42,
      featured: true,
    ),
    Service(
      id: '6',
      title: 'Diseño de jardines',
      providerName: 'Elena Vega',
      providerId: 'user_6',
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400',
      rating: 4.5,
      price: '\$50/hr',
      description: 'Diseño, mantenimiento y paisajismo de jardines residenciales.',
      category: 'Jardinería',
      reviewsCount: 9,
      featured: false,
    ),
  ];

  @override
  Future<List<Service>> getFeaturedServices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _services.where((s) => s.featured).toList();
  }

  @override
  Future<List<Service>> getAllServices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_services);
  }

  @override
  Future<List<Service>> searchServices(String query, String category) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _services.where((s) {
      final matchesQuery = s.title.toLowerCase().contains(query.toLowerCase()) ||
          s.providerName.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == 'Todos' || s.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Future<Service?> getServiceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Service> createService(Service service) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newService = Service(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      title: service.title,
      providerName: service.providerName,
      providerId: service.providerId,
      imageUrl: service.imageUrl,
      rating: 0.0,
      price: service.price,
      description: service.description,
      category: service.category,
      reviewsCount: 0,
      featured: false,
    );
    _services.add(newService);
    return newService;
  }

  @override
  Future<Service> updateService(Service service) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _services.indexWhere((s) => s.id == service.id);
    if (index != -1) {
      _services[index] = service;
      return _services[index];
    }
    throw Exception('Servicio no encontrado');
  }

  @override
  Future<void> deleteService(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _services.removeWhere((s) => s.id == id);
  }
}

class MockChatRepository implements ChatRepository {
  final List<Message> _conversations = [
    Message(
      id: '1',
      name: 'Carlos Méndez',
      lastMessage: '¿Podemos coordinar para mañana?',
      time: '10:30',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      unread: true,
    ),
    Message(
      id: '2',
      name: 'Ana Ruiz',
      lastMessage: 'Gracias por la recomendación',
      time: 'Ayer',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      unread: false,
    ),
    Message(
      id: '3',
      name: 'María Torres',
      lastMessage: 'El presupuesto está listo',
      time: 'Lun',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      unread: true,
    ),
  ];

  final Map<String, List<ChatMessage>> _chatHistory = {
    '1': [
      ChatMessage(id: '1', text: 'Hola, vi tu servicio de plomería', type: MessageType.text, isMe: true, time: DateTime(2026, 8, 29, 9, 0)),
      ChatMessage(id: '2', text: '¡Hola! Sí, ¿en qué puedo ayudarte?', type: MessageType.text, isMe: false, time: DateTime(2026, 8, 29, 9, 1)),
      ChatMessage(id: '3', text: 'Necesito reparar una tubería en la cocina', type: MessageType.text, isMe: true, time: DateTime(2026, 8, 29, 9, 2)),
      ChatMessage(id: '4', text: 'Perfecto, ¿podemos coordinar para mañana?', type: MessageType.text, isMe: false, time: DateTime(2026, 8, 29, 9, 3)),
    ],
  };

  @override
  Future<List<Message>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_conversations);
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_chatHistory[conversationId] ?? []);
  }

  @override
  Future<ChatMessage> sendMessage(String conversationId, String text) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final message = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isMe: true,
      time: DateTime.now(),
      type: MessageType.text,
    );
    _chatHistory.putIfAbsent(conversationId, () => []).add(message);
    final conversation = _conversations.firstWhere((c) => c.id == conversationId);
    final updated = Message(
      id: conversation.id,
      name: conversation.name,
      lastMessage: text,
      time: 'Ahora',
      avatarUrl: conversation.avatarUrl,
      unread: false,
    );
    _conversations.removeWhere((c) => c.id == conversationId);
    _conversations.insert(0, updated);
    return message;
  }

  @override
  Future<ChatMessage> sendLocation(String conversationId, double latitude, double longitude, String address) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final message = ChatMessage(
      id: 'loc_${DateTime.now().millisecondsSinceEpoch}',
      text: 'Ubicación compartida',
      isMe: true,
      time: DateTime.now(),
      type: MessageType.location,
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
    _chatHistory.putIfAbsent(conversationId, () => []).add(message);
    final conversation = _conversations.firstWhere((c) => c.id == conversationId);
    final updated = Message(
      id: conversation.id,
      name: conversation.name,
      lastMessage: '📍 Ubicación',
      time: 'Ahora',
      avatarUrl: conversation.avatarUrl,
      unread: false,
    );
    _conversations.removeWhere((c) => c.id == conversationId);
    _conversations.insert(0, updated);
    return message;
  }

  @override
  Future<ChatMessage> sendAudio(String conversationId, int durationSeconds, String audioUrl) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final message = ChatMessage(
      id: 'audio_${DateTime.now().millisecondsSinceEpoch}',
      text: 'Nota de voz',
      isMe: true,
      time: DateTime.now(),
      type: MessageType.audio,
      audioDurationSeconds: durationSeconds,
      audioUrl: audioUrl,
    );
    _chatHistory.putIfAbsent(conversationId, () => []).add(message);
    final conversation = _conversations.firstWhere((c) => c.id == conversationId);
    final updated = Message(
      id: conversation.id,
      name: conversation.name,
      lastMessage: '🎤 Nota de voz',
      time: 'Ahora',
      avatarUrl: conversation.avatarUrl,
      unread: false,
    );
    _conversations.removeWhere((c) => c.id == conversationId);
    _conversations.insert(0, updated);
    return message;
  }
}

class MockNotificationRepository implements NotificationRepository {
  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      title: 'Nueva solicitud de servicio',
      body: 'Carlos Méndez solicitó tu servicio de plomería',
      time: DateTime(2026, 8, 29, 10, 0),
      read: false,
    ),
    AppNotification(
      id: '2',
      title: 'Reseña recibida',
      body: 'Juan Pérez te dejó una reseña de 5 estrellas',
      time: DateTime(2026, 8, 28, 15, 30),
      read: false,
    ),
    AppNotification(
      id: '3',
      title: 'Pago procesado',
      body: 'Tu pago de \$120 ha sido procesado exitosamente',
      time: DateTime(2026, 8, 27, 9, 0),
      read: true,
    ),
  ];

  @override
  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_notifications);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = AppNotification(
        id: _notifications[index].id,
        title: _notifications[index].title,
        body: _notifications[index].body,
        time: _notifications[index].time,
        read: true,
      );
    }
  }
}

class MockProfileRepository implements ProfileRepository {
  AppUser _currentUser = AppUser(
    id: 'user_1',
    name: 'Carlos Méndez',
    email: 'carlos@example.com',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
  );

  final List<Review> _reviews = [
    Review(
      id: '1',
      userName: 'Juan Pérez',
      userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      rating: 5,
      comment: 'Excelente trabajo, muy profesional y puntual.',
      date: DateTime(2026, 8, 20),
    ),
    Review(
      id: '2',
      userName: 'Laura Gómez',
      userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      rating: 4,
      comment: 'Buen servicio, aunque tardó un poco más de lo acordado.',
      date: DateTime(2026, 8, 15),
    ),
    Review(
      id: '3',
      userName: 'Pedro Sánchez',
      userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      rating: 5,
      comment: 'Recomendado 100%, volvería a contratarlo.',
      date: DateTime(2026, 8, 10),
    ),
  ];

  final List<PortfolioItem> _portfolio = [
    PortfolioItem(id: '1', imageUrl: 'https://images.unsplash.com/photo-1581578731438-314f53f6f7f5?w=400', title: 'Reparación cocina'),
    PortfolioItem(id: '2', imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a2692?w=400', title: 'Instalación eléctrica'),
    PortfolioItem(id: '3', imageUrl: 'https://images.unsplash.com/photo-1584820927498-cfe5211fd8bf?w=400', title: 'Limpieza oficina'),
    PortfolioItem(id: '4', imageUrl: 'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=400', title: 'Pintura sala'),
    PortfolioItem(id: '5', imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400', title: 'Mueble comedor'),
    PortfolioItem(id: '6', imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400', title: 'Jardín residencial'),
  ];

  @override
  Future<AppUser> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (userId == _currentUser.id) return _currentUser;
    return _currentUser.copyWith(name: _currentUser.name);
  }

  @override
  Future<AppUser> updateUserProfile(AppUser user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = user;
    return _currentUser;
  }

  @override
  Future<List<Review>> getUserReviews(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_reviews);
  }

  @override
  Future<List<PortfolioItem>> getUserPortfolio(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_portfolio);
  }
}
