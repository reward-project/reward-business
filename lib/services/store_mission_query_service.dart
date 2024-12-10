import 'package:flutter/material.dart';
import 'package:reward/models/store_mission/store_mission_response.dart';
import 'package:reward/models/store_mission/store_mission_stats.dart';
import '../services/dio_service.dart';
import '../models/store_mission.dart';

class StoreMissionQueryService {
  static Future<List<StoreMissionResponse>> getStoreMissionsByRegistrant(
      BuildContext context, String registrantId) async {
    debugPrint('=== Starting API call to get store missions ===');
    try {
      final dio = DioService.instance;
      debugPrint('Dio instance created');
      debugPrint(
          'Making GET request to: ${dio.options.baseUrl}/api/v1/store-missions/my');
      debugPrint('Headers: ${dio.options.headers}');

      final response = await dio.get('/store-missions/my');
      debugPrint('Response received - Status: ${response.statusCode}');
      debugPrint('Response data type: ${response.data.runtimeType}');
      debugPrint('Response data structure: ${response.data.toString()}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success']) {
          final List<dynamic> data = responseData['data'];
          debugPrint(
              'Data item example: ${data.isNotEmpty ? data[0].toString() : "No data"}');
          return data.map((json) {
            debugPrint('Processing item: $json');
            try {
              return StoreMissionResponse.fromJson(json);
            } catch (e, stackTrace) {
              debugPrint('Error parsing item: $e');
              debugPrint('Stack trace: $stackTrace');
              rethrow;
            }
          }).toList();
        }
        throw Exception(
            responseData['message'] ?? 'Failed to load store missions');
      } else {
        throw Exception('Failed to load store missions');
      }
    } catch (e, stackTrace) {
      debugPrint('Error getting store missions: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<StoreMission>> getStoreMissions({
    required BuildContext context,
    String? status,
    String? platform,
    String? searchQuery,
  }) async {
    try {
      final dio = DioService.instance;
      final response = await dio.get(
        '/store-missions',
        queryParameters: {
          if (status != null) 'status': status,
          if (platform != null) 'platform': platform,
          if (searchQuery != null) 'query': searchQuery,
        },
      );

      if (response.data['success']) {
        return (response.data['data'] as List)
            .map((item) => StoreMission.fromJson(item))
            .toList();
      }
      throw Exception(response.data['message']);
    } catch (e) {
      debugPrint('Error fetching store missions: $e');
      rethrow;
    }
  }

  static Future<StoreMission> getStoreMissionById(
    BuildContext context,
    String missionId,
  ) async {
    try {
      final dio = DioService.instance;
      final response = await dio.get('/store-missions/$missionId');

      if (response.data['success']) {
        return StoreMission.fromJson(response.data['data']);
      }
      throw Exception(response.data['message']);
    } catch (e) {
      debugPrint('Error fetching store mission: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getStoreMissionsByTag(
    BuildContext context,
    String tag,
  ) async {
    try {
      final dio = DioService.instance;
      final response = await dio.get('/store-missions/tags/$tag');
      if (response.statusCode == 200 && response.data['success']) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting store missions by tag: $e');
      rethrow;
    }
  }

  static Future<StoreMissionStats> getStoreMissionStats(
      BuildContext context, String registrantId) async {
    try {
      final missions =
          await getStoreMissionsByRegistrant(context, registrantId);

      int total = missions.length;
      int completed = missions.where((m) => m.status == 'COMPLETED').length;
      int active = missions.where((m) => m.status == 'ACTIVE').length;

      double totalReward =
          missions.fold(0, (sum, m) => sum + m.reward.rewardAmount);
      double avgReward = total > 0 ? totalReward / total : 0;
      double successRate = total > 0 ? (completed / total) * 100 : 0;

      int totalUsageAmount =
          missions.fold(0, (sum, m) => sum + m.totalRewardUsage);
      int remainingBudget =
          missions.fold(0, (sum, m) => sum + m.remainingRewardBudget);

      return StoreMissionStats(
        totalMissions: total,
        activeMissions: active,
        completedMissions: completed,
        totalRewardAmount: totalReward,
        averageRewardAmount: avgReward,
        successRate: successRate,
        totalUsageCount: missions.length,
        todayUsageCount: 0,
        usageRate: 0.0,
        missionsByPlatform: _calculateMissionsByPlatform(missions),
        dailyStats: [],
        usageByHour: <String, int>{},
        usageByDay: <String, int>{},
        recentUsage: [],
      );
    } catch (e) {
      debugPrint('Error getting store mission stats: $e');
      rethrow;
    }
  }

  static Map<String, int> _calculateMissionsByPlatform(
      List<StoreMissionResponse> missions) {
    final Map<String, int> result = {};
    for (var mission in missions) {
      final platform = mission.platform.name;
      result[platform] = (result[platform] ?? 0) + 1;
    }
    return result;
  }
}
