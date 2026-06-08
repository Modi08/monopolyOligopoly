import 'package:flutter/material.dart';
import 'package:monopolyoligarch/pages/screens/accountActions.dart';
import 'package:monopolyoligarch/pages/screens/dashboard.dart';
import 'package:monopolyoligarch/pages/screens/portfolio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedScreenIndex = 1;
  List<Widget> pages = [Portfolio(), Dashboard(), AccountActions()];

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
