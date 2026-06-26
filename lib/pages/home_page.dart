import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monopolyoligarch/components/boardPrompt/viewsquarecard.dart';
import 'package:monopolyoligarch/components/board_action_prompt.dart';
import 'package:monopolyoligarch/constants/monoployboard.dart';
import 'package:monopolyoligarch/pages/screens/accountActions.dart';
import 'package:monopolyoligarch/pages/screens/dashboard.dart';
import 'package:monopolyoligarch/pages/screens/portfolio.dart';
import 'package:monopolyoligarch/services/database/database_service.dart';
import 'package:monopolyoligarch/services/database/models.dart';
import 'package:monopolyoligarch/services/snackbar.dart';
import 'package:monopolyoligarch/services/socket.dart';

class HomePage extends StatefulWidget {
  final double height;
  final double width;
  final Player currentPlayer;
  final FirebaseFirestore firestoreInstance;
  final DatabaseService database;
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

  Map<String, dynamic> gameDetails = {"playerOrder": [], "turn": 0, "cashPool": 0};

  bool isScreenIgnored = true;
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
            debugPrint("Stopped listening to Player Stream");
            return;
          }

          Map<String, dynamic> rawPlayersSnapshot =
              snapshot.data() as Map<String, dynamic>;

          debugPrint(rawPlayersSnapshot.toString());

          for (var index in rawPlayersSnapshot.keys.toList()) {
            Map<String, dynamic> rawPlayerData = Map<String, dynamic>.from(
              rawPlayersSnapshot.values.toList()[int.parse(index) - 1],
            );

            rawPlayerData["id"] = int.parse(index);
            rawPlayerData["isCurrentPlayer"] =
                int.parse(index) == currentPlayer.id;
            widget.database.insertPlayer(Player.fromMap(rawPlayerData));
          }

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

          debugPrint("Stopped listening to Property Stream");
          return;
        });
    return;
  }

  void onSocketDataReceived() {
    debugPrint("Socket Data Trigger ${socketClient.userData.value.toString()}");

    if (socketClient.userData.value == null) return;

    final int statusCode = socketClient.userData.value[0];
    final dynamic userData = socketClient.userData.value[1];

    debugPrint("page: $statusCode");

    switch (statusCode) {
      case 201:
        setState(() {
          gameDetails["playerOrder"] = userData.map<int>((item) => int.parse(item)).toList();

          for (var entry in (gameDetails["playerOrder"] as List).asMap().entries) {
            int index = entry.key;
            int item = entry.value;

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
        if (int.parse(userData[0]) != widget.currentPlayer.id) {
          widget.database
              .getParamofPlayer(int.parse(userData[0]), "username")
              .then((username) {
                setState(() {
                  promptInputData = [username, userData[1], userData[2]];
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

      case 203:
        if (userData[0] != widget.currentPlayer.id) {
          widget.database.getParamofPlayer(userData[0], "username").then((
            username,
          ) {
            setState(() {
              promptInputData = [username, userData[1]];
              promptColor = null;
              promptType = PromptType.playerBoughtProperty;
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
        } else {
          showSnackbar(
            context,
            "Successfully bought ${properties[userData[1]].name}",
            false,
          );
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
    listentoPlayerStream(widget.gameId, widget.currentPlayer);
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
        "Propmt function: $promptType, ${gameDetails["playerOrder"][gameDetails["turn"]]} == ${widget.currentPlayer.id}",
      );
      if (gameDetails["playerOrder"][0] == widget.currentPlayer.id &&
          promptType == PromptType.turnDisplay) {
        setState(() {
          showPrompt = true;
          isScreenIgnored = false;
          promptType = PromptType.rollDice;
          promptInputData = widget.currentPlayer;
        });
      } else if (promptType == PromptType.rollDice &&
          gameDetails["playerOrder"][gameDetails["turn"]] == widget.currentPlayer.id) {
        setState(() {
          promptType = PromptType.buyProperty;
          showPrompt = false;
          isScreenIgnored = false;
        });
      } else {
        setState(() {
          showPrompt = false;
          isScreenIgnored = true;
          promptType = PromptType.none;
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
              opacity: showPrompt || promptType == PromptType.buyProperty
                  ? 1.0
                  : 0.0,
              child: GestureDetector(
                onTap: () {
                  debugPrint("clicked");
                  if (promptType == PromptType.playerMovement ||
                      promptType == PromptType.playerBoughtProperty) {
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
                          socketClient: socketClient,
                          database: widget.database,
                          currentPlayer: widget.currentPlayer,
                          onFinish: promptFunction,
                          gameDetails: gameDetails,
                        )
                      : const SizedBox(),
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
