import 'package:flutter/foundation.dart';

@immutable
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final bool read;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      time: DateTime.parse(json['time'] as String),
      read: json['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'time': time.toIso8601String(),
        'read': read,
      };
}
