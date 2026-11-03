import '../models/message.dart';
import '../models/chat_message.dart';

abstract class ChatRepository {
  Future<List<Message>> getConversations();
  Future<List<ChatMessage>> getMessages(String conversationId);
  Future<void> deleteMessage(String conversationId, String messageId);
  Future<ChatMessage> sendMessage(String conversationId, String text);
  Future<ChatMessage> sendLocation(String conversationId, double latitude, double longitude, String address);
  Future<ChatMessage> sendAudio(String conversationId, int durationSeconds, String audioUrl);
  Stream<ChatMessage> watchMessages(String conversationId);
  void joinConversation(String conversationId);
  void leaveConversation(String conversationId);
  void dispose();
}
