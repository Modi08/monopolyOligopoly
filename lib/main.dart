import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monopolyoligarch/pages/home_page.dart';
import 'package:monopolyoligarch/services/database/models.dart';
import 'constants/theme.dart';
import 'pages/join_game_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'services/database/database_service.dart';
import 'pages/waiting_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // This is the magic lock. It runs silently.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? AndroidDebugProvider()
        : AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode ? AppleDebugProvider() : AppleAppAttestProvider(),
  );

  runApp(const Oligarch());
}

class Oligarch extends StatefulWidget {
  const Oligarch({super.key});

  @override
  State<Oligarch> createState() => _OligarchState();
}

class _OligarchState extends State<Oligarch> {
  final DatabaseServicePlayer database = DatabaseServicePlayer.instance;
  int gameId = 0;
  Player currentPlayer = Player(
    id: 0,
    name: "N.A",
    cash: 5000,
    propertiesOwnershipShares: {},
    propertiesVotershare: {},
    position: 0,
    inJail: false,
    jailTurns: 0,
    activeLoans: {},
    playerTurn: 0,
    isCurrentPlayer: true,
  );

  final firestoreInstance = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'oligarch-firestore-db',
  );

  void setGameId(int value) {
    setState(() {
      gameId = value;
    });
  }

  void setCurrentPlayerData(Player player) {
    setState(() {
      currentPlayer = player;
    });
  }

  @override
  void initState() {
    super.initState();
    database.clearAllPLayers();
    debugPrint("Game started");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oligarch',
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) =>
            // ignore: void_checks
            JoinScreen(
              width: width,
              height: height,
              database: database,
              setGameId: setGameId,
              setCurrentPlayerData: setCurrentPlayerData,
            ),
        '/waitingScreen': (context) => WaitingPage(
          width: width,
          height: height,
          database: database,
          firestoreInstance: firestoreInstance,
          gameId: gameId,
          currentPlayer: currentPlayer,
        ),
        '/HomePage':(context) => HomePage()
      },
    );
  }
}
