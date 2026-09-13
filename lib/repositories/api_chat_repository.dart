import 'dart:convert';
import 'package:red_de_trabajo/services/api_service.dart';
import 'package:red_de_trabajo/services/socket_service.dart';
import 'package:red_de_trabajo/services/session_service.dart';
import '../models/chat_message.dart';
import '../models/message.dart';
import 'chat_repository.dart';

class ApiChatRepository implements ChatRepository {
  final ApiService _api;
  final SocketService _socketService = SocketService();
  final SessionService _sessionService = SessionService();
  String? _currentUserId;

  ApiChatRepository(this._api);

  Future<void> _ensureUser() async {
    if (_currentUserId == null) {
      final session = await _sessionService.getSession();
      _currentUserId = session?.user?.id;
    }
  }

  @override
  Future<List<Message>> getConversations() async {
    await _ensureUser();
    final response = await _api.get('/chat/conversations');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((json) => Message.fromJson(json)).toList();
      }
      return [];
    }
    throw Exception('Error al obtener conversaciones (${response.statusCode})');
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    await _ensureUser();
    final response = await _api.get('/chat/conversations/$conversationId/messages');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((json) => ChatMessage.fromJson(json, currentUserId: _currentUserId)).toList();
      }
      return [];
    }
    throw Exception('Error al obtener mensajes (${response.statusCode})');
  }

  @override
  Future<ChatMessage> sendMessage(String conversationId, String text) async {
    await _ensureUser();
    final response = await _api.post('/chat/conversations/$conversationId/messages', {'text': text});
    if (response.statusCode == 201) {
      return ChatMessage.fromJson(jsonDecode(response.body), currentUserId: _currentUserId);
    }
    throw Exception('Error al enviar mensaje (${response.statusCode})');
  }

  @override
  Future<ChatMessage> sendLocation(String conversationId, double latitude, double longitude, String address) async {
    await _ensureUser();
    final response = await _api.post('/chat/conversations/$conversationId/messages', {
      'text': '📍 Ubicación compartida',
      'type': 'location',
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    });
    if (response.statusCode == 201) {
      return ChatMessage.fromJson(jsonDecode(response.body), currentUserId: _currentUserId);
    }
    throw Exception('Error al enviar ubicación (${response.statusCode})');
  }

  @override
  Future<ChatMessage> sendAudio(String conversationId, int durationSeconds, String audioUrl) async {
    await _ensureUser();
    final response = await _api.post('/chat/conversations/$conversationId/messages', {
      'text': '🎵 Nota de voz',
      'type': 'audio',
      'audioUrl': audioUrl,
      'audioDurationSeconds': durationSeconds,
    });
    if (response.statusCode == 201) {
      return ChatMessage.fromJson(jsonDecode(response.body), currentUserId: _currentUserId);
    }
    throw Exception('Error al enviar audio (${response.statusCode})');
  }

  @override
  Stream<ChatMessage> watchMessages(String conversationId) {
    return _socketService.messageStream
      .where((data) => data['conversationId'] == conversationId)
      .map((data) => ChatMessage.fromJson(data, currentUserId: _currentUserId));
  }

  @override
  void joinConversation(String conversationId) {
    _socketService.connect().then((_) {
      _socketService.joinConversation(conversationId);
    });
  }

  @override
  void leaveConversation(String conversationId) {
    _socketService.leaveConversation(conversationId);
  }

  @override
  void dispose() {
    _socketService.disconnect();
  }
}
