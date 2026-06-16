import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monopolyoligarch/components/board_action_prompt.dart';
import 'package:monopolyoligarch/pages/screens/accountActions.dart';
import 'package:monopolyoligarch/pages/screens/dashboard.dart';
import 'package:monopolyoligarch/pages/screens/portfolio.dart';
import 'package:monopolyoligarch/services/database/database_service.dart';
import 'package:monopolyoligarch/services/database/models.dart';
import 'package:monopolyoligarch/services/socket.dart';

class HomePage extends StatefulWidget {
  final double height;
  final double width;
  final Player currentPlayer;
  final FirebaseFirestore firestoreInstance;
  final DatabaseServicePlayer database;
  const HomePage({
    super.key,
    required this.width,
    required this.height,
    required this.currentPlayer,
    required this.firestoreInstance,
    required this.database,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedScreenIndex = 1;
  GameClient socketClient = locator<GameClient>();

  List<int> playerOrder = [];

  bool showPrompt = false;
  dynamic promptInputData = 0;
  Color? promptColor;
  PromptType promptType = PromptType.turnDisplay;

  List<Widget> get pages => [
    const Portfolio(),
    Dashboard(
      height: widget.height,
      width: widget.width,
      currentPlayer: widget.currentPlayer,
    ),
    const AccountActions(),
  ];

  void onScreenSelected(int index) {
    setState(() {
      selectedScreenIndex = index;
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

          List<Player> playersSnapshot = [];

          for (var index in rawPlayersSnapshot.keys.toList()) {
            Map<String, dynamic> rawPlayerData = Map<String, dynamic>.from(
              rawPlayersSnapshot.values.toList()[int.parse(index) - 1],
            );

            rawPlayerData["id"] = int.parse(index);
            rawPlayerData["isCurrentPlayer"] = false;
            Player player = Player.fromMap(rawPlayerData);
            playersSnapshot.add(player);
          }

          listentoPlayerStream(gameId, currentPlayer);
          return;
        });
    return;
  }

  @override
  Widget build(BuildContext context) {
    void promptFunction() {
      setState(() {
        showPrompt = false;
      });
    }

    if (playerOrder.isEmpty) {
    } else if (playerOrder[0] == widget.currentPlayer.id &&
        promptType == PromptType.turnDisplay) {
      setState(() {
        showPrompt = true;
        promptType = PromptType.rollDice;
        promptInputData = [true, widget.currentPlayer];
      });
    }

    final theme = Theme.of(context);

    if (socketClient.userData != null) {
      int statusCode = socketClient.userData[0];
      debugPrint(statusCode.toString());
      switch (statusCode) {
        case 201:
          setState(() {
            playerOrder = socketClient.userData[1]
                .map<int>((item) => int.parse(item))
                .toList();

            for (var (index, item) in playerOrder.indexed) {
              if (widget.currentPlayer.id == item) {
                widget.currentPlayer.position = index + 1;
              }
            }
            showPrompt = true;
            promptInputData = playerOrder;
            promptColor = null;
            socketClient.userData = null;
          });

        case 202:
          widget.database
              .getParamofPlayer(socketClient.userData[1][0], "username")
              .then((username) {
                setState(() {
                  showPrompt = true;
                  promptInputData = [
                    false,
                    [
                      username,
                      socketClient.userData[1][1],
                      socketClient.userData[1][2],
                    ],
                  ];
                  promptColor = null;
                  promptType = PromptType.rollDice;

                  socketClient.userData = null;
                });
              });
      }
      debugPrint("success");
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          pages[selectedScreenIndex],
          IgnorePointer(
            ignoring: !showPrompt,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: showPrompt ? 1.0 : 0.0,
              child: GestureDetector(
                onTap: () {
                  debugPrint("clicked");
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(
                    0.7,
                  ), // Dims the background beautifully
                ),
              ),
            ),
          ),
          showPrompt
              ? BoardActionPrompt(
                  isVisible: showPrompt,
                  width: widget.width,
                  color: null,
                  onButtonPress: promptFunction,
                  inputData: promptInputData,
                  promptType: promptType,
                  height: widget.height,
                  socketClient: socketClient,
                )
              : SizedBox(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedScreenIndex,
        onTap: onScreenSelected,

        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.tertiary,
        unselectedItemColor: theme.colorScheme.onPrimary,
        backgroundColor: theme.cardColor,

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city_rounded),
            label: "Porfolio",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Dashboard"),
          BottomNavigationBarItem(
            icon: Icon(Icons.feed_sharp),
            label: "Hot Feed",
          ),
        ],
      ),
    );
  }
}
