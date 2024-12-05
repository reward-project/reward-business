import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/dio_service.dart';

class RewardWritePage extends StatefulWidget {
  const RewardWritePage({super.key});

  @override
  State<RewardWritePage> createState() => _RewardWritePageState();
}

class _RewardWritePageState extends State<RewardWritePage> {
  final _formKey = GlobalKey<FormState>();
  final rewardSetPoint = 15;
  String? _error;

  final _formData = {
    'advertiserId': '',
    'rewardStatus': '생성',
    'productUrl': '',
    'keyword': '',
    'advertiserChannel': '',
    'rewardProductPrice': '',
    'rewardPoint': '15',
    'productId': '',
    'optionId': '',
    'productName': '',
    'priceComparison': '무',
    'rewardStartDate': '',
    'rewardEndDate': '',
    'inflowCount': '100',
    'rewardMemo': '',
  };

  bool validateDates() {
    if (_formData['rewardStartDate']!.isEmpty || _formData['rewardEndDate']!.isEmpty) {
      setState(() => _error = "시작 날짜와 종료 날짜를 모두 입력해주세요.");
      return false;
    }

    final startDate = DateTime.parse(_formData['rewardStartDate']!);
    final endDate = DateTime.parse(_formData['rewardEndDate']!);
    final today = DateTime.now();
    
    if (startDate.isBefore(today)) {
      setState(() => _error = "시작 날짜는 오늘 이전일 수 없습니다.");
      return false;
    }

    final diffInDays = endDate.difference(startDate).inDays + 1;
    if (![10, 30].contains(diffInDays)) {
      setState(() => _error = "리워드 기간은 시작일과 종료일을 포함하여 10일 또는 30일이어야 합니다.");
      return false;
    }

    setState(() => _error = null);
    return true;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!validateDates()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error ?? "날짜를 확인해주세요")),
      );
      return;
    }

    try {
      final authProvider = context.read<AuthProvider>();
      final salesId = authProvider.user?.userId;
      
      if (salesId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("사용자 정보를 찾을 수 없습니다")),
        );
        return;
      }

      final requestData = {
        ..._formData,
        'salesId': salesId,
        'rewardProductPrice': int.parse(_formData['rewardProductPrice']!),
        'rewardPoint': int.parse(_formData['rewardPoint']!),
        'inflowCount': int.parse(_formData['inflowCount']!),
        'rewardStatus': _formData['rewardStatus'] == '생성' ? 'ACTIVE' : 'INACTIVE',
      };

      final dio = DioService.getInstance(context);
      await dio.post('/my/reward/write', data: requestData);

      if (mounted) {
        final currentLocale = Localizations.localeOf(context).languageCode;
        context.go('/$currentLocale/sales/inspect-listing');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("에러가 발생했습니다: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final currentLocale = Localizations.localeOf(context).languageCode;
            context.go('/$currentLocale/sales/inspect-listing');
          },
        ),
        title: Text(
          '리워드 관리: ${context.read<AuthProvider>().user?.userName ?? ""}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildUrlField(),
                      _buildTwoColumnRow(
                        _buildAdvertiserIdField(),
                        _buildStatusField(),
                      ),
                      _buildTwoColumnRow(
                        _buildKeywordField(),
                        _buildChannelField(),
                      ),
                      // ... 나머지 필드들도 비슷한 패턴으로 구현
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      final currentLocale = Localizations.localeOf(context).languageCode;
                      context.go('/$currentLocale/sales/inspect-listing');
                    },
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('저장'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI 헬퍼 메서드들...
  Widget _buildTwoColumnRow(Widget left, Widget right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 16),
          Expanded(child: right),
        ],
      ),
    );
  }

  Widget _buildUrlField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '상품 URL *',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'https://www.example.com/product/123',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '상품 URL을 입력해주세요';
                    }
                    return null;
                  },
                  onSaved: (value) => _formData['productUrl'] = value ?? '',
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // URL 조회 로직
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('조회'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertiserIdField() {
    return _buildFormField(
      '광고주 ID *',
      '사용자 ID를 입력하세요',
      onSaved: (v) => _formData['advertiserId'] = v ?? '',
    );
  }

  Widget _buildStatusField() {
    return _buildFormField(
      '리워드 생성여부 *',
      '생성 여부 입력',
      initialValue: '생성',
      readOnly: true,
      onSaved: (v) => _formData['rewardStatus'] = v ?? '생성',
    );
  }

  Widget _buildKeywordField() {
    return _buildFormField(
      '키워드 *',
      '키워드를 입력하세요',
      onSaved: (v) => _formData['keyword'] = v ?? '',
    );
  }

  Widget _buildChannelField() {
    return _buildFormField(
      '판매처 *',
      '판매처를 입력하세요',
      onSaved: (v) => _formData['advertiserChannel'] = v ?? '',
    );
  }

  Widget _buildFormField(
    String label,
    String hint, {
    bool readOnly = false,
    String? initialValue,
    void Function(String?)? onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty ?? true ? '필수 입력 항목입니다' : null,
          onSaved: onSaved,
        ),
      ],
    );
  }
} 