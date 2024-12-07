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
}
