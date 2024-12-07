class RewardInfo {
  final String rewardId;
  final String rewardName;
  final double rewardAmount;
  final int maxRewardsPerDay;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  RewardInfo({
    required this.rewardId,
    required this.rewardName,
    required this.rewardAmount,
    required this.maxRewardsPerDay,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory RewardInfo.fromJson(Map<String, dynamic> json) {
    return RewardInfo(
      rewardId: json['rewardId'],
      rewardName: json['rewardName'],
      rewardAmount: json['rewardAmount'].toDouble(),
      maxRewardsPerDay: json['maxRewardsPerDay'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rewardId': rewardId,
      'rewardName': rewardName,
      'rewardAmount': rewardAmount,
      'maxRewardsPerDay': maxRewardsPerDay,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
    };
  }
}