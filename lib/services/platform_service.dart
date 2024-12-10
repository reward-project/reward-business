import 'package:flutter/material.dart';
import '../models/platform/platform.dart';
import 'dio_service.dart';
import 'package:dio/dio.dart';

class PlatformService {
  Future<Platform> registerPlatform(BuildContext context, String name,
      String displayName, List<String> domains) async {
    try {
      for (var domain in domains) {
        if (!await isDomainAvailable(context, domain)) {
          throw Exception('도메인 중복 확인에 실패했습니다: $domain');
        }
      }

      final dio = DioService.instance;
      final response = await dio.post(
        '/platforms',
        data: {
          'name': name,
          'displayName': displayName,
          'domains': domains,
        },
      );

      return Platform.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('플랫폼 등록 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  Future<bool> isDomainAvailable(BuildContext context, String domain) async {
    try {
      final dio = DioService.instance;
      final response =
          await dio.get('/platforms/domains/check', queryParameters: {
        'domain': domain,
      });

      return response.data['available'] ?? false;
    } catch (e) {
      throw Exception('도메인 중복 확인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  Future<List<Platform>> getPlatforms(BuildContext context) async {
    try {
      final dio = DioService.instance;
      print('Sending request to /api/v1/platforms/active');

      final response = await dio.get(
        '/platforms/active',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      print('Response headers: ${response.headers}');
      print('Response status: ${response.statusCode}');
      print('Response data type: ${response.data.runtimeType}');
      print('Raw response data: ${response.data}');

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data is List) {
        return (response.data as List)
            .map((x) => Platform.fromJson(x as Map<String, dynamic>))
            .toList();
      }

      throw Exception(
          'Expected List but got ${response.data.runtimeType}: ${response.data}');
    } catch (e, stackTrace) {
      print('Error in getPlatforms: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Exception _handleDioError(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      final errorData = e.response?.data as Map;
      final message = errorData['message'] ?? 'Unknown error occurred';
      return Exception(message);
    }
    return Exception('Failed to process request: ${e.message}');
  }

  Future<List<Platform>> searchPlatforms(
      BuildContext context, String searchTerm) async {
    try {
      final dio = DioService.instance;
      final response = await dio.get(
        '/platforms/search',
        queryParameters: {
          'searchTerm': searchTerm,
        },
      );

      return (response.data as List)
          .map((item) => Platform.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('플랫폼 검색 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getPlatformDomains(
      BuildContext context, String platformId) async {
    try {
      final dio = DioService.instance;
      final response = await dio.get('/platforms/$platformId/domains');

      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('도메인 목록 조회 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  Future<Platform?> updatePlatform(BuildContext context, String id, String name,
      String displayName, List<String> newDomains) async {
    final dio = DioService.instance;

    // ID가 유효한 숫자인지 확인
    final platformId = int.tryParse(id);
    if (platformId == null) {
      return null;
    }

    try {
      // 새로운 도메인 추가
      for (var domain in newDomains) {
        await dio.post(
          '/platforms/$platformId/domains',
          data: {
            'domain': domain,
          },
        );
      }

      // 업데이트된 플랫폼 정보 조회
      final platformResponse = await dio.get('/platforms/$platformId');
      if (platformResponse.data is! Map<String, dynamic>) {
        return null;
      }

      return Platform.fromJson(platformResponse.data as Map<String, dynamic>);
    } on DioException {
      return null;
    }
  }
}
