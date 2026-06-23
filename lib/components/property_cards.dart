import 'package:flutter/material.dart';
import 'package:monopolyoligarch/services/database/models.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final double width;

  const PropertyCard({super.key, required this.property, required this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerColor = Color(property.color!);


    debugPrint(property.rent.length.toString());
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.onSurface.withOpacity(0.2),
          width: 1,
        ),
      ),
      color: const Color(0xFFF5F5DC),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. The Colored Header Block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: const Border(
                  bottom: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "TITLE DEED",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // 2. The Rent Details Body
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        "RENT \$${property.rent[0]}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Scaled House Rents
                  property.type == 1
                      ? Column(
                          children: [
                            _buildRentRow("With 1 Houses", property.rent[1]),
                            _buildRentRow("With 2 Houses", property.rent[2]),
                            _buildRentRow("With 3 Houses", property.rent[3]),
                            _buildRentRow("With 4 Houses", property.rent[4]),
                          ],
                        )
                      : Column(
                          children: [
                            _buildRentRow("With 1 Railroad", property.rent[0]),
                            _buildRentRow("With 2 Railroads", property.rent[1]),
                            _buildRentRow("With 3 Railroads", property.rent[2]),
                            _buildRentRow("With 4 Railroads", property.rent[3]),
                          ],
                        ),
                  const SizedBox(height: 8),
                  property.rent.length == 5
                      ? Text(
                          "With HOTEL \$${property.rent[5]}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )
                      : SizedBox(),

                  const Divider(color: Colors.black54, height: 20),
                  property.type == 1
                  ?
                  Column(
                    children: [
                      Text(
                        "Houses cost \$${property.houseCost} each",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Hotels, \$${property.houseCost} plus 4 houses",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ) : SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A tiny helper widget to keep the rent rows perfectly aligned
  Widget _buildRentRow(String label, int amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          Text(
            "\$$amount",
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
