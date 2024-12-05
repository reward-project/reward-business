class Reward {
  final String rewardId;
  final String advertiserId;
  final String rewardStatus;
  final String productUrl;
  final String keyword;
  final String advertiserChannel;
  final dynamic rewardProductPrice;
  final dynamic rewardPoint;
  final String productId;
  final String optionId;
  final String productName;
  final String priceComparison;
  final String rewardStartDate;
  final String rewardEndDate;
  final dynamic inflowCount;
  final dynamic actualInflowCount;
  final String rewardMemo;

  Reward({
    required this.rewardId,
    required this.advertiserId,
    required this.rewardStatus,
    required this.productUrl,
    required this.keyword,
    required this.advertiserChannel,
    required this.rewardProductPrice,
    required this.rewardPoint,
    required this.productId,
    required this.optionId,
    required this.productName,
    required this.priceComparison,
    required this.rewardStartDate,
    required this.rewardEndDate,
    required this.inflowCount,
    required this.actualInflowCount,
    required this.rewardMemo,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      rewardId: json['rewardId'] ?? '',
      advertiserId: json['advertiserId'] ?? '',
      rewardStatus: json['rewardStatus'] ?? '',
      productUrl: json['productUrl'] ?? '',
      keyword: json['keyword'] ?? '',
      advertiserChannel: json['advertiserChannel'] ?? '',
      rewardProductPrice: json['rewardProductPrice'],
      rewardPoint: json['rewardPoint'],
      productId: json['productId'] ?? '',
      optionId: json['optionId'] ?? '',
      productName: json['productName'] ?? '',
      priceComparison: json['priceComparison'] ?? '',
      rewardStartDate: json['rewardStartDate'] ?? '',
      rewardEndDate: json['rewardEndDate'] ?? '',
      inflowCount: json['inflowCount'],
      actualInflowCount: json['actualInflowCount'],
      rewardMemo: json['rewardMemo'] ?? '',
    );
  }
} 