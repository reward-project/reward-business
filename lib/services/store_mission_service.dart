import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/dio_service.dart';
import '../models/store_mission/platform_info.dart';
import '../models/store_mission/reward_info.dart';
import '../models/store_mission/store_info.dart';
import '../models/store_mission/registrant_info.dart';
import '../models/store_mission/store_mission_response.dart';
import '../models/store_mission/store_mission_stats.dart';

class StoreMissionService {
  static Future<Map<String, dynamic>> createStoreMission({
    required BuildContext context,
    required String rewardName,
    required int platformId,
    required String storeName,
    required String productLink,
    required String keyword,
    required String productId,
    required String optionId,
    required DateTime startDate,
    required DateTime endDate,
    required String registrantId,
    required double rewardAmount,
    required int maxRewardsPerDay,
    required List<String> tags,
  }) async {
    try {
      final dio = DioService.getInstance(context);

      // 요청 데이터 로깅
      debugPrint('Creating store mission with data:');
      debugPrint({
        'rewardName': rewardName,
        'platformId': platformId,
        'storeName': storeName,
        'registrantName': registrantId,
        'productLink': productLink,
        'keyword': keyword,
        'productId': productId,
        'optionId': optionId,
        'startDate': startDate.toIso8601String().split('T')[0],
        'endDate': endDate.toIso8601String().split('T')[0],
        'registrantId': registrantId,
        'rewardAmount': rewardAmount,
        'maxRewardsPerDay': maxRewardsPerDay,
        'tags': tags,
      }.toString());

      if (!Uri.parse(productLink).hasScheme) {
        throw Exception('올바른 URL 형식이 아닙니다. 전체 URL을 입력해주세요.');
      }

      final response = await dio.post(
        '/store-missions',
        data: {
          'rewardName': rewardName,
          'platformId': platformId,
          'storeName': storeName,
          'registrantName': registrantId,
          'productLink': productLink,
          'keyword': keyword,
          'productId': productId,
          'optionId': optionId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
          'registrantId': registrantId,
          'rewardAmount': rewardAmount,
          'maxRewardsPerDay': maxRewardsPerDay,
          'tags': tags,
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('리워드 등록에 실패했습니다. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating store mission: $e');
      rethrow;
    }
  }



  static Future<List<StoreMissionResponse>> getStoreMissionsByRegistrant(BuildContext context, String registrantId) async {
    try {
      final dio = DioService.getInstance(context);
      final response = await dio.get('/store-missions/registrant/$registrantId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => StoreMissionResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load store missions');
      }
    } catch (e) {
      debugPrint('Error getting store missions: $e');
      rethrow;
    }
  }

  static Future<StoreMissionStats> getStoreMissionStats(BuildContext context, String registrantId) async {
    try {
      final missions = await getStoreMissionsByRegistrant(context, registrantId);
      
      int total = missions.length;
      int active = missions.where((m) => m.status == 'ACTIVE').length;
      int completed = missions.where((m) => m.status == 'COMPLETED').length;
      double successRate = total > 0 ? (completed / total) * 100 : 0;

      return StoreMissionStats(
        totalMissions: total,
        activeMissions: active,
        completedMissions: completed,
        successRate: successRate,
      );
    } catch (e) {
      debugPrint('Error getting store mission stats: $e');
      rethrow;
    }
  }

  static Future<void> updateStoreMissionStatus(
    BuildContext context, 
    String missionId, 
    String newStatus
  ) async {
    try {
      final dio = DioService.getInstance(context);
      await dio.patch(
        '/store-missions/$missionId/status',
        data: {'status': newStatus},
      );
    } catch (e) {
      debugPrint('Error updating store mission status: $e');
      rethrow;
    }
  }

  static Future<void> deleteStoreMissions(
    BuildContext context,
    List<String> missionIds,
  ) async {
    try {
      final dio = DioService.getInstance(context);
      await dio.delete(
        '/store-missions',
        data: {'missionIds': missionIds},
      );
    } catch (e) {
      debugPrint('Error deleting store missions: $e');
      rethrow;
    }
  }

  static Exception _handleDioError(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      final errorData = e.response?.data as Map;
      final message = errorData['message'] ?? 'Unknown error occurred';
      return Exception(message);
    }
    return Exception('Failed to create store mission: ${e.message}');
  }
}
