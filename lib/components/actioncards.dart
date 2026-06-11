import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final double width;
  final IconData iconSymbol;
  final String action;
  final VoidCallback actionFunction;
  const ActionCard({
    super.key,
    required this.width,
    required this.iconSymbol,
    required this.action,
    required this.actionFunction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      
      onTap: () {
        actionFunction();
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
            Icon(iconSymbol, color: theme.primaryColor, size: 35,),
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
