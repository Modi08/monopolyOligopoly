import 'package:flutter/material.dart';
import 'package:monopolyoligarch/components/avatarcirclecard.dart';

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
            AvatarCircleCard(height: height, width: width, username: username, isColorPrimary: true,),
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
