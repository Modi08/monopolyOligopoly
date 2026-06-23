import 'package:flutter/material.dart';
import 'package:monopolyoligarch/components/boardPrompt/electricandhascompany.dart';
import 'package:monopolyoligarch/components/property_cards.dart';
import 'package:monopolyoligarch/services/database/models.dart';

class BuyProperty extends StatelessWidget {
  final double height;
  final double width;
  final Square square;
  final bool isProperty;

  const BuyProperty({
    super.key,
    required this.height,
    required this.width,
    required this.square,
    required this.isProperty,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      spacing: height * 0.01,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        square.type != 5
            ? PropertyCard(property: square as Property, width: width * 0.6)
            : UtilityCard(property: square as Property),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                debugPrint("buy");
              },
              style: theme.elevatedButtonTheme.style,
              child: Text(
                "Buy Property for ${(square as Property).price}",
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
