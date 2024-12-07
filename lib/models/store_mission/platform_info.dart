class PlatformInfo {
  final int id;
  final String name;
  final String displayName;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlatformInfo({
    required this.id,
    required this.name,
    required this.displayName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlatformInfo.fromJson(Map<String, dynamic> json) {
    return PlatformInfo(
      id: json['id'],
      name: json['name'],
      displayName: json['displayName'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}