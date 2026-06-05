import 'package:flutter/material.dart';
import 'package:monopolyoligarch/components/playercard.dart';
import 'package:monopolyoligarch/services/database/models.dart';
import '../services/database/database_helper.dart';

class WaitingPage extends StatefulWidget {
  final double width;
  final double height;
  final DatabaseHelper database;
  const WaitingPage({
    super.key,
    required this.width,
    required this.height,
    required this.database,
  });

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  List<Player> playerList = [];

  void loadUserData() {
    widget.database.getAllPlayers().then((userList) {
      for (var user in userList) {
        debugPrint("\n\n\n${user.toMap().toString()}\n\n\n");
      }

      setState(() {
        playerList = userList;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
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
            SizedBox(height: widget.height*0.02,)
          ],
        ),
      ),
    );
  }
}
