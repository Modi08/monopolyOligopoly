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
  final VoidCallback onFinish;
  final Map<String, dynamic> gameDetails;

  const ViewSquareCard({
    super.key,
    required this.height,
    required this.width,
    required this.square,
    required this.socketClient,
    required this.database,
    required this.currentPlayer,
    required this.onFinish,
    required this.gameDetails,
  });

  void buyPropertyFunction(BuildContext context, int? x) {
    Map<String, dynamic> boughtProperty = square.toMap();
    if (currentPlayer.cash > boughtProperty["price"]) {
      boughtProperty["ownershipShares"] = {currentPlayer.id: 100};
      boughtProperty["voterShares"] = {currentPlayer.id: 100};

      database.insertProperty(Property.fromMap(boughtProperty));
      database.updatePlayerParam(
        currentPlayer.id,
        "propertiesOwnershipShares",
        {square.id.toString(): 100}.toString(),
      );
      database.updatePlayerParam(
        currentPlayer.id,
        "propertiesVoterShares",
        {square.id.toString(): 100}.toString(),
      );
      database.updatePlayerParam(
        currentPlayer.id,
        "cash",
        currentPlayer.cash - boughtProperty["price"],
      );
      currentPlayer.cash = currentPlayer.cash - boughtProperty["price"] as int;
      boughtProperty.remove("id");

      boughtProperty["ownershipShares"] = {currentPlayer.id.toString(): 100};
      boughtProperty["voterShares"] = {currentPlayer.id.toString(): 100};

      socketClient.sendMessagetoServer({
        "propertyId": square.id,
        "propertyData": boughtProperty,
      }, "buyProperty");
    } else {
      showSnackbar(context, "You don't have enough cash", true);
    }
  }

  void payTaxFunction(BuildContext context, int? taxAmount) {
    if (currentPlayer.cash > taxAmount!) {
      currentPlayer.cash = currentPlayer.cash - taxAmount;

      database.updatePlayerParam(
        currentPlayer.id,
        "cash",
        currentPlayer.cash - taxAmount,
      );

      gameDetails["cashPool"] = gameDetails["cashPool"] + taxAmount;

      socketClient.sendMessagetoServer({
        "taxPaid": taxAmount,
        "cashPool": gameDetails["cashPool"],
      }, "payTax");

      showSnackbar(context, "You just paid \$$taxAmount in taxes", true);
    } else {
      debugPrint("To be Implimented");
    }
  }

  void collectFunction(BuildContext context, int? x) {
    int amount = 0;
    if (square.id == 20) {
      currentPlayer.cash = currentPlayer.cash + gameDetails["cashPool"] as int;

      database.updatePlayerParam(
        currentPlayer.id,
        "cash",
        currentPlayer.cash + gameDetails["cashPool"],
      );

      socketClient.sendMessagetoServer({
        "cashPool": gameDetails["cashPool"],
      }, "cashPoolCollected");

      amount = gameDetails["cashPool"];

      gameDetails["cashPool"] = 0;
    } else {
      currentPlayer.cash = currentPlayer.cash + 200;
      amount = 200;

      database.updatePlayerParam(
        currentPlayer.id,
        "cash",
        currentPlayer.cash + 200,
      );

      socketClient.sendMessagetoServer({}, "goCollected");
    }
    showSnackbar(context, "You just collect \$$amount", false);
  }

  void goToJail(BuildContext context, int? x) {
    currentPlayer.inJail = true;
    currentPlayer.position = 10;

    database.updatePlayerParam(currentPlayer.id, "inJail", "true");
    database.updatePlayerParam(currentPlayer.id, "postion", 10);
  }

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
    } else if (0 == square.type) {
      return Text(
        "Collect",
        style: currentTheme.textTheme.bodyLarge!.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (3 == square.type) {
      return Text(
        "Pay",
        style: currentTheme.textTheme.bodyLarge!.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (4 == square.type) {
      return Text(
        10 == square.id ? "Continue" : "Go To Jail",
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

  List<Widget> buildBottomButtons(
    List<Function(BuildContext, int?)> functionsLists,
    BuildContext context,
    ThemeData currentTheme,
  ) {
    if ([1, 5, 6].contains(square.type)) {
      return [
        ElevatedButton(
          onPressed: () {
            functionsLists[0](context, null);
            onFinish();
          },
          style: currentTheme.elevatedButtonTheme.style,
          child: buildContinueButtonText(square, currentTheme),
        ),
        ElevatedButton(
          onPressed: () {
            onFinish();
          },
          style: currentTheme.elevatedButtonTheme.style!.copyWith(
            backgroundColor: WidgetStateProperty.all(
              currentTheme.colorScheme.error,
            ),
          ),
          child: Text(
            "Leave",
            style: currentTheme.textTheme.bodyLarge!.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            debugPrint("To be implimented");
          },
          style: currentTheme.elevatedButtonTheme.style!.copyWith(
            backgroundColor: WidgetStateProperty.all(
              currentTheme.colorScheme.inversePrimary,
            ),
          ),
          child: Text(
            "Apply for a loan",
            style: currentTheme.textTheme.bodyLarge!.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ];
    } else if (0 == square.type) {
      return [
        ElevatedButton(
          onPressed: () {
            functionsLists[1](context, null);
            onFinish();
          },
          style: currentTheme.elevatedButtonTheme.style,
          child: buildContinueButtonText(square, currentTheme),
        ),
      ];
    } else if (3 == square.type) {
      return [
        ElevatedButton(
          onPressed: () {
            functionsLists[2](context, square.id == 4 ? 200 : 100);
            onFinish();
          },
          style: currentTheme.elevatedButtonTheme.style,
          child: buildContinueButtonText(square, currentTheme),
        ),
      ];
    } else if (4 == square.type) {
      if (square.type == 30) {
        return [
          ElevatedButton(
            onPressed: () {
              functionsLists[3](context, null);
              onFinish();
            },
            style: currentTheme.elevatedButtonTheme.style,
            child: buildContinueButtonText(square, currentTheme),
          ),
        ];
      } else {
        return [
          ElevatedButton(
            onPressed: () {
              onFinish();
            },
            style: currentTheme.elevatedButtonTheme.style,
            child: buildContinueButtonText(square, currentTheme),
          ),
        ];
      }
    } else {
      return [];
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
          children: buildBottomButtons(
            [buyPropertyFunction, collectFunction, payTaxFunction,  goToJail],
            context,
            theme,
          ),
        ),
      ],
    );
  }
}
