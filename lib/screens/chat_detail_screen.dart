import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/chat_message.dart';
import '../models/message.dart';
import '../repositories/mock_repositories.dart';
import '../widgets/avatar.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;

  const ChatDetailScreen({super.key, required this.conversationId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _chatRepository = MockChatRepository();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  Message? _conversation;
  bool _isTyping = false;
  bool _hasMessages = false;

  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    final messages = await _chatRepository.getMessages(widget.conversationId);
    final conversations = await _chatRepository.getConversations();
    final conversation = conversations.firstWhere(
      (c) => c.id == widget.conversationId,
      orElse: () => Message(id: widget.conversationId, name: 'Chat', lastMessage: '', time: '', avatarUrl: '', unread: false),
    );
    if (mounted) {
      setState(() {
        _messages = messages;
        _conversation = conversation;
        _hasMessages = messages.isNotEmpty;
      });
      if (messages.isNotEmpty) _scrollToBottom();
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() => _hasMessages = true);
    await _chatRepository.sendMessage(widget.conversationId, text);
    _messageController.clear();
    await _loadConversation();
    _showTypingAndReply();
  }

  void _showTypingAndReply() {
    setState(() => _isTyping = true);
    _scrollToBottom();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isTyping = false);
      _chatRepository.sendMessage(widget.conversationId, 'Entendido, te confirmo en un momento.');
      _loadConversation();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  ),
                  title: Text('Foto', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Función próximamente')));
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.location_on_rounded, color: AppColors.secondary),
                  ),
                  title: Text('Ubicación', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface)),
                  onTap: () {
                    Navigator.pop(context);
                    _sendMockLocation();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendMockLocation() async {
    setState(() => _hasMessages = true);
    await _chatRepository.sendLocation(
      widget.conversationId,
      19.432608 + (Random().nextDouble() - 0.5) * 0.1,
      -99.133209 + (Random().nextDouble() - 0.5) * 0.1,
      'Av. Reforma ${Random().nextInt(300) + 1}, Ciudad de México',
    );
    await _loadConversation();
    _showTypingAndReply();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(messageDay).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isConsecutive(ChatMessage current, ChatMessage? previous) {
    if (previous == null) return false;
    if (current.isMe != previous.isMe) return false;
    final diff = current.time.difference(previous.time).inMinutes;
    return diff <= 5;
  }

  bool _isLastInGroup(int index) {
    if (index >= _messages.length - 1) return true;
    final next = _messages[index + 1];
    final current = _messages[index];
    return current.isMe != next.isMe || !_isSameDay(current.time, next.time) || current.time.difference(next.time).inMinutes > 5;
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.outlineVariant.withValues(alpha: 0.5), thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_formatDateSeparator(date), style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
          ),
          Expanded(child: Divider(color: AppColors.outlineVariant.withValues(alpha: 0.5), thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RTAvatar(
            imageUrl: _conversation?.avatarUrl,
            size: 28,
            fallbackInitial: (_conversation?.name ?? '?')[0],
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationContent(ChatMessage message) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mapa: ${message.address ?? 'ubicación'}'), behavior: SnackBarBehavior.floating),
        );
      },
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primaryContainer, AppColors.primaryFixedDim]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Icon(Icons.map_rounded, color: AppColors.onPrimary, size: 48),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 16, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          message.address ?? 'Ubicación compartida',
                          style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.latitude?.toStringAsFixed(4) ?? '0.0000'}, ${message.longitude?.toStringAsFixed(4) ?? '0.0000'}',
                    style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioContent(ChatMessage message) {
    final duration = message.audioDurationSeconds ?? 0;
    final bars = <Widget>[];
    final random = Random(message.id.hashCode);
    for (var i = 0; i < 18; i++) {
      final height = random.nextDouble() * 14 + 6;
      bars.add(Container(width: 3, height: height, decoration: BoxDecoration(color: AppColors.onPrimary.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(2))));
    }
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reproducción simulada'), behavior: SnackBarBehavior.floating));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: AppColors.onPrimary.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Icon(Icons.play_arrow_rounded, color: AppColors.onPrimary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Row(mainAxisSize: MainAxisSize.min, children: bars)),
            const SizedBox(width: 12),
            Text(_formatDuration(duration), style: AppTextStyles.labelSm.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.85))),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final previous = index > 0 ? _messages[index - 1] : null;
    final isConsecutive = _isConsecutive(message, previous);
    final isLast = _isLastInGroup(index);
    final isMe = message.isMe;

    final marginBottom = isLast ? 16.0 : 3.0;
    final avatarMargin = isConsecutive ? 0.0 : 0.0;

    Widget content = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(
        gradient: isMe
            ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryContainer])
            : null,
        color: isMe ? null : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.type == MessageType.text)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(message.text, style: TextStyle(color: isMe ? AppColors.onPrimary : AppColors.onSurface)),
            ),
          if (message.type == MessageType.location) Padding(padding: const EdgeInsets.fromLTRB(8, 8, 8, 4), child: _buildLocationContent(message)),
          if (message.type == MessageType.audio) Padding(padding: const EdgeInsets.fromLTRB(8, 8, 8, 4), child: _buildAudioContent(message)),
          Padding(
            padding: EdgeInsets.fromLTRB(message.type == MessageType.text ? 16 : 8, message.type == MessageType.text ? 4 : 8, 16, 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_formatTime(message.time), style: AppTextStyles.labelSm.copyWith(color: isMe ? AppColors.onPrimary.withValues(alpha: 0.75) : AppColors.onSurfaceVariant)),
                if (isMe && isLast) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.time.isAfter(DateTime.now().subtract(const Duration(minutes: 1))) ? Icons.done_all_rounded : Icons.check_rounded,
                    size: 14,
                    color: AppColors.onPrimary.withValues(alpha: 0.75),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (isMe) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: EdgeInsets.only(right: 16, bottom: marginBottom),
          child: content,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: marginBottom),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isConsecutive)
            Padding(
              padding: EdgeInsets.only(right: 8 + avatarMargin),
              child: RTAvatar(
                imageUrl: _conversation?.avatarUrl,
                size: 28,
                fallbackInitial: (_conversation?.name ?? '?')[0],
              ),
            )
          else
            const SizedBox(width: 36),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.primaryContainer.withValues(alpha: 0.05)]),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text('Inicia la conversación', style: AppTextStyles.titleLg.copyWith(color: AppColors.onBackground)),
            const SizedBox(height: 8),
            Text(
              'Envía el primer mensaje a ${_conversation?.name ?? 'este contacto'}',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final hasText = _messageController.text.trim().isNotEmpty;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _openAttachmentMenu,
            icon: Icon(Icons.attach_file_rounded, color: AppColors.onSurfaceVariant),
            style: IconButton.styleFrom(backgroundColor: AppColors.surface, foregroundColor: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
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
          if (hasText)
            AnimatedOpacity(
              opacity: hasText ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: Container(
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
            )
          else
            _AudioRecordButton(onRecorded: _sendMockAudio),
        ],
      ),
    );
  }

  Future<void> _sendMockAudio() async {
    setState(() => _hasMessages = true);
    await _chatRepository.sendAudio(widget.conversationId, Random().nextInt(20) + 5, 'mock_audio_url');
    await _loadConversation();
    _showTypingAndReply();
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
            child: _hasMessages
                ? ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == _messages.length) {
                        return _buildTypingIndicator();
                      }
                      final message = _messages[index];
                      final showDateSeparator = index == 0 || !_isSameDay(_messages[index].time, _messages[index - 1].time);
                      final items = <Widget>[
                        if (showDateSeparator) _buildDateSeparator(message.time),
                        _buildMessageBubble(message, index),
                      ];
                      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: items);
                    },
                  )
                : _buildEmptyState(),
          ),
          _buildInputArea(),
        ],
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}

