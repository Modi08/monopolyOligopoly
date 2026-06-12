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
  final VoidCallback onGameStarted; // Callback to trigger UI navigation

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
    final event = data['event'];

    switch (event) {
      case 'gameStarted':
        // This fires for EVERY connected player
        print("Game Stared: $data");
        break;
      // Add other cases here later (e.g., 'player_moved', 'rent_paid')
    }
  }

  // Action for Player 1 to trigger
  void startGame() {
    _channel.sink.add(jsonEncode({"action": "startGame"}));
  }

  void leaveGame() {
    _channel.sink.close();
  }
}