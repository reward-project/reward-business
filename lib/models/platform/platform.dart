class Platform {
  final int? id;
  final String name;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? displayName;
  final List<String> domains;

  Platform({
    this.id,
    required this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.displayName,
    required this.domains,
  });

  factory Platform.fromJson(Map<String, dynamic> json) {
    var rawId = json['id'];
    int? parsedId;
    if (rawId != null) {
      if (rawId is int) {
        parsedId = rawId;
      } else if (rawId is String) {
        parsedId = int.tryParse(rawId);
      }
    }

    return Platform(
      id: parsedId,
      name: json['name'],
      status: json['status'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      displayName: json['displayName'],
      domains: List<String>.from(json['domains'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'displayName': displayName,
      'domains': domains,
    };
  }
}
