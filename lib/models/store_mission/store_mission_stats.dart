class StoreMissionStats {
  final int totalMissions;
  final int activeMissions;
  final int completedMissions;
  final double successRate;
  final double totalRewardAmount;
  final double averageRewardAmount;
  final Map<String, int> missionsByPlatform;
  final List<DailyRewardStats> dailyStats;
  final int totalUsageCount;
  final int todayUsageCount;
  final double usageRate;
  final Map<String, int> usageByHour;
  final Map<String, int> usageByDay;
  final List<UsageStats> recentUsage;

  StoreMissionStats({
    required this.totalMissions,
    required this.activeMissions,
    required this.completedMissions,
    required this.successRate,
    required this.totalRewardAmount,
    required this.averageRewardAmount,
    required this.missionsByPlatform,
    required this.dailyStats,
    required this.totalUsageCount,
    required this.todayUsageCount,
    required this.usageRate,
    required this.usageByHour,
    required this.usageByDay,
    required this.recentUsage,
  });

  factory StoreMissionStats.fromJson(Map<String, dynamic> json) {
    return StoreMissionStats(
      totalMissions: json['totalMissions'] as int,
      activeMissions: json['activeMissions'] as int,
      completedMissions: json['completedMissions'] as int,
      successRate: (json['successRate'] as num).toDouble(),
      totalRewardAmount: (json['totalRewardAmount'] as num).toDouble(),
      averageRewardAmount: (json['averageRewardAmount'] as num).toDouble(),
      missionsByPlatform: Map<String, int>.from(json['missionsByPlatform'] as Map),
      dailyStats: (json['dailyStats'] as List<dynamic>)
          .map((e) => DailyRewardStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalUsageCount: json['totalUsageCount'] as int,
      todayUsageCount: json['todayUsageCount'] as int,
      usageRate: (json['usageRate'] as num).toDouble(),
      usageByHour: Map<String, int>.from(json['usageByHour'] as Map),
      usageByDay: Map<String, int>.from(json['usageByDay'] as Map),
      recentUsage: (json['recentUsage'] as List<dynamic>)
          .map((e) => UsageStats.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DailyRewardStats {
  final DateTime date;
  final int rewardCount;
  final double rewardAmount;

  DailyRewardStats({
    required this.date,
    required this.rewardCount,
    required this.rewardAmount,
  });

  factory DailyRewardStats.fromJson(Map<String, dynamic> json) {
    return DailyRewardStats(
      date: DateTime.parse(json['date'] as String),
      rewardCount: json['rewardCount'] as int,
      rewardAmount: (json['rewardAmount'] as num).toDouble(),
    );
  }
}

class UsageStats {
  final DateTime timestamp;
  final String platform;
  final String storeName;
  final double amount;
  final String status;

  UsageStats({
    required this.timestamp,
    required this.platform,
    required this.storeName,
    required this.amount,
    required this.status,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    return UsageStats(
      timestamp: DateTime.parse(json['timestamp'] as String),
      platform: json['platform'] as String,
      storeName: json['storeName'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
    );
  }
}
