import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:monopolyoligarch/services/database/models.dart';
import 'package:monopolyoligarch/services/socket.dart';

class RollDice extends StatefulWidget {
  final VoidCallback onRollComplete;
  final double height;
  final Player? currentPlayer;
  final GameClient socketClient;

  const RollDice({
    super.key,
    required this.onRollComplete,
    required this.height,
    required this.socketClient,
    this.currentPlayer,
  });

  @override
  State<RollDice> createState() => _RollDiceState();
}

class _RollDiceState extends State<RollDice> {
  int currentFace1 = 1;
  double turns = 0.0;
  int currentFace2 = 1;

  bool isRolling = false;
  bool hasRolled = false;

  IconData _getDiceIcon(int face) {
    switch (face) {
      case 1:
        return Icons.looks_one_rounded;
      case 2:
        return Icons.looks_two_rounded;
      case 3:
        return Icons.looks_3_rounded;
      case 4:
        return Icons.looks_4_rounded;
      case 5:
        return Icons.looks_5_rounded;
      case 6:
        return Icons.looks_6_rounded;
      default:
        return Icons.casino_rounded;
    }
  }

  void _startRoll() {
    if (isRolling) return;

    setState(() {
      isRolling = true;
      turns += 2.0;
    });

    int ticks = 0;
    Timer.periodic(const Duration(milliseconds: 80), (timer) {
      setState(() {
        currentFace1 = Random().nextInt(6) + 1;
        currentFace2 = Random().nextInt(6) + 1;
      });

      ticks++;
      if (ticks >= 12) {
        timer.cancel();
        setState(() {
          isRolling = false;
          hasRolled = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: widget.height * 0.01,
      children: [
        Text(
          "Its your turn to roll the dice",
          style: theme.textTheme.bodyLarge,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedRotation(
              turns: turns,
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutCirc,
              child: Icon(
                _getDiceIcon(currentFace1),
                size: 80,
                color: theme.colorScheme.onSurface,
              ),
            ),
            AnimatedRotation(
              turns: turns,
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutCirc,
              child: Icon(
                _getDiceIcon(currentFace2),
                size: 80,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),

        !hasRolled
            ? ElevatedButton(
                onPressed: isRolling ? null : _startRoll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface,
                  foregroundColor: theme.colorScheme.onTertiary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  isRolling ? "Rolling..." : "Roll Dice",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: () {
                  widget.socketClient.sendMessagetoServer({
                    "oldPosition": widget.currentPlayer!.position,
                    "newPosition":
                        widget.currentPlayer!.position +
                        currentFace1 +
                        currentFace2,
                  }, "rolledDice");
                  widget.currentPlayer!.position =
                      widget.currentPlayer!.position +
                      currentFace1 +
                      currentFace2;

                  widget.onRollComplete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface,
                  foregroundColor: theme.colorScheme.onTertiary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  "Continue",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ],
    );
  }
}
