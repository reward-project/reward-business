import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/dio_service.dart';
import 'package:intl/intl.dart'; // Added import for DateFormat
import 'package:dio/dio.dart';

class StoreMissionCommandService {
  static Future<void> createStoreMission({
    required BuildContext context,
    required Map<String, dynamic> formData,
  }) async {
    try {
      final locale = Localizations.localeOf(context).languageCode;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = await authProvider.user;

      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await DioService.instance.post(
        '/store-missions',
        data: {
          'platformId': formData['platformId'],
          'rewardName': formData['rewardName'],
          'storeName': formData['storeName'],
          'productLink': formData['productLink'],
          'keyword': formData['keyword'],
          'productId': formData['productId'],
          'rewardAmount': formData['rewardAmount'],
          'maxRewardsPerDay': formData['maxRewardsPerDay'],
          'startDate': formData['startDate'].toIso8601String(),
          'endDate': formData['endDate'].toIso8601String(),
          'registrantId': user.userId,
          'tags': formData['tags'],
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리워드가 성공적으로 등록되었습니다.')),
        );
        context.go('/$locale/sales/store-mission');
      } else {
        throw Exception(response.data['message'] ?? '리워드 등록에 실패했습니다.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      rethrow;
    }
  }

  static Future<void> updateStoreMission({
    required BuildContext context,
    required int id,
    required Map<String, dynamic> formData,
  }) async {
    try {
      final locale = Localizations.localeOf(context).languageCode;
      final request = {
        'id': id,
        'rewardName': formData['rewardName'],
        'platformId': formData['platformId'],
        'storeName': formData['storeName'],
        'productLink': formData['productLink'],
        'keyword': formData['keyword'],
        'productId': formData['productId'],
        'rewardAmount': formData['rewardAmount'],
        'maxRewardsPerDay': formData['maxRewardsPerDay'],
        'startDate': formData['startDate'].toString().split(' ')[0],
        'endDate': formData['endDate'].toString().split(' ')[0],
        'tags': formData['tags'],
      };

      final response = await DioService.instance.put(
        '/store-missions/$id',
        data: request,
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('미션이 성공적으로 수정되었습니다.')),
          );
          context.go('/$locale/sales/store-mission');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('미션 수정 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  static Future<void> deleteStoreMission({
    required BuildContext context,
    required int id,
  }) async {
    try {
      await DioService.instance.delete('/store-missions/$id');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('미션이 삭제되었습니다.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = '미션 삭제 중 오류가 발생했습니다';
        
        if (e is DioException && e.response?.data != null) {
          final responseData = e.response!.data;
          if (responseData['message'] != null) {
            errorMessage = responseData['message'];
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  static Future<void> deleteStoreMissions({
    required BuildContext context,
    required List<int> ids,
  }) async {
    try {
      await DioService.instance.delete(
        '/store-missions',
        data: {'missionIds': ids},
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('선택한 미션이 삭제되었습니다.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = '미션 삭제 중 오류가 발생했습니다';
        
        if (e is DioException && e.response?.data != null) {
          final responseData = e.response!.data;
          if (responseData['message'] != null) {
            errorMessage = responseData['message'];
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

}
