import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/message.dart';
import '../models/chat_message.dart';
import '../repositories/mock_repositories.dart';
import '../widgets/avatar.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;

  const ChatDetailScreen({super.key, required this.conversationId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _chatRepository = MockChatRepository();
  List<ChatMessage> _messages = [];
  Message? _conversation;

  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  Future<void> _loadConversation() async {
    final messages = await _chatRepository.getMessages(widget.conversationId);
    final conversations = await _chatRepository.getConversations();
    final conversation = conversations.firstWhere((c) => c.id == widget.conversationId, orElse: () => Message(id: widget.conversationId, name: 'Chat', lastMessage: '', time: '', avatarUrl: '', unread: false));
    if (mounted) {
      setState(() {
        _messages = messages;
        _conversation = conversation;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    await _chatRepository.sendMessage(widget.conversationId, text);
    _messageController.clear();
    _loadConversation();
  }

  @override
  Widget build(BuildContext context) {
    final conversation = _conversation;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            RTAvatar(
              imageUrl: conversation?.avatarUrl,
              size: 36,
              fallbackInitial: (conversation?.name ?? '?')[0],
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(conversation?.name ?? 'Chat', style: AppTextStyles.titleLg, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: message.isMe
                          ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryContainer])
                          : null,
                      color: message.isMe ? null : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Text(message.text, style: TextStyle(color: message.isMe ? AppColors.onPrimary : AppColors.onSurface)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryContainer]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded, color: AppColors.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
