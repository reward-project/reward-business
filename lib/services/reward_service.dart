import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dio_service.dart';

class RewardService {
  static Future<RewardResponse> createReward({
    required BuildContext context,
    required String name,
    required String registrantId,
    // Add other reward-related fields here
  }) async {
    try {
      final dio = DioService.instance;

      final response = await dio.post(
        '/api/rewards',
        data: {
          'name': name,
          'registrantId': registrantId,
          // Add other reward fields here
        },
      );

      return RewardResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Exception _handleDioError(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      final errorData = e.response?.data as Map;
      final message = errorData['message'] ?? 'Unknown error occurred';
      return Exception(message);
    }
    return Exception('Failed to create reward: ${e.message}');
  }
}

class RewardResponse {
  final String rewardId;
  final String name;
  final String registrantId;
  // Add other reward fields here

  RewardResponse({
    required this.rewardId,
    required this.name,
    required this.registrantId,
  });

  factory RewardResponse.fromJson(Map<String, dynamic> json) {
    return RewardResponse(
      rewardId: json['rewardId'] as String,
      name: json['name'] as String,
      registrantId: json['registrantId'] as String,
    );
  }
}
