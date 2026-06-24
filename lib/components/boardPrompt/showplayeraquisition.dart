import 'package:flutter/material.dart';
import 'package:monopolyoligarch/components/property_title.dart';
import 'package:monopolyoligarch/components/sold_stamp.dart';
import 'package:monopolyoligarch/constants/monoployboard.dart';
import 'dart:math' as math;

class ShowPlayerAcquisition extends StatelessWidget {
  final String username;
  final int propertyId;
  final double height;

  const ShowPlayerAcquisition({
    super.key,
    required this.username,
    required this.propertyId,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
              TextSpan(text: " just bought the property "),
              TextSpan(
                text: properties[propertyId].name,
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: theme.colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: height * 0.05),
        Stack(
          alignment: Alignment.center,
          children: [
            PropertyTitle(propertyId: propertyId, theme: theme),

            Transform.rotate(
              angle: -math.pi / 5.1,
              child: const SoldStamp(scaleFactor: 0.25),
            ),
          ],
        ),
      ],
    );
  }
}
