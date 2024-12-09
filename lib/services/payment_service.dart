import 'package:dio/dio.dart';
import 'package:reward/config/app_config.dart';
import 'package:reward/models/payment_response.dart';

class PaymentService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  Future<PaymentResponse> requestKakaoPayment({
    required double amount,
    required String itemName,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/payments/kakao/ready',
        data: {
          'amount': amount,
          'itemName': itemName,
        },
      );

      return PaymentResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentResponse> requestTossPayment({
    required double amount,
    required String itemName,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/payments/toss/ready',
        data: {
          'amount': amount,
          'itemName': itemName,
        },
      );

      return PaymentResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
} 