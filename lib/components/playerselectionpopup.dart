import 'package:flutter/material.dart';
import 'package:monopolyoligarch/services/database/models.dart';

class PlayerSelectionDialog extends StatelessWidget {
  final List<Player> allPlayers;
  final Player currentPlayer;
  final Function(Player) onPlayerSelected;

  const PlayerSelectionDialog({
    super.key,
    required this.allPlayers,
    required this.currentPlayer,
    required this.onPlayerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Exclude the current player from the list
    final availablePlayers = allPlayers.where((p) => p.id != currentPlayer.id).toList();

    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: const Text("Select Player", textAlign: TextAlign.center),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: double.maxFinite,
        child: availablePlayers.isEmpty 
          ? const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No other players available.", textAlign: TextAlign.center),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: availablePlayers.length,
              itemBuilder: (context, index) {
                final targetPlayer = availablePlayers[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(targetPlayer.name[0])),
                  title: Text(targetPlayer.name, style: theme.textTheme.titleMedium),
                  onTap: () {
                    Navigator.pop(context);
                    onPlayerSelected(targetPlayer);
                     // Closes the dialog
                  },
                );
              },
            ),
      ),
    );
  }
}