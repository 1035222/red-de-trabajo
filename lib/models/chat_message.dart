import 'package:flutter/foundation.dart';

@immutable
class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime time;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      isMe: json['isMe'] as bool,
      time: DateTime.parse(json['time'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isMe': isMe,
        'time': time.toIso8601String(),
      };
}
