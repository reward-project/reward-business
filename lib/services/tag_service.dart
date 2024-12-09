import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:reward/models/tag/tag_share_request.dart';
import 'package:reward/services/dio_service.dart';
import 'package:reward/services/dio_service.dart';
import 'package:reward/models/tag/tag_share_request.dart';

class TagService {
  static Future<void> shareTag({
    required BuildContext context,
    required String tagId,
    required TagShareRequest request,
  }) async {
    try {
      final dio = DioService.instance;
      await dio.post('/tags/$tagId/share', data: request.toJson());
    } catch (e) {
      debugPrint('Error sharing tag: $e');
      rethrow;
    }
  }
}
