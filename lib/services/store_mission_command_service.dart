import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/dio_service.dart';

class StoreMissionCommandService {
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
    required double totalBudget,
    required int maxRewardsPerDay,
    required List<String> tags,
  }) async {
    try {
      final dio = DioService.instance;

      if (!Uri.parse(productLink).hasScheme) {
        throw Exception('올바른 URL 형식이 아닙니다. 전체 URL을 입력해주세요.');
      }

      final response = await dio.post(
        '/store-missions',
        data: {
          'rewardName': rewardName,
          'platformId': platformId,
          'storeName': storeName,
          'productLink': productLink,
          'keyword': keyword,
          'productId': productId,
          'optionId': optionId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
          'registrantId': int.parse(registrantId),
          'rewardAmount': rewardAmount,
          'totalBudget': totalBudget,
          'maxRewardsPerDay': maxRewardsPerDay,
          'tags': tags,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('리워드 등록에 실패했습니다. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Dio error creating store mission: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('Error creating store mission: $e');
      rethrow;
    }
  }

  static Future<void> updateMissionStatus({
    required BuildContext context,
    required int missionId,
    required String newStatus,
  }) async {
    try {
      final dio = DioService.instance;
      await dio.patch(
        '/store-missions/$missionId/status',
        data: {'status': newStatus},
      );
    } catch (e) {
      debugPrint('Error updating mission status: $e');
      rethrow;
    }
  }

  static Future<void> deleteStoreMissions({
    required BuildContext context,
    required List<int> missionIds,
  }) async {
    try {
      final dio = DioService.instance;
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