class _AudioRecordButton extends StatefulWidget {
  final Future<void> Function() onRecorded;

  const _AudioRecordButton({required this.onRecorded});

  @override
  State<_AudioRecordButton> createState() => _AudioRecordButtonState();
}

class _AudioRecordButtonState extends State<_AudioRecordButton> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  int _seconds = 0;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)..repeat();
    _pulseAnimation = Tween(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  void _stopRecording() async {
    _timer?.cancel();
    setState(() => _isRecording = false);
    if (_seconds >= 1) {
      await widget.onRecorded();
    }
  }

  void _cancelRecording() {
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _seconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = _isRecording ? '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}' : null;
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 100) {
          _cancelRecording();
        }
      },
      child: ScaleTransition(
        scale: _isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _isRecording ? AppColors.error : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: _isRecording
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mic_rounded, color: AppColors.onPrimary, size: 22),
                      const SizedBox(width: 4),
                      Text(text ?? '', style: AppTextStyles.labelSm.copyWith(color: AppColors.onPrimary)),
                    ],
                  )
                : Icon(Icons.mic_rounded, color: AppColors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)..repeat();
    _animations = List.generate(3, (i) {
      final start = i * 0.15;
      final end = start + 0.4;
      return Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeInOut)));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value = _animations[i].value;
            final translateY = (value - 0.5) * -8;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Transform.translate(
                offset: Offset(0, translateY),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: AppColors.onSurfaceVariant, borderRadius: BorderRadius.circular(3)),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
