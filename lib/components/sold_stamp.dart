import 'package:flutter/material.dart';

class SoldStamp extends StatelessWidget {
  final double scaleFactor;
  const SoldStamp({super.key, required this.scaleFactor});

  @override
  Widget build(BuildContext context) {
    final Color stampRed = const Color(0xFFE53935);

    return Transform.scale(
      scale: scaleFactor,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: stampRed, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          decoration: BoxDecoration(
            color: stampRed,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            "SOLD",
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              fontFamily: 'serif',
              letterSpacing: 6,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
