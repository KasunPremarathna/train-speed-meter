class Station {
  final String name;
  final double lat;
  final double lng;
  final String type;
  final String line;
  final String code;

  Station({
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    required this.line,
    required this.code,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      name: json['name'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      type: json['type'] ?? 'Unknown',
      line: json['line'] ?? 'Unknown',
      code: json['code'] ?? '???',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'lng': lng,
      'type': type,
      'line': line,
      'code': code,
    };
  }

  // Helper to check if this is a major station
  bool get isMajor =>
      type.contains('Major') ||
      type.contains('Junction') ||
      type.contains('Terminal');

  // Priority for sorting (lower = higher priority)
  int get priority {
    if (type.contains('Major Junction')) return 1;
    if (type.contains('Major')) return 2;
    if (type.contains('Terminal')) return 3;
    if (type.contains('Sub-Station')) return 4;
    return 5; // Halt
  }
}
