class Platform {
  final int id;
  final String name;
  final String displayName;
  final String status;
  final List<String> domains;

  Platform({
    required this.id,
    required this.name,
    required this.displayName,
    required this.status,
    this.domains = const [],
  });

  factory Platform.fromJson(Map<String, dynamic> json) {
    try {
      return Platform(
        id: json['id'] is String ? int.parse(json['id']) : json['id'],
        name: json['name'] as String,
        displayName: json['displayName'] as String,
        status: json['status'] as String,
        domains: List<String>.from(json['domains'] ?? []),
      );
    } catch (e) {
      print('Error parsing Platform: $json');
      rethrow;
    }
  }
}
