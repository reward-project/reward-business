class PaymentResponse {
  final String? paymentKey;
  final String? orderId;
  final String? successUrl;

  PaymentResponse({
    this.paymentKey,
    this.orderId,
    this.successUrl,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      paymentKey: json['paymentKey'],
      orderId: json['orderId'],
      successUrl: json['successUrl'],
    );
  }
} 