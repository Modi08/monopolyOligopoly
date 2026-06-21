import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monopolyoligarch/components/playercard.dart';
import 'package:monopolyoligarch/services/database/models.dart';
import '../services/database/database_service.dart';
import '../services/socket.dart';

class WaitingPage extends StatefulWidget {
  final double width;
  final double height;
  final DatabaseServicePlayer database;
  final FirebaseFirestore firestoreInstance;
  final int gameId;
  final Player currentPlayer;
  const WaitingPage({
    super.key,
    required this.width,
    required this.height,
    required this.database,
    required this.firestoreInstance,
    required this.gameId,
    required this.currentPlayer,
  });

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  List<Player> playerList = [];
  bool gameStarted = false;

  void loadUserData() {
    widget.database.getAllPlayers().then((userList) {
      for (var user in userList) {
        debugPrint(
          "=============================================================\n${user.toMap().toString()}\n=============================================================",
        );
      }

      setState(() {
        playerList = userList;
      });
    });
  }

  void listentoPlayerStream(int gameId, Player currentPlayer) {
    debugPrint("listening to Player Stream");
    widget.firestoreInstance
        .collection(gameId.toString())
        .doc("players")
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
          if (!snapshot.exists) {
            listentoPlayerStream(gameId, currentPlayer);
            return;
          }

          Map<String, dynamic> rawPlayersSnapshot =
              snapshot.data() as Map<String, dynamic>;

          if (rawPlayersSnapshot.keys.toList().length != playerList.length) {
            List<Player> playersSnapshot = [];
            for (var index in rawPlayersSnapshot.keys.toList()) {
              Map<String, dynamic> rawPlayerData = Map<String, dynamic>.from(
                rawPlayersSnapshot.values.toList()[int.parse(index) - 1],
              );

              rawPlayerData["id"] = int.parse(index);
              rawPlayerData["isCurrentPlayer"] = false;
              Player player = Player.fromMap(rawPlayerData);
              widget.database.insertPlayer(player);
              playersSnapshot.add(player);
            }

            debugPrint(playersSnapshot.length.toString());
            setState(() {
              playerList = playersSnapshot;
            });
            if (!gameStarted) {
              listentoPlayerStream(gameId, currentPlayer);
              return;
            } else {
              debugPrint("Stopped listening to Player Stream");
              return;
            }
          }
        });
    debugPrint("end of function");
    return;
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    listentoPlayerStream(widget.gameId, widget.currentPlayer);

    if (!locator.isRegistered<GameClient>()) {
      final client = GameClient(
        gameId: widget.gameId.toString(),
        playerId: widget.currentPlayer.id.toString(),
        onGameStarted: () {
          setState(() {
            gameStarted = true;
          });
          if (mounted) {
            Navigator.pushReplacementNamed(context, "/HomePage");
          }
        },
      );

      // Register it globally
      locator.registerSingleton<GameClient>(client);
    }
    debugPrint("1: ${locator<GameClient>().userData}");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: widget.height * 0.075),
            Text(
              "Monoploy Game",
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 163, 82, 255),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: widget.height * 0.025),
            Text(
              "Room: ${widget.gameId}",
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 21, 238, 57),
              ),
            ),
            SizedBox(height: widget.height * 0.025),
            Text(
              'Waiting for other host to start...',
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: widget.height * 0.025),
            playerList.isEmpty
                ? CircularProgressIndicator()
                : Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: playerList.length,
                      padding: const EdgeInsets.all(25),

                      itemBuilder: (context, index) {
                        return PlayerCard(
                          height: widget.height,
                          width: widget.width,
                          theme: theme,
                          username: playerList[index].name,
                        );
                      },
                    ),
                  ),

            widget.currentPlayer.id == 1
                ? ElevatedButton(
                    style: theme.elevatedButtonTheme.style,
                    onPressed: () {
                      setState(() {
                        locator<GameClient>().startGame();

                        gameStarted = true;
                      });
                    },
                    child: Text(
                      "Start Game",
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Spacer(),
            SizedBox(height: widget.height * 0.02),
          ],
        ),
      ),
    );
  }
}
