class StoreMission {
  final String id;
  final String title;
  final String status;
  final String platform;
  final String productName;
  final double rewardAmount;
  final DateTime startDate;
  final DateTime endDate;
  final String productUrl;
  final String keyword;

  StoreMission({
    required this.id,
    required this.title,
    required this.status,
    required this.platform,
    required this.productName,
    required this.rewardAmount,
    required this.startDate,
    required this.endDate,
    required this.productUrl,
    required this.keyword,
  });

  factory StoreMission.fromJson(Map<String, dynamic> json) {
    return StoreMission(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      platform: json['platform'],
      productName: json['productName'],
      rewardAmount: json['rewardAmount'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      productUrl: json['productUrl'],
      keyword: json['keyword'],
    );
  }
} 