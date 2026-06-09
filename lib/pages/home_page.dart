import 'package:flutter/material.dart';
import 'package:monopolyoligarch/pages/screens/accountActions.dart';
import 'package:monopolyoligarch/pages/screens/dashboard.dart';
import 'package:monopolyoligarch/pages/screens/portfolio.dart';
import 'package:monopolyoligarch/services/database/models.dart';

class HomePage extends StatefulWidget {
  final double height;
  final double width;
  final Player currentPlayer;
  const HomePage({super.key, required this.width, required this.height, required this.currentPlayer});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedScreenIndex = 1;
  List<Widget> get pages => [
    const Portfolio(),
    Dashboard(height: widget.height, width: widget.width, currentPlayer: widget.currentPlayer,),
    const AccountActions(),
  ];

  void onScreenSelected(int index) {
    setState(() {
      selectedScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: pages[selectedScreenIndex],

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
