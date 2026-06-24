import 'package:monopolyoligarch/constants/monoployboard.dart';
import 'package:monopolyoligarch/services/database/database_service.dart';
import 'package:monopolyoligarch/services/database/models.dart';
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
  final DatabaseService database;
  final ValueNotifier<dynamic> userData = ValueNotifier(null);
  GameClient({
    required this.gameId,
    required this.playerId,
    required this.onGameStarted,
    required this.database,
  }) {
    final url =
        'wss://oligarch-websocket-server-v7xkx4cedq-ez.a.run.app/ws/$gameId/$playerId';
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
        database.updatePlayerParam(
          int.parse(data["data"].toList()[1][0]),
          "position",
          int.parse(data["data"].toList()[1][1]),
        );
        userData.value = [statusCode, data["data"].toList()];
        break;
      
      case 203:
        debugPrint("Property Bought: $data");
        
        userData.value = [statusCode, data["data"].toList()];

        int playerId = data["data"].toList()[0];
        int propertyId = data["data"].toList()[1];
        Map<String, dynamic> boughtProperty = properties[propertyId].toMap();
        
        boughtProperty["ownershipShares"] = {playerId: 100};
        boughtProperty["voterShares"] = {playerId: 100};

        database.insertProperty(Property.fromMap(boughtProperty));
        database.updatePlayerParam(playerId, "propertiesOwnershipShares", {
          playerId: 100,
        });
        database.updatePlayerParam(playerId, "propertiesVoterShares", {
          playerId: 100,
        });
        database.getParamofPlayer(playerId, "cash").then((cash) {
          database.updatePlayerParam(
            playerId,
            "cash",
            cash - int.parse(boughtProperty["price"]),
          );
        });
        break;
    }
  }

  void startGame() {
    _channel.sink.add(jsonEncode({"action": "startGame"}));
  }

  void sendMessagetoServer(Map<String, dynamic> msg, String action) {
    msg["action"] = action;
    _channel.sink.add(jsonEncode(msg));
  }

  void leaveGame() {
    _channel.sink.close();
  }
}
