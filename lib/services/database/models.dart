import 'dart:convert';

class Player {
  final int? id;
  final String name;
  final int cash;
  final Map<String, dynamic> propertiesOwnershipShares;
  final Map<String, dynamic> propertiesVotershare;
  final int position;
  final bool inJail;
  final int jailTurns;
  final Map<String, dynamic> activeLoans;
  final int playerTurn;
  final bool isCurrentPlayer;

  Player({
    this.id,
    required this.name,
    required this.cash,
    required this.propertiesOwnershipShares,
    required this.propertiesVotershare,
    required this.position,
    required this.inJail,
    required this.jailTurns,
    required this.activeLoans,
    required this.playerTurn,
    required this.isCurrentPlayer,
  });

  // Convert a Player into a Map for SQLite
  Map<String, dynamic> toMap({bool isDatabase = false}) {
    return {
      'id': id,
      'username': name,
      'cash': cash,
      'propertiesOwnershipShares': isDatabase
          ? propertiesOwnershipShares.toString()
          : propertiesOwnershipShares,
      'propertiesVotershare': isDatabase
          ? propertiesVotershare.toString()
          : propertiesVotershare,
      'position': position,
      'inJail': isDatabase ? inJail.toString() : inJail,
      'jailTurns': jailTurns,
      'activeLoans': isDatabase ? activeLoans.toString() : activeLoans,
      'playerTurn': playerTurn,
      'isCurrentPlayer': isDatabase
          ? isCurrentPlayer.toString()
          : isCurrentPlayer,
    };
  }

  // Convert a Map from SQLite back into a Player object
  factory Player.fromMap(Map<String, dynamic> map, {bool isDatabase = false}) {
    return Player(
      id: map['id'] as int?,
      name: map['username'] as String,
      cash: map['cash'] as int,
      propertiesOwnershipShares: isDatabase
          ? jsonDecode(map['propertiesOwnershipShares']) as Map<String, dynamic>
          : map['propertiesOwnershipShares'] as Map<String, dynamic>,
      propertiesVotershare: isDatabase
          ? jsonDecode(map['propertiesVotershare']) as Map<String, dynamic>
          : map['propertiesVotershare'] as Map<String, dynamic>,
      position: map['position'] as int,
      inJail: isDatabase
          ? (map['inJail'] == true.toString())
          : map['inJail'] as bool,
      jailTurns: map['jailTurns'] as int,
      activeLoans: isDatabase
          ? jsonDecode(map['activeLoans']) as Map<String, dynamic>
          : map['activeLoans'] as Map<String, dynamic>,
      playerTurn: map['playerTurn'] as int,
      isCurrentPlayer: isDatabase
          ? (map['isCurrentPlayer'] == true.toString())
          : map['isCurrentPlayer'] as bool,
    );
  }
}
