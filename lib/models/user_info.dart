class UserInfo {
  final String userId;
  final String email;
  final String name;
  final double rewardBudget;

  UserInfo({
    required this.userId,
    required this.email,
    required this.name,
    this.rewardBudget = 0.0,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'],
      email: json['email'],
      name: json['name'],
      rewardBudget: (json['rewardBudget'] as num?)?.toDouble() ?? 0.0,
    );
  }
} 