import 'package:flutter/material.dart';

class PlayerCard extends StatelessWidget {
  final double width;
  final double height;
  final ThemeData theme;
  final String username;
  const PlayerCard({
    super.key,
    required this.height,
    required this.width,
    required this.theme,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * 0.4,
      height: height * 0.15,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(flex: 1),
            Container(
              height: height * 0.075,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                "${username[0].toUpperCase()}${username[1].toLowerCase()}",
                style: theme.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Spacer(flex: 2),
            Text(
              username,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
