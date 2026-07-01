import 'package:flutter/material.dart';

class CircularSharePercentage extends StatefulWidget {
  final double progress;
  final double height;
  final double thickness;
  final Color backgroundColor;
  final Color progressColor;

  const CircularSharePercentage({
    super.key,
    required this.progress,
    required this.height,
    required this.thickness,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  State<CircularSharePercentage> createState() =>
      _CircularSharePercentageState();
}

class _CircularSharePercentageState extends State<CircularSharePercentage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.height,
      height: widget.height,
      child: CircularProgressIndicator(
        value: widget.progress,
        strokeWidth: widget.thickness,
        backgroundColor: widget.backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.progressColor, 
        ),
        strokeCap:
            StrokeCap.round, 
      ),
    );
  }
}
