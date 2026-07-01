import 'package:flutter/material.dart';
import 'package:monopolyoligarch/services/database/database_service.dart';
import 'package:monopolyoligarch/services/database/models.dart';

class ActionCard extends StatelessWidget {
  final double width;
  final IconData iconSymbol;
  final String action;
  final DatabaseService database;
  final Player currentPlayer;
  final Function(BuildContext, DatabaseService, Player) actionFunction;
  const ActionCard({
    super.key,
    required this.width,
    required this.iconSymbol,
    required this.action,
    required this.database, 
    required this.actionFunction,
    required this.currentPlayer
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        actionFunction(context, database, currentPlayer);
      },
      child: Container(
        height: width * 0.15,
        width: width * 0.15,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          shape: BoxShape.rectangle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconSymbol, color: theme.primaryColor, size: 35),
            Text(
              action,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
