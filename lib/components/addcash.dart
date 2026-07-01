import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCash extends StatefulWidget {
  final int maxCash;
  const AddCash({super.key, required this.maxCash});

  @override
  State<AddCash> createState() => _AddCashState();
}

class _AddCashState extends State<AddCash> {
  final cashController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: const Text("Set Cash", textAlign: TextAlign.center),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          cashController.text.isNotEmpty
              ? Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3,),
                    Icon(
                      Icons.money_rounded,
                      color: theme.colorScheme.tertiary,
                    ),
                    Text(
                      "\$${cashController.text}",
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Spacer(flex: 4,),
                  ],
                )
              : SizedBox(),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: cashController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.money_sharp, color: Colors.green),
              hintText:
                  "Enter value (Max: \$${widget.maxCash})",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                int cashAdded = int.parse(value);

                if (cashAdded > widget.maxCash) {
                  cashController.text = widget.maxCash.toString();

                  cashController.selection = TextSelection.fromPosition(
                    TextPosition(offset: cashController.text.length),
                  );
                }
              }
            },
          ),
          ElevatedButton(onPressed: () {
            Navigator.pop(context, int.parse(cashController.text));
          },
          style: ButtonStyle(backgroundColor: WidgetStateProperty.all(theme.colorScheme.tertiary), padding: WidgetStateProperty.all(const EdgeInsets.all(8))), 
          child: Text("Set Cash", style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),))
        ],
      ),
    );
  }
}
