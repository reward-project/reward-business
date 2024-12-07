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
  
  // 사용량 관련 필드 추가
  final int totalUsageCount;      // 총 사용 횟수
  final int todayUsageCount;      // 오늘 사용 횟수
  final double usageRate;         // 사용률
  final Map<String, int> usageByHour;  // 시간대별 사용량
  final Map<String, int> usageByDay;   // 요일별 사용량
  final List<RewardUsage> recentUsages; // 최근 사용 이력

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
    required this.totalUsageCount,
    required this.todayUsageCount,
    required this.usageRate,
    required this.usageByHour,
    required this.usageByDay,
    required this.recentUsages,
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
      totalUsageCount: json['totalUsageCount'] ?? 0,
      todayUsageCount: json['todayUsageCount'] ?? 0,
      usageRate: (json['usageRate'] ?? 0).toDouble(),
      usageByHour: Map<String, int>.from(json['usageByHour'] ?? {}),
      usageByDay: Map<String, int>.from(json['usageByDay'] ?? {}),
      recentUsages: (json['recentUsages'] as List?)
          ?.map((e) => RewardUsage.fromJson(e))
          .toList() ?? [],
    );
  }
}

class RewardUsage {
  final DateTime timestamp;
  final String userId;
  final String userName;
  final double amount;
  final String status;

  RewardUsage({
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.status,
  });

  factory RewardUsage.fromJson(Map<String, dynamic> json) {
    return RewardUsage(
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      userName: json['userName'],
      amount: json['amount'].toDouble(),
      status: json['status'],
    );
  }
} 