class StoreInfo {
  final String storeName;
  final String productLink;
  final String keyword;
  final String productId;
  final String optionId;
  final String storeStatus;

  StoreInfo({
    required this.storeName,
    required this.productLink,
    required this.keyword,
    required this.productId,
    required this.optionId,
    required this.storeStatus,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      storeName: json['storeName'],
      productLink: json['productLink'],
      keyword: json['keyword'],
      productId: json['productId'],
      optionId: json['optionId'],
      storeStatus: json['storeStatus'],
    );
  }
} 