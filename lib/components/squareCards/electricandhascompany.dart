import 'package:flutter/material.dart';
import 'package:monopolyoligarch/services/database/models.dart';

class UtilityCard extends StatelessWidget {
  final Property property;

  const UtilityCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    IconData utilityIcon = Icons.build_circle_outlined;
    if (property.name.toLowerCase().contains("electric")) {
      utilityIcon = Icons.lightbulb_outline;
    } else if (property.name.toLowerCase().contains("water")) {
      utilityIcon = Icons.water_drop_outlined; 
    } else if (property.name.toLowerCase().contains("gas")) {
      utilityIcon = Icons.local_fire_department_outlined;
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.2), width: 1),
      ),
      // Forcing a classic off-white paper look for the card body
      color: const Color(0xFFF5F5DC), 
      child: SizedBox(
        width: 220, // Matches the standard card width
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. The Utility Icon
              Icon(utilityIcon, size: 60, color: Colors.black87),
              const SizedBox(height: 12),
              
              // 2. The Title
              Text(
                property.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              
              // 3. The Rules (Using the database rent multipliers!)
              Text(
                "If one \"Utility\" is owned\nrent is ${property.rent[0]} times\namount shown on dice.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                "If both \"Utilities\" are owned\nrent is ${property.rent[1]} times\namount shown on dice.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
              ),
              
              const SizedBox(height: 20),
              const Divider(color: Colors.black54, height: 2),
              const SizedBox(height: 12),
              
              // 4. Base Information
              Text(
                "Property Value \$${property.price}",
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}