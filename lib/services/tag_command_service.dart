import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/dio_service.dart';

class TagCommandService {
  static Future<void> createTag({
    required BuildContext context,
    required String name,
    required bool isPublic,
  }) async {
    try {
      final dio = DioService.instance;
      await dio.post(
        '/tags',
        data: {
          'name': name,
          'isPublic': isPublic,
        },
      );
    } catch (e) {
      debugPrint('Error creating tag: $e');
      rethrow;
    }
  }

  static Future<void> shareTag({
    required BuildContext context,
    required String tagId,
    required int sharedWithId,
    required String permission,
  }) async {
    try {
      final dio = DioService.instance;
      await dio.post(
        '/tags/$tagId/share',
        data: {
          'sharedWithId': sharedWithId,
          'permission': permission,
        },
      );
    } catch (e) {
      debugPrint('Error sharing tag: $e');
      rethrow;
    }
  }
}
