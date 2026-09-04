import 'package:flutter/foundation.dart';

@immutable
class Message {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final String avatarUrl;
  final bool unread;

  const Message({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.avatarUrl = '',
    this.unread = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      name: json['name'] as String,
      lastMessage: json['lastMessage'] as String,
      time: json['time'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      unread: json['unread'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lastMessage': lastMessage,
        'time': time,
        'avatarUrl': avatarUrl,
        'unread': unread,
      };
}
