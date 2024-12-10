import 'package:reward/models/payment_response.dart';
import 'package:reward/services/dio_service.dart';

class PaymentService {
  Future<PaymentResponse> requestKakaoPayment({
    required double amount,
    required String itemName,
  }) async {
    try {
      final response = await DioService.instance.post(
        '/payments/kakao/ready',
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

  Future<PaymentResponse> processNaverPayment(double amount, String itemName) async {
    try {
      final response = await DioService.instance.post('/payments/naver/request', 
        data: {
          'amount': amount,
          'itemName': itemName,
        }
      );

      return PaymentResponse.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyNaverPayment({
    required String paymentKey,
    required String orderId,
  }) async {
    try {
      await DioService.instance.post(
        '/payments/naver/verify',
        data: {
          'paymentKey': paymentKey,
          'orderId': orderId,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
