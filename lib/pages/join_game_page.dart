import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../services/snackbar.dart';
import '../services/database/models.dart';
import 'dart:convert';
import '../services/database/database_service.dart';

Widget _buildTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  bool obscureText = false,
  int? maxLength,
}) {
  return TextField(
    maxLength: maxLength,
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.green),
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
    ),
  );
}

Future<void> joinGame(
  String gameId,
  String username,
  FirebaseFunctions functions,
  context,
  DatabaseServicePlayer database,
  void Function(int) setGameId,
  void Function(Player) setCurrentPlayerData,
) async {
  try {
    final callable = functions.httpsCallable('joinGameFunction');
    final response = await callable.call({
      'gameId': gameId,
      'username': username,
    });

    debugPrint('Function response: ${response.data}');

    showSnackbar(
      context,
      response.data['message'],
      response.data['statusCode'] != 200,
    );

    List<dynamic> playersData = response.data['players'] as List<dynamic>;

    for (var player in playersData) {
      Map<String, dynamic> playerMap = jsonDecode(jsonEncode(player));
      //debugPrint('Player data: $playerMap');
      await database.insertPlayer(Player.fromMap(playerMap));
    }

    setGameId(int.parse(gameId));
    Player player = Player(
      id: response.data['newPlayerId'] as int,
      name: username,
      cash: 5000,
      netWorth: 5000,
      propertiesOwnershipShares: {},
      propertiesVotershare: {},
      position: 0,
      inJail: false,
      jailTurns: 0,
      activeLoans: {},
      playerTurn: 0,
      isCurrentPlayer: true,
    );

    setCurrentPlayerData(player);
    await database.insertPlayer(player);

    Navigator.pushNamed(context, '/waitingScreen');
  } catch (e) {
    debugPrint('Error calling function: $e');
  }
}

Future<void> createGame(
  String username,
  FirebaseFunctions functions,
  context,
  DatabaseServicePlayer database,
  void Function(int) setGameId,
  void Function(Player) setCurrentPlayerData,
) async {
  try {
    final callable = functions.httpsCallable('createGameFunction');
    final response = await callable.call({'username': username});

    //debugPrint('Function response: ${response.data}');
    showSnackbar(
      context,
      response.data['message'],
      response.data['statusCode'] != 200,
    );

    setGameId(response.data["gameId"]);

    Player player = Player(
      id: 1,
      name: username,
      cash: 5000,
      netWorth: 5000,
      propertiesOwnershipShares: {},
      propertiesVotershare: {},
      position: 0,
      inJail: false,
      jailTurns: 0,
      activeLoans: {},
      playerTurn: 0,
      isCurrentPlayer: true,
    );
    setCurrentPlayerData(player);

    await database.insertPlayer(player);

    Navigator.pushNamed(context, "/waitingScreen");
  } catch (e) {
    debugPrint('Error calling function: $e');
  }
}

class JoinScreen extends StatefulWidget {
  final double width;
  final double height;
  final DatabaseServicePlayer database;
  final void Function(int) setGameId;
  final void Function(Player) setCurrentPlayerData;
  const JoinScreen({
    super.key,
    required this.width,
    required this.height,
    required this.database,
    required this.setGameId,
    required this.setCurrentPlayerData,
  });

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final roomCodeController = TextEditingController();
  final usernameController = TextEditingController();
  final functions = FirebaseFunctions.instanceFor(region: 'europe-west4');
  bool isJoinGamepage = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Oligarch',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge,
              ),
              SizedBox(height: widget.height * 0.02),
              Text(
                'The Ultimate Monopoly Experience',
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(height: widget.height * 0.035),
              Container(
                width: widget.width * 0.6,
                height: widget.height * 0.06,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Row(
                    spacing: widget.width * 0.05,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isJoinGamepage = true;
                          });
                        },
                        child: Container(
                          width: widget.width * 0.25,
                          height: widget.height * 0.06,
                          decoration: BoxDecoration(
                            color: isJoinGamepage
                                ? theme.colorScheme.tertiary
                                : theme.scaffoldBackgroundColor,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.onSurface,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Join Game',
                              style: theme.textTheme.bodyLarge!.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isJoinGamepage = false;
                          });
                        },
                        child: Container(
                          width: widget.width * 0.3,
                          height: widget.height * 0.06,
                          decoration: BoxDecoration(
                            color: isJoinGamepage
                                ? theme.scaffoldBackgroundColor
                                : theme.colorScheme.tertiary,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.onSurface,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Create Game',
                              style: theme.textTheme.bodyLarge!.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: widget.height * 0.05),
              isJoinGamepage
                  ? _buildTextField(
                      controller: roomCodeController,
                      hintText: 'Enter Game Code',
                      icon: Icons.vpn_key,
                      maxLength: 5,
                    )
                  : SizedBox.shrink(),
              SizedBox(height: widget.height * 0.025),
              _buildTextField(
                controller: usernameController,
                hintText: 'Enter Your Username',
                icon: Icons.person,
                maxLength: 10,
              ),
              SizedBox(height: widget.height * 0.1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: theme.elevatedButtonTheme.style,
                    onPressed: () {
                      debugPrint(
                        'Game code: ${roomCodeController.text}, Username: ${usernameController.text}',
                      );
                      if (isJoinGamepage) {
                        if (roomCodeController.text.isEmpty ||
                            usernameController.text.isEmpty) {
                          showSnackbar(
                            context,
                            'Please enter both game code and username',
                            true,
                          );
                          return;
                        }
                        joinGame(
                          roomCodeController.text,
                          usernameController.text,
                          functions,
                          context,
                          widget.database,
                          widget.setGameId,
                          widget.setCurrentPlayerData,
                        );
                      } else {
                        if (usernameController.text.isEmpty) {
                          showSnackbar(
                            context,
                            'Please enter a username',
                            true,
                          );
                          return;
                        }
                        createGame(
                          usernameController.text,
                          functions,
                          context,
                          widget.database,
                          widget.setGameId,
                          widget.setCurrentPlayerData,
                        );
                      }
                    },
                    child: Text(
                      isJoinGamepage ? 'Join Game' : 'Create Game',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
