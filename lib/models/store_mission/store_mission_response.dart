import 'platform_info.dart';
import 'reward_info.dart';
import 'store_info.dart';
import 'registrant_info.dart';

class StoreMissionResponse {
  final int id;
  final PlatformInfo platform;
  final RewardInfo reward;
  final StoreInfo store;
  final RegistrantInfo registrant;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreMissionResponse({
    required this.id,
    required this.platform,
    required this.reward,
    required this.store,
    required this.registrant,
    required this.createdAt,
    required this.updatedAt,
  });
} 