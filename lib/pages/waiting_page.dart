import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monopolyoligarch/components/playercard.dart';
import 'package:monopolyoligarch/services/database/models.dart';
import '../services/database/database_service.dart';

class WaitingPage extends StatefulWidget {
  final double width;
  final double height;
  final DatabaseServicePlayer database;
  final FirebaseFirestore firestoreInstance;
  final int gameId;
  const WaitingPage({
    super.key,
    required this.width,
    required this.height,
    required this.database,
    required this.firestoreInstance,
    required this.gameId,
  });

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  List<Player> playerList = [];
  int count = 0;
  bool gameStarted = false;

  void loadUserData() {
    widget.database.getAllPlayers().then((userList) {
      if (count == 1) {
        for (var user in userList) {
          debugPrint(
            "=============================================================\n${user.toMap().toString()}\n=============================================================",
          );
        }
      }

      setState(() {
        playerList = userList;
        count++;
      });
    });
  }

  void listentoPlayerStream(int gameId) {
    debugPrint(gameId.toString());
    widget.firestoreInstance
        .collection(gameId.toString())
        .doc("players")
        .snapshots()
        .map((DocumentSnapshot snapshot) {
          Map<String, dynamic> rawPlayersSnapshot =
              snapshot.data() as Map<String, dynamic>;

          if (rawPlayersSnapshot.keys.toList().length > playerList.length) {
            List<Player> playersSnapshot = [];
            for (var index in rawPlayersSnapshot.keys.toList()) {
              Player player = Player.fromMap(Map<String, dynamic>.from(rawPlayersSnapshot.values.toList()[int.parse(index)]));
              playersSnapshot.add(player);
            }
            
            setState(() {
              playerList = playersSnapshot;
            });
          }
          if (!gameStarted) {
            listentoPlayerStream(gameId);
          }
        });
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    listentoPlayerStream(widget.gameId);
  }

  @override
  Widget build(BuildContext context) {
    loadUserData();
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
            ElevatedButton(
              style: theme.elevatedButtonTheme.style,
              onPressed: () {
                debugPrint("hello");
              },
              child: Text(
                "Start Game",
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: widget.height * 0.02),
          ],
        ),
      ),
    );
  }
}
