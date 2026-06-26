Map<String, dynamic> parseStringToMap(String input) {
  Map<String, dynamic> resultMap = {};

  // 1. Remove curly braces and whitespace from the edges
  String cleaned = input.trim().replaceAll('{', '').replaceAll('}', '');

  if (cleaned.isEmpty) return resultMap;

  // 2. Split the string by commas to get individual "key: value" pairs
  List<String> pairs = cleaned.split(',');

  for (String pair in pairs) {
    // 3. Split each pair by the colon
    List<String> keyValue = pair.split(':');

    if (keyValue.length == 2) {
      String key = keyValue[0].trim();
      String rawValue = keyValue[1].trim();

      dynamic finalValue;

      if (int.tryParse(rawValue) != null) {
        finalValue = int.parse(rawValue);
      } else if (double.tryParse(rawValue) != null) {
        finalValue = double.parse(rawValue);
      } else {
        finalValue = rawValue.replaceAll('"', '').replaceAll("'", "");
      }

      resultMap[key] = finalValue;
    }
  }
  return resultMap;
}

Map<int, int> processRawMap(
    Map<String, dynamic> rawMap, {
    bool isValueDynamic = false,
  }) {
    return rawMap.map((key, value) {
      return isValueDynamic
          ? MapEntry(int.parse(key), value as int)
          : MapEntry(int.parse(key), value as dynamic);
    });
  }