import 'package:flutter/material.dart';

class TurnDisplay extends StatelessWidget {
  final Color activeColor;
  final int playerTurn;
  final VoidCallback onButtonPress;
  const TurnDisplay({
    super.key,
    required this.activeColor,
    required this.playerTurn,
    required this.onButtonPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Icon(Icons.sync, size: 40, color: activeColor),
        const SizedBox(height: 4),
        Text(
          "Your turn is the $playerTurn",
          style: theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: activeColor,
          ),
        ),
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: onButtonPress,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.pressed)) {
                return theme
                    .colorScheme
                    .inversePrimary; // Brighter color on hover
              }
              return activeColor;
            }),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          child: Text(
            "Continue",
            style: theme.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}
