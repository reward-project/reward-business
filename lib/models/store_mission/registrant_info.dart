class RegistrantInfo {
  final String registrantId;
  final String registrantName;

  RegistrantInfo({
    required this.registrantId,
    required this.registrantName,
  });

  factory RegistrantInfo.fromJson(Map<String, dynamic> json) {
    return RegistrantInfo(
      registrantId: json['registrantId'],
      registrantName: json['registrantName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registrantId': registrantId,
      'registrantName': registrantName,
    };
  }
}