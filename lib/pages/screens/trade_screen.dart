import 'package:flutter/material.dart';
import 'package:monopolyoligarch/components/addcash.dart';
import 'package:monopolyoligarch/components/addproperties.dart';
import 'package:monopolyoligarch/components/circularshareholderpercentage.dart';
import 'package:monopolyoligarch/services/database/models.dart';


class TradeLedgerScreen extends StatefulWidget {
  final Player currentPlayer;
  final Player targetPlayer;
  final double width;

  const TradeLedgerScreen({
    super.key,
    required this.currentPlayer,
    required this.targetPlayer,
    required this.width,
  });

  @override
  State<TradeLedgerScreen> createState() => _TradeLedgerScreenState();
}

class _TradeLedgerScreenState extends State<TradeLedgerScreen> {
  // Trade Ledger Data
  int offerCash = 0;
  List<MapEntry<Property, List<int>>> offerProperties = [];

  int requestCash = 0;
  List<MapEntry<Property, List<int>>> requestProperties = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // Classic ledger off-white/beige
      appBar: AppBar(
        title: Text(
          "Trade Ledger",
          style: theme.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.hintColor),
      ),
      body: Column(
        children: [
          // --- TOP SECTION: THE SPLIT LEDGER ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // LEFT SIDE: YOUR OFFER
                    Expanded(
                      child: _buildLedgerColumn(
                        title: "YOU GIVE",
                        playerName: widget.currentPlayer.name,
                        cash: offerCash,
                        properties: offerProperties,
                        isOffer: true,
                        theme: theme,
                      ),
                    ),

                    // THE LINE DOWN THE MIDDLE
                    const VerticalDivider(
                      color: Colors.black87,
                      thickness: 2,
                      width: 2,
                    ),

                    // RIGHT SIDE: THEIR OFFER
                    Expanded(
                      child: _buildLedgerColumn(
                        title: "YOU GET",
                        playerName: widget.targetPlayer.name,
                        cash: requestCash,
                        properties: requestProperties,
                        isOffer: false,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- BOTTOM SECTION: THE CONTROLS ---
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            theme.primaryColor,
                          ),
                        ),
                        onPressed: () async {
                          debugPrint("Add Cash");
                          showDialog(
                            context: context,
                            builder: (context) =>
                                AddCash(maxCash: widget.currentPlayer.cash),
                          ).then((addedCash) {
                            if (addedCash != null) {
                              setState(() {
                                offerCash = addedCash;
                              });
                              widget.currentPlayer.cash -= int.parse(addedCash);
                            }
                          });
                        },
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: theme.hintColor,
                          weight: 50,
                        ),
                        label: Text(
                          "Add Cash",
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: theme.hintColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            theme.primaryColor,
                          ),
                        ),
                        onPressed: () async {
                          debugPrint("Add Properties");
                          List<MapEntry<int, List<int>>> currentPlayerProperties =  widget.currentPlayer.propertiesVoterShares.entries.map((entries) {
                                return MapEntry(entries.key, [entries.value, widget.currentPlayer.propertiesOwnershipShares[entries.key]!]);
                          }).toList();
                          currentPlayerProperties.add(MapEntry(8, [100, 100]));
                          currentPlayerProperties.add(MapEntry(39, [100, 100]));
                          showDialog(context: context, builder: (context) => AddProperties(propertiesData: currentPlayerProperties)).then((addedProperties) {
                            if (addedProperties != null) {
                              offerProperties.addAll(addedProperties);
                              offerProperties.map((propData) {
                                for (var entry in addedProperties) {
                                  if (propData.key.id == entry.key.id) {
                                    setState(() {
                                      offerProperties.remove(propData);
                                    });
                                }}
                              }).toList();
                              setState(() {
                                offerProperties.addAll(addedProperties);
                              });
                            }
                          });
                        },
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: theme.hintColor,
                          weight: 50,
                        ),
                        label: Text(
                          "Add Property",
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: theme.hintColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.tertiary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        // TODO: Submit Trade
                      },
                      child: const Text(
                        "PROPOSE TRADE",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerColumn({
    required String title,
    required String playerName,
    required int cash,
    required List<MapEntry<Property, List<int>>> properties,
    required bool isOffer,
    required ThemeData theme,
  }) {
    final ledgerStyle = TextStyle(
      fontFamily: 'serif',
      color: theme.hintColor,
      fontSize: 16,
    );

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Center(
            child: Text("($playerName)", style: theme.textTheme.bodyMedium),
          ),
          Divider(color: theme.primaryColor),
          const SizedBox(height: 8),

          Text(
            "CASH:",
            style: ledgerStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            cash > 0 ? "\$$cash" : "\$0",
            style: ledgerStyle.copyWith(
              color: isOffer
                  ? theme.colorScheme.error
                  : theme.colorScheme.tertiary,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "PROPERTIES:",
            style: ledgerStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          if (properties.isEmpty)
            Text(
              "- None -",
              style: ledgerStyle.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.primary,
              ),
            ),
          ...properties.map((p) => buildPropertyRow(p, theme)),
        ],
      ),
    );
  }

  Widget buildPropertyRow(MapEntry<Property, List<int>> propertyEntry, ThemeData theme) {
    final property = propertyEntry.key;
    final shares = propertyEntry.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            overflow: TextOverflow.ellipsis,
            property.name,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            CircularSharePercentage(
              progress: shares[0] / 100,
              height: 50,
              thickness: 6,
              backgroundColor: Colors.grey.shade300,
              progressColor: theme.colorScheme.inversePrimary,
            ),
            CircularSharePercentage(
              progress: shares[1] / 100,
              height: 40,
              thickness: 6,
              backgroundColor: Colors.grey.shade300,
              progressColor: theme.focusColor,
            ),
            Text(
              "${shares[0]}%",
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.inversePrimary,
              ),
            ),
            Text(
              "${shares[1]}%",
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.focusColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
