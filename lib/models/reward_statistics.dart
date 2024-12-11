class RewardStatistics {
  final int totalRewards;
  final int activeRewards;
  final int pendingRewards;
  final int completedRewards;

  RewardStatistics({
    required this.totalRewards,
    required this.activeRewards,
    required this.pendingRewards,
    required this.completedRewards,
  });

  factory RewardStatistics.fromJson(Map<String, dynamic> json) {
    return RewardStatistics(
      totalRewards: json['totalRewards'] as int,
      activeRewards: json['activeRewards'] as int,
      pendingRewards: json['pendingRewards'] as int,
      completedRewards: json['completedRewards'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRewards': totalRewards,
      'activeRewards': activeRewards,
      'pendingRewards': pendingRewards,
      'completedRewards': completedRewards,
    };
  }
}
