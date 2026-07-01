import 'package:flutter/material.dart';
import 'package:monopolyoligarch/constants/monoployboard.dart';
import 'package:monopolyoligarch/services/stringprocessing.dart';

class PropertyTitle extends StatelessWidget {
  const PropertyTitle({
    super.key,
    required this.propertyId,
    required this.theme,
  });

  final int propertyId;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return properties[propertyId].color == 0
        ? Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.inversePrimary,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Text(
              properties[propertyId].name,
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          )
        : Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color(properties[propertyId].color),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Text(
              properties[propertyId].name,
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: getTextColor(Color(properties[propertyId].color)),
              ),
            ),
          );
  }
}
