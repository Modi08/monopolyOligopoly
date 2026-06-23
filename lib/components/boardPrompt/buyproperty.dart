import 'package:flutter/material.dart';
import 'package:monopolyoligarch/components/squareCards/corner_tax_card.dart';
import 'package:monopolyoligarch/components/squareCards/electricandhascompany.dart';
import 'package:monopolyoligarch/components/squareCards/event_card.dart';
import 'package:monopolyoligarch/components/squareCards/property_cards.dart';
import 'package:monopolyoligarch/services/database/models.dart';

class ViewSquareCard extends StatelessWidget {
  final double height;
  final double width;
  final Square square;

  const ViewSquareCard({
    super.key,
    required this.height,
    required this.width,
    required this.square,
  });

  Widget buildBoardSquareDisplay(Square currentSquare) {
    debugPrint("square type: ${currentSquare.type}");
    if (currentSquare is Property) {
      if (currentSquare.type == 1) {
        return PropertyCard(
          property: currentSquare,
          width: width*0.6,
          isProperty: true,
        );
      } else if (currentSquare.type == 5) {
        return UtilityCard(property: currentSquare);
      } else {
        return PropertyCard(
          property: currentSquare,
          width: width,
          isProperty: false,
        );
      }
    } else {
      if (currentSquare.type == 2) {
        return EventCard(square: currentSquare);
      } else {
        return CornerTaxCard(square: currentSquare);
      }
    }
  }

  Widget buildContinueButtonText(Square currentSquare, ThemeData currentTheme) {
    if ([1, 5, 6].contains(square.type)) {
      return Text(
        "Buy Property for \$${(square as Property).price}",
        style: currentTheme.textTheme.bodyLarge!.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if ([0, 3, 4].contains(square.type)) {
      return Text([0, 4].contains(square.type) ?
        "Continue" : "Pay",
        style: currentTheme.textTheme.bodyLarge!.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return Text(
        "Draw Card",
        style: currentTheme.textTheme.bodyLarge!.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      spacing: height * 0.01,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildBoardSquareDisplay(square),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                debugPrint("buy");
              },
              style: theme.elevatedButtonTheme.style,
              child: buildContinueButtonText(square, theme),
            ),
          ],
        ),
      ],
    );
  }
}
