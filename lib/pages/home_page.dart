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

  void onSocketDataReceived() {
    final dynamic userData = socketClient.userData.value;
    debugPrint("Socket Data Trigger ${userData.toString()}");

    if (userData == null) return;

    int statusCode = userData[0];
    debugPrint(statusCode.toString());
    switch (statusCode) {
      case 201:
        setState(() {
          playerOrder = userData[1]
              .map<int>((item) => int.parse(item))
              .toList();

          for (var (index, item) in playerOrder.indexed) {
            if (widget.currentPlayer.id == item) {
              widget.currentPlayer.playerTurn = index + 1;
            }
          }

          promptInputData = widget.currentPlayer.playerTurn;
          promptColor = null;
          promptType = PromptType.turnDisplay;
        });
        debugPrint("1: $showPrompt, $promptInputData, $promptColor");
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() => showPrompt = true);
          }
        });
        socketClient.userData.value = null;
        break;

      case 202:
        widget.database
            .getParamofPlayer(int.parse(userData[1][0]), "username")
            .then((username) {
              debugPrint(username.toString());
              if (username == null) {
                widget.database.getAllPlayers().then((users) {
                  debugPrint(users.toString());
                });
              }
              setState(() {
                showPrompt = true;
                promptInputData = [username, userData[1][1], userData[1][2]];
                promptColor = null;
                promptType = PromptType.playerMovement;
              });
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) setState(() => showPrompt = true);
              });
            });
        socketClient.userData.value = null;
        break;
    }
    debugPrint("success");
  }

  @override
  void initState() {
    super.initState();
    socketClient.userData.addListener(onSocketDataReceived);

    if (socketClient.userData.value != null) {
      onSocketDataReceived();
    }
  }

  @override
  void dispose() {
    super.dispose();

    socketClient.userData.removeListener(onSocketDataReceived);
  }

  @override
  Widget build(BuildContext context) {
    void promptFunction() {
      if (playerOrder[0] == widget.currentPlayer.id &&
          promptType == PromptType.turnDisplay) {
        setState(() {
          showPrompt = true;
          promptType = PromptType.rollDice;
          promptInputData = widget.currentPlayer;
        });
      } else {
        setState(() {
          showPrompt = false;
        });
      }
    }

    final theme = Theme.of(context);
    debugPrint("2: $showPrompt, $promptInputData, $promptColor");
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
                  if (promptType == PromptType.playerMovement) {
                    setState(() {
                      showPrompt = false;
                    });
                  }
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
          BoardActionPrompt(
            isVisible: showPrompt,
            width: widget.width,
            color: null,
            onButtonPress: promptFunction,
            inputData: promptInputData,
            promptType: promptType,
            height: widget.height,
            socketClient: socketClient,
          ),
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
