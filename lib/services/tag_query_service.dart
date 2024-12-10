import 'package:flutter/material.dart';
import '../services/dio_service.dart';

class TagQueryService {
  static Future<List<String>> searchTags(
      BuildContext context, String query) async {
    try {
      final dio = DioService.instance;
      final response = await dio.get('/tags/search/private', queryParameters: {
        'query': query,
      });

      if (response.statusCode == 200) {
        if (response.data is Map) {
          // ApiResponse로 감싸진 경우
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

  static Future<List<String>> getMyTags(BuildContext context) async {
    try {
      final dio = DioService.instance;
      final response = await dio.get('/tags/my');

      if (response.data['success']) {
        return (response.data['data'] as List)
            .map((tag) => tag.toString())
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting my tags: $e');
      return [];
    }
  }

  static Future<List<String>> getPopularTags(BuildContext context) async {
    try {
      final dio = DioService.instance;
      final response = await dio.get('/tags/popular');

      if (response.data['success']) {
        return (response.data['data'] as List)
            .map((tag) => tag.toString())
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting popular tags: $e');
      return [];
    }
  }
}
