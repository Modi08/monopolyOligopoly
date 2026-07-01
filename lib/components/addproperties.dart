import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monopolyoligarch/constants/monoployboard.dart';
import 'package:monopolyoligarch/services/database/models.dart';
import 'dart:math' as math;

import 'package:monopolyoligarch/services/stringprocessing.dart';

class AddProperties extends StatefulWidget {
  final List<MapEntry<int, List<int>>> propertiesData;
  const AddProperties({super.key, required this.propertiesData});

  @override
  State<AddProperties> createState() => _AddPropertiesState();
}

class _AddPropertiesState extends State<AddProperties> {
  List<MapEntry<Property, List<int>>> selectedPropertiesData = [];

  final Map<int, bool> isDropDownOpen = {};
  final Map<int, TextEditingController> _ownershipControllers = {};
  final Map<int, TextEditingController> _voterControllers = {};

  @override
  void dispose() {
    for (var controller in _ownershipControllers.values) {
      controller.dispose();
    }
    for (var controller in _voterControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void onChange(Property? prop) {
    if (prop != null) {
      debugPrint(prop.name.toString());

      for (var entry in widget.propertiesData) {
        if (entry.key == prop.id) {
          MapEntry<Property, List<int>> propData = MapEntry(prop, entry.value);
          _ownershipControllers.putIfAbsent(
            prop.id,
            () => TextEditingController(),
          );
          _voterControllers.putIfAbsent(prop.id, () => TextEditingController());

          setState(() {
            selectedPropertiesData.add(propData);
            isDropDownOpen[prop.id] = false;
          });
          continue;
        }
      }
    }
  }

  List<Widget> buildPropertiesList(ThemeData theme) {
    return selectedPropertiesData.map((propData) {
      Property prop = propData.key;
      final ownershipSharesController = _ownershipControllers[prop.id]!;
      final voterSharesController = _voterControllers[prop.id]!;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: prop.color == 0 ? Colors.grey.shade400 : Color(prop.color),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      isDropDownOpen[prop.id] = !isDropDownOpen[prop.id]!;
                    });
                  },
                  icon: Transform.rotate(
                    angle: isDropDownOpen[prop.id]! ? 0 : math.pi * 3 / 2,
                    child: Icon(
                      Icons.arrow_drop_down_circle,
                      color: getTextColor(Color(prop.color)),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    prop.name,
                    style: TextStyle(
                      color: getTextColor(Color(prop.color)),
                      fontWeight: FontWeight.w900,
                      fontFamily: 'serif',
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Property Price
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "\$${prop.price}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedPropertiesData.remove(propData);
                      isDropDownOpen.remove(prop.id);
                      _ownershipControllers.remove(prop.id);
                      _voterControllers.remove(prop.id);
                    });
                  },
                  icon: const Icon(Icons.close_rounded, weight: 40),
                  color: theme.colorScheme.error,
                  iconSize: 20,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    backgroundColor: Color(prop.color),
                    shape: const CircleBorder(),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          isDropDownOpen[prop.id]!
              ? shareInputFieldBuilder(
                  ownershipSharesController,
                  theme,
                  propData.value[0],
                  true,
                  prop.id,
                )
              : SizedBox(),
          isDropDownOpen[prop.id]!
              ? shareInputFieldBuilder(
                  voterSharesController,
                  theme,
                  propData.value[1],
                  false,
                  prop.id,
                )
              : SizedBox(),
        ],
      );
    }).toList();
  }

  Widget shareInputFieldBuilder(
    TextEditingController controller,
    ThemeData theme,
    int maxShares,
    bool isOwnership,
    int propId,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isOwnership
                  ? theme.colorScheme.inversePrimary
                  : theme.focusColor,
              width: 3.0,
            ),
            bottom: BorderSide(
              color: isOwnership
                  ? theme.colorScheme.inversePrimary
                  : theme.focusColor,
              width: 3.0,
            ),
          ),
        ),
        child: TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter value (Max: $maxShares)",
            contentPadding: const EdgeInsets.all(12),

            filled: false,

            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 1.5),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 2.0),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              int ownershipShares = int.parse(value);

              if (ownershipShares > maxShares) {
                controller.text = maxShares.toString();

                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              }

              for (var entry in selectedPropertiesData) {
                if (entry.key.id == propId) {
                  if (isOwnership) {
                    selectedPropertiesData.remove(entry);
                    selectedPropertiesData.add(
                      MapEntry(entry.key, [
                        int.parse(controller.text),
                        entry.value[1],
                      ]),
                    );
                  } else {
                    selectedPropertiesData.remove(entry);
                    selectedPropertiesData.add(
                      MapEntry(entry.key, [
                        entry.value[0],
                        int.parse(controller.text),
                      ]),
                    );
                  }
                  break;
                }
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      scrollable: true,
      backgroundColor: theme.cardColor,
      title: const Text("Set Properties", textAlign: TextAlign.center),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Column(spacing: 10, children: buildPropertiesList(theme)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton<Property>(
                  isExpanded: true,
                  value: null,
                  hint: const Text(
                    "Select a Property",
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: const Icon(Icons.arrow_drop_down_circle),
                  onChanged: onChange,

                  menuMaxHeight: 300,
                  dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                  items: widget.propertiesData.map((entry) {
                    final Property property = properties[entry.key] as Property;
                    final bgColor = property.color == 0
                        ? Colors.grey.shade400
                        : Color(property.color);
                    final textColor = getTextColor(bgColor);

                    return DropdownMenuItem<Property>(
                      value: property,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Property Name
                            Expanded(
                              child: Text(
                                property.name,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'serif',
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Property Price
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "\$${property.price}",
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedPropertiesData);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  theme.colorScheme.inversePrimary,
                ),
                padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
              ),
              child: Text(
                "Add Properties",
                style: theme.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
