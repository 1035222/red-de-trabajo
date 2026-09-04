import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/message.dart';
import '../repositories/mock_repositories.dart';
import '../screens/chat_detail_screen.dart';
import '../widgets/avatar.dart';

class ChatListScreen extends StatelessWidget {
  final ValueChanged<String>? onChatTap;
  final bool fullScreen;
  final VoidCallback? onBack;

  const ChatListScreen({super.key, this.onChatTap, this.fullScreen = true, this.onBack});

  @override
  Widget build(BuildContext context) {
    final chatRepository = MockChatRepository();

    final body = FutureBuilder<List<Message>>(
      future: chatRepository.getConversations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.outline),
                const SizedBox(height: 16),
                Text('No tienes conversaciones', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: RTAvatar(
                imageUrl: message.avatarUrl,
                size: 56,
                fallbackInitial: message.name.isNotEmpty ? message.name[0] : '?',
              ),
                title: Text(message.name, style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text(message.lastMessage, style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(message.time, style: AppTextStyles.labelSm),
                    if (message.unread) Container(margin: const EdgeInsets.only(top: 6), width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  ],
                ),
                onTap: () {
                  if (onChatTap != null) {
                    onChatTap!(message.id);
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(conversationId: message.id)));
                  }
                },
              ),
            );
          },
        );
      },
    );

    if (!fullScreen) return body;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () {
          if (onBack != null) {
            onBack!();
          } else {
            Navigator.maybePop(context);
          }
        }),
        title: Text('Mensajes', style: AppTextStyles.titleLg),
      ),
      body: body,
    );
  }
}
