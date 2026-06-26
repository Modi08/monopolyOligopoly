import 'dart:convert';

class Player {
  final int id;
  final String name;
  int cash;
  int netWorth;
  Map<int, int> propertiesOwnershipShares;
  Map<int, int> propertiesVoterShares;
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
    required this.propertiesVoterShares,
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
          ? jsonEncode(
              propertiesOwnershipShares.map(
                (k, v) => MapEntry(k.toString(), v),
              ),
            )
          : propertiesOwnershipShares,
      'propertiesVoterShares': isDatabase
          ? jsonEncode(
              propertiesVoterShares.map((k, v) => MapEntry(k.toString(), v)),
            )
          : propertiesVoterShares,
      'position': position,
      'inJail': isDatabase ? inJail.toString() : inJail,
      'jailTurns': jailTurns,
      'activeLoans': isDatabase
          ? activeLoans.map((k, v) => MapEntry(k.toString(), v))
          : activeLoans,
      'playerTurn': playerTurn,
      'isCurrentPlayer': isDatabase
          ? isCurrentPlayer.toString()
          : isCurrentPlayer,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as int,
      name: map['username'] as String,
      cash: map['cash'] as int,
      netWorth: map['netWorth'],
      propertiesOwnershipShares:
          map['propertiesOwnershipShares'].runtimeType == String
          ? processRawMap(jsonDecode(map['propertiesOwnershipShares']))
          : processRawMap(map['propertiesOwnershipShares']),
      propertiesVoterShares: map['propertiesVoterShares'].runtimeType == String
          ? processRawMap(jsonDecode(map['propertiesVoterShares']))
          : processRawMap(map['propertiesVoterShares']),
      position: map['position'] as int,
      inJail: map['inJail'].runtimeType == String
          ? (map['inJail'] == "true")
          : map['inJail'] as bool,
      jailTurns: map['jailTurns'] as int,
      activeLoans: map['activeLoans'].runtimeType == String
          ? processRawMap(jsonDecode(map['activeLoans']), isValueDynamic: true)
          : processRawMap(map['activeLoans'], isValueDynamic: true),
      playerTurn: map['playerTurn'] as int,
      isCurrentPlayer: map['isCurrentPlayer'].runtimeType == String
          ? (map['isCurrentPlayer'] == "true")
          : map['isCurrentPlayer'] as bool,
    );
  }

  static Map<int, int> processRawMap(
    Map<String, dynamic> rawMap, {
    bool isValueDynamic = false,
  }) {
    return rawMap.map((key, value) {
      return isValueDynamic
          ? MapEntry(int.parse(key), value as int)
          : MapEntry(int.parse(key), value as dynamic);
    });
  }
}

class Square {
  final int id;
  final String name;
  final int type;
  final int color;

  Square({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'type': type, 'color': color};
  }

  factory Square.fromMap(Map<String, dynamic> map) {
    return Square(
      id: map['id'] as int,
      name: map['name'] as String,
      type: map['type'] as int,
      color: map['color'] as int,
    );
  }
}

class Property extends Square {
  final int price;
  final List<int> rent;
  final int houseCost;
  final int houses;
  final Map<int, int> ownershipShares;
  final Map<int, int> voterShares;
  final int valuation;

  Property({
    required super.id,
    required super.name,
    required super.type,
    required super.color,
    required this.price,
    required this.rent,
    required this.houseCost,
    required this.houses,
    required this.ownershipShares,
    required this.voterShares,
    required this.valuation
  });

  @override
  Map<String, dynamic> toMap({bool isDatabase = false}) {
    final map = super.toMap();

    map.addAll({
      'price': price,
      'rent': isDatabase ? jsonEncode(rent) : rent,
      'houseCost': houseCost,
      'houses': houses,
      'ownershipShares': isDatabase
          ? jsonEncode(ownershipShares.map((k, v) => MapEntry(k.toString(), v)))
          : ownershipShares,
      'voterShares': isDatabase
          ? jsonEncode(voterShares.map((k, v) => MapEntry(k.toString(), v)))
          : voterShares,
      'valuation' : valuation
    });

    return map;
  }

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'] as int,
      name: map['name'] as String,
      type: map['type'] as int,
      color: map['color'] as int,
      price: map['price'] as int,
      houseCost: map['houseCost'] as int,
      houses: map['houses'] as int,
      rent: List<int>.from(map['rent']),
      ownershipShares: processRawMap(map['ownershipShares']),
      voterShares: processRawMap(map['voterShares']),
      valuation: map["valuation"] as int,
    );
  }

  static Map<int, int> processRawMap(Map<dynamic, dynamic> rawMap) {
    return rawMap.map((key, value) {
      if (key is String) {
        return MapEntry(int.parse(key), value as int);
      } else {
        return MapEntry(key, value as int);
      }
    });
  }
}
