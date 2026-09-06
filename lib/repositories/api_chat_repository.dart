import 'dart:convert';
import 'package:red_de_trabajo/services/api_service.dart';
import '../models/chat_message.dart';
import '../models/message.dart';
import 'chat_repository.dart';

class ApiChatRepository implements ChatRepository {
  final ApiService _api;

  ApiChatRepository(this._api);

  @override
  Future<List<Message>> getConversations() async {
    final response = await _api.get('/chat');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((json) => Message.fromJson(json)).toList();
      }
      return [];
    }
    throw Exception('Error al obtener conversaciones');
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final response = await _api.get('/chat');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((json) => ChatMessage.fromJson(json)).toList();
      }
      return [];
    }
    throw Exception('Error al obtener mensajes');
  }

  @override
  Future<ChatMessage> sendMessage(String conversationId, String text) async {
    final response = await _api.post('/chat', {'text': text});
    if (response.statusCode == 201) {
      return ChatMessage.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al enviar mensaje');
  }

  @override
  Future<ChatMessage> sendLocation(String conversationId, double latitude, double longitude, String address) async {
    final response = await _api.post('/chat', {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    });
    if (response.statusCode == 201) {
      return ChatMessage.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al enviar ubicación');
  }

  @override
  Future<ChatMessage> sendAudio(String conversationId, int durationSeconds, String audioUrl) async {
    final response = await _api.post('/chat', {
      'durationSeconds': durationSeconds,
      'audioUrl': audioUrl,
    });
    if (response.statusCode == 201) {
      return ChatMessage.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al enviar audio');
  }
}
