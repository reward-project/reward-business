import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/dio_service.dart';

class TagQueryService {
  static Future<List<String>> searchTags({
    required BuildContext context,
    required String query,
    bool? isPublic,
  }) async {
    try {
      final dio = DioService.getInstance(context);
      final response = await dio.get(
        '/tags/search',
        queryParameters: {
          'query': query,
          if (isPublic != null) 'isPublic': isPublic,
        },
      );

      if (response.data['success']) {
        return (response.data['data'] as List)
            .map((tag) => tag.toString())
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error searching tags: $e');
      return [];
    }
  }

  static Future<List<String>> getMyTags(BuildContext context) async {
    try {
      final dio = DioService.getInstance(context);
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
      final dio = DioService.getInstance(context);
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