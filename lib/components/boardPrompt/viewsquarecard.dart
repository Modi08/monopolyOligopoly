import 'package:flutter/material.dart';
import 'package:monopolyoligarch/components/squareCards/corner_tax_card.dart';
import 'package:monopolyoligarch/components/squareCards/electricandhascompany.dart';
import 'package:monopolyoligarch/components/squareCards/event_card.dart';
import 'package:monopolyoligarch/components/squareCards/property_cards.dart';
import 'package:monopolyoligarch/services/database/database_service.dart';
import 'package:monopolyoligarch/services/database/models.dart';
import 'package:monopolyoligarch/services/snackbar.dart';
import 'package:monopolyoligarch/services/socket.dart';

class ViewSquareCard extends StatelessWidget {
  final double height;
  final double width;
  final Square square;
  final GameClient socketClient;
  final DatabaseService database;
  final Player currentPlayer;

  const ViewSquareCard({
    super.key,
    required this.height,
    required this.width,
    required this.square,
    required this.socketClient,
    required this.database,
    required this.currentPlayer,
  });

  Widget buildBoardSquareDisplay(Square currentSquare) {
    debugPrint("square type: ${currentSquare.type}");
    if (currentSquare is Property) {
      if (currentSquare.type == 1) {
        return PropertyCard(
          property: currentSquare,
          width: width * 0.6,
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
      return Text(
        [0, 4].contains(square.type) ? "Continue" : "Pay",
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
                if (square is Property) {
                  Map<String, dynamic> boughtProperty = square.toMap();
                  if (currentPlayer.cash > boughtProperty["price"]) {
                    boughtProperty["ownershipShares"] = {currentPlayer.id: 100};
                    boughtProperty["voterShares"] = {currentPlayer.id: 100};
                    
                    database.insertProperty(Property.fromMap(boughtProperty));
                    database.updatePlayerParam(
                      currentPlayer.id,
                      "propertiesOwnershipShares",
                      {currentPlayer.id: 100},
                    );
                    database.updatePlayerParam(
                      currentPlayer.id,
                      "propertiesVoterShares",
                      {currentPlayer.id: 100},
                    );
                    database.updatePlayerParam(
                      currentPlayer.id,
                      "cash",
                      currentPlayer.cash - int.parse(boughtProperty["price"]),
                    );
                    currentPlayer.cash = currentPlayer.cash - int.parse(boughtProperty["price"]);

                    socketClient.sendMessagetoServer({
                      "propertyId": square.id,
                      "propertyData": boughtProperty.remove("id"),
                    }, "buyProperty");
                   } else {
                    showSnackbar(context, "You don't have enough cash", true);
                   }
                }
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
