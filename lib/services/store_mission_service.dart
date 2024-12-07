import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/dio_service.dart';
import '../models/store_mission/platform_info.dart';
import '../models/store_mission/reward_info.dart';
import '../models/store_mission/store_info.dart';
import '../models/store_mission/registrant_info.dart';
import '../models/store_mission/store_mission_response.dart';

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

  static StoreMissionResponse parseResponse(Map<String, dynamic> json) {
    return StoreMissionResponse(
      id: json['id'],
      platform: PlatformInfo.fromJson(json['platform']),
      reward: RewardInfo.fromJson(json['reward']),
      store: StoreInfo.fromJson(json['store']),
      registrant: RegistrantInfo.fromJson(json['registrant']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
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

  static Future<List<String>> searchTags(BuildContext context, String query) async {
    try {
      final dio = DioService.getInstance(context);
      final response = await dio.get('/tags/search/private', queryParameters: {
        'query': query,
      });

      if (response.statusCode == 200) {
        if (response.data is Map) {  // ApiResponse로 감싸진 경우
          final List<dynamic> tagsData = response.data['data'] ?? [];
          return tagsData.map((tag) => tag.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error searching tags: $e');
      return [];
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
