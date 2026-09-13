import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/api_config.dart';
import '../services/session_service.dart';

class SocketService {
  io.Socket? _socket;
  final SessionService _sessionService = SessionService();
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _typingController =
      StreamController.broadcast();
  final StreamController<String> _errorController =
      StreamController.broadcast();
  bool _isConnected = false;
  Future<void>? _connectionFuture;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<String> get errorStream => _errorController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_socket?.connected == true) return;
    if (_connectionFuture != null) return _connectionFuture;
    _connectionFuture = _connectInternal();
    try {
      await _connectionFuture;
    } finally {
      _connectionFuture = null;
    }
  }

  Future<void> _connectInternal() async {

    final session = await _sessionService.getSession();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final token = firebaseUser != null
        ? await firebaseUser.getIdToken(true)
        : session?.token;
    final userId = session?.user?.id;

    if (token == null && userId == null) {
      _errorController.add('No hay token de autenticación');
      return;
    }

    _socket = io.io(
      ApiConfig.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token ?? '', 'userId': userId ?? ''})
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('[SocketService] Connected: ${_socket?.id}');
    });

    _socket!.onDisconnect((reason) {
      _isConnected = false;
      debugPrint('[SocketService] Disconnected: $reason');
    });

    _socket!.onConnectError((error) {
      debugPrint('[SocketService] Connection error: $error');
      _errorController.add('Error de conexión: $error');
    });

    _socket!.onError((error) {
      debugPrint('[SocketService] Error: $error');
      _errorController.add('Error: $error');
    });

    _socket!.on('message', (data) {
      _messageController.add(data as Map<String, dynamic>);
    });

    _socket!.on('typing', (data) {
      _typingController.add(data as Map<String, dynamic>);
    });

    _socket!.on('error', (data) {
      _errorController.add(data?.toString() ?? 'Error desconocido');
    });

    final connected = Completer<void>();
    _socket!.once('connect', (_) {
      if (!connected.isCompleted) connected.complete();
    });
    _socket!.once('connect_error', (error) {
      if (!connected.isCompleted) connected.completeError(Exception('Error de conexión: $error'));
    });
    _socket!.connect();
    await connected.future.timeout(const Duration(seconds: 10));
  }

  void joinConversation(String conversationId) {
    _socket?.emit('join', {'conversationId': conversationId});
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('leave', {'conversationId': conversationId});
  }

  Future<void> sendMessage({
    required String conversationId,
    required String text,
    String type = 'text',
    Map<String, dynamic>? extra,
  }) async {
    await connect();
    if (!_isConnected || _socket == null) {
      throw Exception('El chat no está conectado');
    }
    final data = <String, dynamic>{
      'conversationId': conversationId,
      'text': text,
      'type': type,
    };
    if (extra != null) data.addAll(extra);
    _socket!.emit('message', data);
  }

  void sendTyping(String conversationId) {
    _socket?.emit('typing', {'conversationId': conversationId});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _errorController.close();
  }
}
