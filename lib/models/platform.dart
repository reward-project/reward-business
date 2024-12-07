class Platform {
  final int id;
  final String name;
  final String displayName;
  final String status;

  Platform({
    required this.id,
    required this.name,
    required this.displayName,
    required this.status,
  });

  factory Platform.fromJson(Map<String, dynamic> json) {
    return Platform(
      id: json['id'],
      name: json['name'],
      displayName: json['displayName'],
      status: json['status'],
    );
  }
} 