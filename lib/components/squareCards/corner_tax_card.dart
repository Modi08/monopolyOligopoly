import 'package:flutter/material.dart';
import 'package:monopolyoligarch/services/database/models.dart';

class CornerTaxCard extends StatelessWidget {
  final Square square;

  const CornerTaxCard({super.key, required this.square});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Default fallbacks
    IconData squareIcon = Icons.star;
    Color iconColor = Colors.black87;
    String subText = "";

    // CORNERS (Types 0 & 4)
    if (square.type == 0 || square.type == 4) {
      if (square.name == "GO") {
        squareIcon = Icons.arrow_forward_outlined;
        iconColor = Colors.redAccent;
        subText = "COLLECT \$200 SALARY AS YOU PASS";
      } else if (square.name == "Jail") {
        squareIcon = Icons.gavel;
        subText = "JUST VISITING";
      } else if (square.name == "Free Parking") {
        squareIcon = Icons.directions_car;
        iconColor = Colors.redAccent;
      } else if (square.name == "Go To Jail") {
        squareIcon = Icons.policy;
        iconColor = Colors.blue.shade900;
        subText = "GO DIRECTLY TO JAIL";
      }
    } 
    // TAXES (Type 3)
    else if (square.type == 3) {
      squareIcon = Icons.request_quote;
      iconColor = Colors.black87;
      subText = square.name == "Income Tax" ? "PAY \$200" : "PAY \$100";
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.2), width: 1),
      ),
      color: const Color(0xFFF5F5DC), 
      child: SizedBox(
        width: 220,
        height: 280, 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(squareIcon, size: 80, color: iconColor),
              const SizedBox(height: 20),
              Text(
                square.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: iconColor,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              if (subText.isNotEmpty)
                Text(
                  subText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}