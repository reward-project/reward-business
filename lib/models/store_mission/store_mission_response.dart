import 'platform_info.dart';
import 'reward_info.dart';
import 'store_info.dart';
import 'registrant_info.dart';

class StoreMissionResponse {
  final int id;
  final String status;
  final PlatformInfo platform;
  final RewardInfo reward;
  final StoreInfo store;
  final RegistrantInfo registrant;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreMissionResponse({
    required this.id,
    required this.status,
    required this.platform,
    required this.reward,
    required this.store,
    required this.registrant,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreMissionResponse.fromJson(Map<String, dynamic> json) {
    return StoreMissionResponse(
      id: json['id'] as int,
      status: json['status'] as String,
      platform: PlatformInfo.fromJson(json['platform'] as Map<String, dynamic>),
      reward: RewardInfo.fromJson(json['reward'] as Map<String, dynamic>),
      store: StoreInfo.fromJson(json['store'] as Map<String, dynamic>),
      registrant: RegistrantInfo.fromJson(json['registrant'] as Map<String, dynamic>),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'platform': platform.toJson(),
      'reward': reward.toJson(),
      'store': store.toJson(),
      'registrant': registrant.toJson(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}