import 'package:flutter/material.dart';
import 'package:monopolyoligarch/components/boardPrompt/rolldice.dart';
import 'package:monopolyoligarch/components/boardPrompt/showplayeraquisition.dart';
import 'package:monopolyoligarch/components/boardPrompt/showplayermovment.dart';
import 'package:monopolyoligarch/components/boardPrompt/turndisplay.dart';
import 'package:monopolyoligarch/services/socket.dart';

enum PromptType {
  turnDisplay,
  rollDice,
  playerMovement,
  buyProperty,
  playerBoughtProperty,
}

class BoardActionPrompt extends StatefulWidget {
  final bool isVisible;
  final double width;
  final double height;
  final Color? color;
  final PromptType promptType;
  final VoidCallback onButtonPress;
  final dynamic inputData;
  final GameClient socketClient;

  const BoardActionPrompt({
    super.key,
    required this.isVisible,
    required this.width,
    required this.promptType,
    required this.color,
    required this.onButtonPress,
    required this.inputData,
    required this.height,
    required this.socketClient,
  });

  @override
  State<BoardActionPrompt> createState() => _BoardActionPromptState();
}

class _BoardActionPromptState extends State<BoardActionPrompt> {
  Widget buildPromptContent(ThemeData theme) {
    switch (widget.promptType) {
      case PromptType.turnDisplay:
        return TurnDisplay(
          activeColor: widget.color ?? theme.colorScheme.tertiary,
          playerTurn: widget.inputData,
          onButtonPress: widget.onButtonPress,
        );

      case PromptType.rollDice:
        return RollDice(
          onRollComplete: widget.onButtonPress,
          height: widget.height,
          currentPlayer: widget.inputData,
          socketClient: widget.socketClient,
        );

      case PromptType.playerMovement:
        return ShowPlayerMovment(
          height: widget.height,
          username: widget.inputData[0],
          oldPosition: widget.inputData[2],
          newPosition: widget.inputData[1],
        );

      case PromptType.playerBoughtProperty:
        return ShowPlayerAcquisition(
          username: widget.inputData[0],
          propertyId: widget.inputData[1],
          height: widget.height,
        );

      default:
        throw Exception(
          "${widget.promptType} is not supposed top tigger this function",
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    final activeColor = widget.color ?? theme.colorScheme.tertiary;

    final double circleDiameter = widget.width;
    final double circleHeight = circleDiameter / 2;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      top: widget.isVisible ? statusBarHeight + 20 : -(circleHeight + 50),
      left: (widget.width - circleDiameter) / 2,

      child: Material(
        color: Colors.transparent,
        elevation: 10,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(circleDiameter),
        ),
        child: Container(
          width: circleDiameter,
          height: circleHeight,
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border.all(color: activeColor, width: 3),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(circleDiameter),
            ),
          ),
          child: buildPromptContent(theme),
        ),
      ),
    );
  }
}
