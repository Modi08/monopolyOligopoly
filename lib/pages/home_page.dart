import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monopolyoligarch/components/boardPrompt/buyproperty.dart';
import 'package:monopolyoligarch/components/board_action_prompt.dart';
import 'package:monopolyoligarch/constants/monoployboard.dart';
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
  final int gameId;
  const HomePage({
    super.key,
    required this.width,
    required this.height,
    required this.currentPlayer,
    required this.firestoreInstance,
    required this.database,
    required this.gameId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedScreenIndex = 1;
  GameClient socketClient = locator<GameClient>();

  List<int> playerOrder = [];
  int turn = 0;

  bool isScreenIgnored = false;
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
            debugPrint("Stopped listening to Player Stream");
            return;
          }

          Map<String, dynamic> rawPlayersSnapshot =
              snapshot.data() as Map<String, dynamic>;

          for (var index in rawPlayersSnapshot.keys.toList()) {
            Map<String, dynamic> rawPlayerData = Map<String, dynamic>.from(
              rawPlayersSnapshot.values.toList()[int.parse(index) - 1],
            );

            rawPlayerData["id"] = int.parse(index);
            rawPlayerData["isCurrentPlayer"] =
                int.parse(index) == currentPlayer.id;
            widget.database.insertPlayer(Player.fromMap(rawPlayerData));
          }

          listentoPlayerStream(gameId, currentPlayer);
          debugPrint("Stopped listening to Player Stream");
          return;
        });
    return;
  }

  void listentoPropertyStream(int gameId) {
    debugPrint("listening to Property Stream");
    widget.firestoreInstance
        .collection(gameId.toString())
        .doc("properties")
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
          if (!snapshot.exists) {
            listentoPropertyStream(gameId);
            debugPrint("Stopped listening to Property Stream");
            return;
          }

          Map<String, dynamic> rawPropertiesSnapshot =
              snapshot.data() as Map<String, dynamic>;

          for (var index in rawPropertiesSnapshot.keys.toList()) {
            Map<String, dynamic> rawPropertyData = Map<String, dynamic>.from(
              rawPropertiesSnapshot.values.toList()[int.parse(index) - 1],
            );

            widget.database.insertProperty(Property.fromMap(rawPropertyData));
          }

          listentoPropertyStream(gameId);
          debugPrint("Stopped listening to Property Stream");
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
            setState(() {
              showPrompt = true;
              isScreenIgnored = false;
            });
          }
        });
        socketClient.userData.value = null;
        break;

      case 202:
        if (int.parse(userData[1][0]) != widget.currentPlayer.id) {
          widget.database
              .getParamofPlayer(int.parse(userData[1][0]), "username")
              .then((username) {
                debugPrint(username.toString());
                setState(() {
                  showPrompt = true;
                  promptInputData = [username, userData[1][1], userData[1][2]];
                  promptColor = null;
                  promptType = PromptType.playerMovement;
                });
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    setState(() {
                      showPrompt = true;
                      isScreenIgnored = false;
                    });
                  }
                });
              });
        }
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
    //listentoPlayerStream(widget.gameId, widget.currentPlayer);
  }

  @override
  void dispose() {
    super.dispose();

    socketClient.userData.removeListener(onSocketDataReceived);
  }

  @override
  Widget build(BuildContext context) {
    void promptFunction() {
      debugPrint(
        "Propmt function: $promptType, ${playerOrder[turn]} == ${widget.currentPlayer.id}",
      );
      if (playerOrder[0] == widget.currentPlayer.id &&
          promptType == PromptType.turnDisplay) {
        setState(() {
          showPrompt = true;
          isScreenIgnored = false;
          promptType = PromptType.rollDice;
          promptInputData = widget.currentPlayer;
        });
      } else if (promptType == PromptType.rollDice &&
          playerOrder[turn] == widget.currentPlayer.id) {
        setState(() {
          promptType = PromptType.buyProperty;
          showPrompt = false;
          isScreenIgnored = false;
        });
      } else {
        setState(() {
          showPrompt = false;
          isScreenIgnored = true;
        });
      }
    }

    final theme = Theme.of(context);
    debugPrint(
      "2: $showPrompt, $promptInputData, $promptColor, ${promptType == PromptType.buyProperty}, $isScreenIgnored",
    );
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          pages[selectedScreenIndex],
          IgnorePointer(
            ignoring: isScreenIgnored,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: showPrompt || promptType == PromptType.buyProperty ? 1.0 : 0.0,
              child: GestureDetector(
                onTap: () {
                  debugPrint("clicked");
                  if (promptType == PromptType.playerMovement) {
                    setState(() {
                      showPrompt = false;
                      isScreenIgnored = true;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.7),
                  child: promptType == PromptType.buyProperty
                      ? ViewSquareCard(
                          height: widget.height,
                          width: widget.width,
                          square: properties[widget.currentPlayer.position],
                        )
                      : const SizedBox(),
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
