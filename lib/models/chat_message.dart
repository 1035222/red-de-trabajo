import 'package:flutter/foundation.dart';

enum MessageStatus { sending, sent, delivered, read }

enum MessageType { text, location, audio }

@immutable
class ChatMessage {
  final String id;
  final MessageType type;
  final String text;
  final bool isMe;
  final DateTime time;
  final MessageStatus status;
  final double? latitude;
  final double? longitude;
  final String? address;
  final int? audioDurationSeconds;
  final String? audioUrl;

  const ChatMessage({
    required this.id,
    required this.type,
    required this.text,
    required this.isMe,
    required this.time,
    this.status = MessageStatus.sent,
    this.latitude,
    this.longitude,
    this.address,
    this.audioDurationSeconds,
    this.audioUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      type: MessageType.values.firstWhere(
        (t) => t.name == (json['type'] as String? ?? 'text'),
        orElse: () => MessageType.text,
      ),
      text: json['text'] as String,
      isMe: json['isMe'] as bool,
      time: DateTime.parse(json['time'] as String),
      status: MessageStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      audioDurationSeconds: json['audioDurationSeconds'] as int?,
      audioUrl: json['audioUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'text': text,
        'isMe': isMe,
        'time': time.toIso8601String(),
        'status': status.name,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (address != null) 'address': address,
        if (audioDurationSeconds != null) 'audioDurationSeconds': audioDurationSeconds,
        if (audioUrl != null) 'audioUrl': audioUrl,
      };

  ChatMessage copyWith({
    MessageStatus? status,
    MessageType? type,
    String? text,
    bool? isMe,
    DateTime? time,
    double? latitude,
    double? longitude,
    String? address,
    int? audioDurationSeconds,
    String? audioUrl,
  }) {
    return ChatMessage(
      id: id,
      type: type ?? this.type,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      time: time ?? this.time,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      audioDurationSeconds: audioDurationSeconds ?? this.audioDurationSeconds,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}
