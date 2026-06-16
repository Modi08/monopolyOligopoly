import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:monopolyoligarch/constants/monoployboard.dart';

class ShowPlayerMovment extends StatelessWidget {
  final double height;
  final String username;
  final int oldPosition;
  final int newPosition;
  const ShowPlayerMovment({
    super.key,
    required this.height,
    required this.username,
    required this.oldPosition,
    required this.newPosition,
  });

  int changeinPostion(int oldPos, int newPos) {
    if (newPos < oldPos) {
      return 39 - oldPos + newPos + 1;
    } else {
      return newPos - oldPos;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: height * 0.01,
      children: [
        Text.rich(
          TextSpan(
            style: theme.textTheme.bodyLarge,
            children: <TextSpan>[
              TextSpan(text: "Player "),
              TextSpan(
                text: username,
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: theme.colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: " just rolled dice and got "),
              TextSpan(
                text: (changeinPostion(oldPosition, newPosition)).toString(),
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: theme.colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Text(properties[oldPosition].name, style: theme.textTheme.displayLarge),
        Transform.rotate(
          // Rotates the arrow 45 degrees downwards
          angle: math.pi / 4,
          child: const Icon(
            Icons.arrow_forward_rounded,
            size: 50,
            color: Colors.blue,
          ),
        ),
        Text(properties[newPosition].name, style: theme.textTheme.displayLarge),
      ],
    );
  }
}
