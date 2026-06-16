import 'dart:convert';

class Player {
  final int id;
  final String name;
  int cash;
  int netWorth;
  Map<int, int> propertiesOwnershipShares;
  Map<int, int> propertiesVotershare;
  int position;
  bool inJail;
  int jailTurns;
  Map<int, dynamic> activeLoans;
  int playerTurn;
  final bool isCurrentPlayer;

  Player({
    required this.id,
    required this.name,
    required this.cash,
    required this.netWorth,
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
      'netWorth': netWorth,
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
      id: map['id'] as int,
      name: map['username'] as String,
      cash: map['cash'] as int,
      netWorth: map['netWorth'],
      propertiesOwnershipShares: isDatabase
          ? jsonDecode(map['propertiesOwnershipShares']) as Map<int, int>
          : processRawMap(map['propertiesOwnershipShares']),
      propertiesVotershare: isDatabase
          ? jsonDecode(map['propertiesVotershare']) as Map<int, int>
          :processRawMap(map['propertiesVotershare']),
      position: map['position'] as int,
      inJail: isDatabase
          ? (map['inJail'] == true.toString())
          : map['inJail'] as bool,
      jailTurns: map['jailTurns'] as int,
      activeLoans: isDatabase
          ? jsonDecode(map['activeLoans']) as Map<int, dynamic>
          : processRawMap(map['activeLoans']),
      playerTurn: map['playerTurn'] as int,
      isCurrentPlayer: isDatabase
          ? (map['isCurrentPlayer'] == true.toString())
          : map['isCurrentPlayer'] as bool,
    );
  }

  static Map<int, int> processRawMap(Map<String, dynamic> rawMap) {
    return rawMap.map((key, value) {
      return MapEntry(int.parse(key), value as int);
    });
  }
}

class Square {
  final int postion;
  final String name;
  final int type;
  final int? color;

  Square({
    required this.postion,
    required this.name,
    required this.type,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {'postion': postion, 'name': name, 'type': type, 'color': color};
  }

  factory Square.fromMap(Map<String, dynamic> map) {
    return Square(
      postion: map['postion'] as int,
      name: map['name'] as String,
      type: map['type'] as int,
      color: map['color'] as int?,
    );
  }
}

class Properties extends Square {
  final int price;
  final List<int> rent;
  final int houseCost;
  final int houses;
  final Map<int, int> ownershipShares;
  final Map<int, int> voterShares;

  Properties({
    // Use 'super' to pass these values up to the Square class!
    required super.postion,
    required super.name,
    required super.type,
    required super.color,

    // These belong to Properties specifically
    required this.price,
    required this.rent,
    required this.houseCost,
    required this.houses,
    required this.ownershipShares,
    required this.voterShares,
  });

  @override
  Map<String, dynamic> toMap() {
    // 1. Grab the base map from the Square class
    final map = super.toMap();

    // 2. Add the specific property fields to it
    map.addAll({
      'price': price,
      'rent': rent,
      'houseCost': houseCost,
      'houses': houses,
      'ownershipShares': ownershipShares,
      'voterShares': voterShares,
    });

    return map;
  }

  factory Properties.fromMap(Map<String, dynamic> map) {
    return Properties(
      postion: map['postion'] as int,
      name: map['name'] as String,
      type: map['type'] as int,
      color: map['color'] as int,
      price: map['price'] as int,
      houseCost: map['houseCost'] as int,
      houses: map['houses'] as int,
      rent: List<int>.from(map['rent']),
      ownershipShares: Map<int, int>.from(map['ownershipShares']),
      voterShares: Map<int, int>.from(map['voterShares']),
    );
  }
}
