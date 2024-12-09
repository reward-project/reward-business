import 'package:flutter/foundation.dart';

class StoreMissionResponse {
  final int id;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PlatformInfo platform;
  final RewardInfo reward;
  final StoreInfo store;
  final RegistrantInfo registrant;
  final List<String> tags;
  final int totalRewardUsage;
  final int remainingRewardBudget;

  StoreMissionResponse({
    required this.id,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.platform,
    required this.reward,
    required this.store,
    required this.registrant,
    required this.tags,
    required this.totalRewardUsage,
    required this.remainingRewardBudget,
  });

  factory StoreMissionResponse.fromJson(Map<String, dynamic>? json) {
    try {
      if (json == null) {
        throw Exception('Null JSON data');
      }
      debugPrint('Parsing StoreMissionResponse: $json');
      return StoreMissionResponse(
        id: json['id'] is int ? json['id'] : int.parse(json['id']?.toString() ?? '0'),
        status: json['status']?.toString() ?? 'UNKNOWN',
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        platform: PlatformInfo.fromJson(json['platform']),
        reward: RewardInfo.fromJson(json['reward']),
        store: StoreInfo.fromJson(json['store']),
        registrant: RegistrantInfo.fromJson(json['registrant']),
        tags: _parseTags(json['tags']),
        totalRewardUsage: _parseIntValue(json['totalRewardUsage']),
        remainingRewardBudget: _parseIntValue(json['remainingRewardBudget']),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing StoreMissionResponse: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];
    try {
      if (tags is List) {
        return tags.map((tag) => tag?.toString() ?? '').where((tag) => tag.isNotEmpty).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error parsing tags: $e');
      return [];
    }
  }

  static int _parseIntValue(dynamic value) {
    try {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    } catch (e) {
      debugPrint('Error parsing int value: $e');
      return 0;
    }
  }
}

class PlatformInfo {
  final int id;
  final String name;
  final String displayName;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PlatformInfo({
    required this.id,
    required this.name,
    required this.displayName,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory PlatformInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PlatformInfo(
        id: 0,
        name: 'Unknown',
        displayName: 'Unknown',
        status: 'UNKNOWN',
        createdAt: DateTime.now(),
      );
    }
    return PlatformInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      displayName: json['displayName'] ?? 'Unknown',
      status: json['status'] ?? 'UNKNOWN',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class RewardInfo {
  final String? rewardId;
  final String rewardName;
  final double rewardAmount;
  final int maxRewardsPerDay;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  RewardInfo({
    this.rewardId,
    required this.rewardName,
    required this.rewardAmount,
    required this.maxRewardsPerDay,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory RewardInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RewardInfo(
        rewardName: 'Unknown',
        rewardAmount: 0.0,
        maxRewardsPerDay: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        status: 'UNKNOWN',
      );
    }
    return RewardInfo(
      rewardId: json['rewardId'],
      rewardName: json['rewardName'] ?? 'Unknown',
      rewardAmount: (json['rewardAmount'] ?? 0.0).toDouble(),
      maxRewardsPerDay: json['maxRewardsPerDay'] ?? 0,
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'UNKNOWN',
    );
  }
}

class StoreInfo {
  final String storeName;
  final String productLink;
  final String keyword;
  final String productId;
  final String optionId;
  final String? storeStatus;

  StoreInfo({
    required this.storeName,
    required this.productLink,
    required this.keyword,
    required this.productId,
    required this.optionId,
    this.storeStatus,
  });

  factory StoreInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StoreInfo(
        storeName: 'Unknown',
        productLink: '',
        keyword: '',
        productId: '',
        optionId: '',
      );
    }
    return StoreInfo(
      storeName: json['storeName'] ?? 'Unknown',
      productLink: json['productLink'] ?? '',
      keyword: json['keyword'] ?? '',
      productId: json['productId'] ?? '',
      optionId: json['optionId'] ?? '',
      storeStatus: json['storeStatus'],
    );
  }
}

class RegistrantInfo {
  final int? registrantId;
  final String? registrantName;
  final String? registrantEmail;
  final String? registrantRole;

  RegistrantInfo({
    this.registrantId,
    this.registrantName,
    this.registrantEmail,
    this.registrantRole,
  });

  factory RegistrantInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RegistrantInfo();
    }
    return RegistrantInfo(
      registrantId: json['registrantId'],
      registrantName: json['registrantName'],
      registrantEmail: json['registrantEmail'],
      registrantRole: json['registrantRole'],
    );
  }
}
