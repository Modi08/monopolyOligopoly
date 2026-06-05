import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'constants/theme.dart';
import 'pages/join_game_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
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
  final int gameIds = 0;

  @override
  void initState() {
    super.initState();
    database.getAllPlayers().then((players) {});
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
            JoinScreen(width: width, height: height, database: database),
        '/waitingScreen': (context) => WaitingPage(width: width, height: height, database: database),
      },
    );
  }
}
