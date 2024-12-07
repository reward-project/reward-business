import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/dio_service.dart';
import '../models/store_mission.dart';

class StoreMissionQueryService {
  static Future<List<StoreMission>> getStoreMissions({
    required BuildContext context,
    String? status,
    String? platform,
    String? searchQuery,
  }) async {
    try {
      final dio = DioService.getInstance(context);
      final response = await dio.get(
        '/api/v1/store-missions',
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
      final response = await dio.get('/api/v1/store-missions/$missionId');
      
      if (response.data['success']) {
        return StoreMission.fromJson(response.data['data']);
      }
      throw Exception(response.data['message']);
    } catch (e) {
      debugPrint('Error fetching store mission: $e');
      rethrow;
    }
  }

  static Future<List<StoreMission>> getStoreMissionsByTag(
    BuildContext context,
    String tag,
  ) async {
    try {
      final dio = DioService.getInstance(context);
      final response = await dio.get('/api/v1/store-missions/tags/$tag');
      
      if (response.statusCode == 200 && response.data['success']) {
        return (response.data['data'] as List)
            .map((item) => StoreMission.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting store missions by tag: $e');
      rethrow;
    }
  }
} 