import 'package:flutter_test/flutter_test.dart';
import 'package:red_de_trabajo/models/chat_message.dart';

void main() {
  test('parses image messages from chat history and socket events', () {
    final message = ChatMessage.fromJson({
      'id': 'photo-1',
      'senderId': 'sender-1',
      'type': 'image',
      'text': 'http://localhost:3000/uploads/photo.jpg',
      'createdAt': '2026-10-31T12:00:00.000Z',
    }, currentUserId: 'recipient-1');

    expect(message.type, MessageType.image);
    expect(message.text, 'http://localhost:3000/uploads/photo.jpg');
    expect(message.isMe, isFalse);
    expect(message.toJson()['type'], 'image');
  });

  test('parses and serializes uploaded audio message details', () {
    final message = ChatMessage.fromJson({
      'id': 'audio-1',
      'senderId': 'sender-1',
      'type': 'audio',
      'text': 'Nota de voz',
      'audioUrl': 'https://example.com/uploads/audio.m4a',
      'audioDurationSeconds': 8,
      'createdAt': '2026-10-31T12:00:00.000Z',
    }, currentUserId: 'sender-1');

    expect(message.type, MessageType.audio);
    expect(message.isMe, isTrue);
    expect(message.audioUrl, 'https://example.com/uploads/audio.m4a');
    expect(message.audioDurationSeconds, 8);
    expect(message.toJson()['audioUrl'], message.audioUrl);
  });
}
