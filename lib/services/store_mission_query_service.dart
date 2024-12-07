import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:reward/models/store_mission/store_mission_response.dart';
import 'package:reward/models/store_mission/store_mission_stats.dart';
import '../services/dio_service.dart';
import '../models/store_mission.dart';

class StoreMissionQueryService {
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


  static Future<List<StoreMission>> getStoreMissions({
    required BuildContext context,
    String? status,
    String? platform,
    String? searchQuery,
  }) async {
    try {
      final dio = DioService.getInstance(context);
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
      final dio = DioService.getInstance(context);
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
      final dio = DioService.getInstance(context);
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

  static Future<StoreMissionStats> getStoreMissionStats(BuildContext context, String registrantId) async {
    try {
      final missions = await getStoreMissionsByRegistrant(context, registrantId);
      
      int total = missions.length;
      int active = missions.where((m) => m.reward.status == 'ACTIVE').length;
      int completed = missions.where((m) => m.reward.status == 'COMPLETED').length;
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
} 