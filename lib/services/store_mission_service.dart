import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dio_service.dart';

class StoreMissionService {
  static Future<Map<String, dynamic>> createStoreMission({
    required BuildContext context,
    required String rewardName,
    required String platform,
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
  }) async {
    try {
      final dio = DioService.getInstance(context);
      
      final response = await dio.post(
        '/store-missions',
        data: {
          'rewardName': rewardName,
          'platform': _convertPlatform(platform),
          'storeName': storeName,
          'registrantName': registrantId, // Using registrantId as name for now
          'productLink': productLink,
          'keyword': keyword,
          'productId': productId,
          'optionId': optionId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
          'registrantId': registrantId,
          'rewardAmount': rewardAmount,
          'maxRewardsPerDay': maxRewardsPerDay,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static String _convertPlatform(String koreanPlatform) {
    switch (koreanPlatform) {
      case '쿠팡':
        return 'COUPANG';
      case '네이버':
        return 'NAVER';
      case '지마켓':
        return 'GMARKET';
      default:
        throw Exception('Unsupported platform: $koreanPlatform');
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
