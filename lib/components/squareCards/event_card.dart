import 'package:flutter/material.dart';
import 'package:monopolyoligarch/services/database/models.dart';

class EventCard extends StatelessWidget {
  final Square square;

  const EventCard({super.key, required this.square});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  
    IconData squareIcon = Icons.redeem;
    Color iconColor = Colors.blueAccent;

    if (square.name == "Chance") {
      squareIcon = Icons.help_outline;
      iconColor = Colors.orange;
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
              const Text(
                "Press Button to Draw a Card",
                textAlign: TextAlign.center,
                style: TextStyle(
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