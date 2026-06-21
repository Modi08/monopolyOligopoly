import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Create the global locator
final GetIt locator = GetIt.instance;

class GameClient {
  late WebSocketChannel _channel;
  final String gameId;
  final String playerId;
  final VoidCallback onGameStarted;
  final ValueNotifier<dynamic> userData = ValueNotifier(null);
  GameClient({
    required this.gameId, 
    required this.playerId,
    required this.onGameStarted,
  }) {
    final url = 'wss://oligarch-websocket-server-v7xkx4cedq-ez.a.run.app/ws/$gameId/$playerId';
    _channel = WebSocketChannel.connect(Uri.parse(url));
    debugPrint("Socket Connected"); 
    
    _channel.stream.listen(
      (message) {
        final Map<String, dynamic> data = jsonDecode(message);
        _handleServerEvent(data);
      },
      onError: (error) => debugPrint('Socket Error: $error'),
      onDone: () => debugPrint('Socket Disconnected'),
    );
  }

  void _handleServerEvent(Map<String, dynamic> data) {
    final int statusCode = data['statusCode'];

    switch (statusCode) {
      case 201:
        debugPrint("Game Stared: $data");
        userData.value = [statusCode, data["data"].toList()];
        onGameStarted();
        break;
      case 202:
        debugPrint("Player moved: $data");
        userData.value = [statusCode, data["data"].toList()];
        break;
    }
  }

  void startGame() {
    _channel.sink.add(jsonEncode({"action": "startGame"}));
  }

  void sendMessagetoServer(Map<String, dynamic> msg) {
    _channel.sink.add(jsonEncode(msg));
  }

  void leaveGame() {
    _channel.sink.close();
  }
}