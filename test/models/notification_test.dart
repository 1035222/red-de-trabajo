import 'package:flutter_test/flutter_test.dart';
import 'package:red_de_trabajo/models/notification.dart';

void main() {
  test('parses and serializes notification destination metadata', () {
    final notification = AppNotification.fromJson({
      'id': 'notification-1',
      'title': 'Mensaje nuevo',
      'body': 'Te envió una foto',
      'time': '2026-10-31T12:00:00.000Z',
      'read': false,
      'data': {'type': 'chat_message', 'conversationId': 'conversation-1'},
    });

    expect(notification.data, {
      'type': 'chat_message',
      'conversationId': 'conversation-1',
    });
    expect(notification.toJson()['data'], notification.data);
  });

  test('supports older notifications without destination metadata', () {
    final notification = AppNotification.fromJson({
      'id': 'notification-2',
      'title': 'Aviso anterior',
      'body': 'Sin datos de destino',
      'time': '2026-10-30T12:00:00.000Z',
    });

    expect(notification.data, isNull);
  });
}
