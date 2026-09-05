import '../models/message.dart';
import '../models/chat_message.dart';

abstract class ChatRepository {
  Future<List<Message>> getConversations();
  Future<List<ChatMessage>> getMessages(String conversationId);
  Future<ChatMessage> sendMessage(String conversationId, String text);
  Future<ChatMessage> sendLocation(String conversationId, double latitude, double longitude, String address);
  Future<ChatMessage> sendAudio(String conversationId, int durationSeconds, String audioUrl);
}
