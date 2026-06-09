import 'package:flutter/material.dart';

class AvatarCircleCard extends StatelessWidget {
  final double height;
  final double width;
  final String username;
  final bool isColorPrimary;
  const AvatarCircleCard({
    super.key,
    required this.height,
    required this.width,
    required this.username,
    this.isColorPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      // The radius is half the diameter
      radius: (height * 0.04),
      backgroundColor: isColorPrimary
          ? theme.scaffoldBackgroundColor
          : theme.cardColor,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "${username[0].toUpperCase()}${username[1].toLowerCase()}",
          style: theme.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
