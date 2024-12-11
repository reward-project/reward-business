import 'package:flutter/material.dart';
import 'package:reward/models/platform/platform.dart';
import '../../../services/platform_service.dart';
import 'reward/reward_basic_info.dart';
import 'reward/reward_platform_info.dart';
import 'reward/reward_amount_info.dart';
import 'reward/reward_date_info.dart';
import 'calendar/calendar_date_range_picker.dart';
import 'package:intl/intl.dart';
import 'reward/reward_tag_input.dart';

class RewardForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(Map<String, dynamic>) onSubmit;
  final String? selectedDomain;
  final Function(String?) onDomainChanged;

  const RewardForm({
    super.key,
    required this.formKey,
    required this.onSubmit,
    required this.selectedDomain,
    required this.onDomainChanged,
  });

  @override
  State<RewardForm> createState() => _RewardFormState();
}

class _RewardFormState extends State<RewardForm> {
  final _rewardNameController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _productLinkController = TextEditingController();
  final _keywordController = TextEditingController();
  final _productIdController = TextEditingController();
  final _optionIdController = TextEditingController();
  final _rewardAmountController = TextEditingController();
  final _maxRewardsPerDayController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _platformService = PlatformService();

  int? _selectedPlatform;
  String? _selectedDomain;
  DateTime? _startDate;
  DateTime? _endDate;
  double _cpcAmount = 0;
  double _totalMaxAmount = 0;
  List<Platform> _platforms = [];
  List<Map<String, dynamic>> _domains = [];
  bool _isLoadingPlatforms = false;
  bool _isLoadingDomains = false;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _rewardAmountController.addListener(_updateCalculations);
    _maxRewardsPerDayController.addListener(_updateCalculations);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_platforms.isEmpty) {
      _loadPlatforms();
    }
  }

  @override
  void dispose() {
    _rewardNameController.dispose();
    _storeNameController.dispose();
    _productLinkController.dispose();
    _keywordController.dispose();
    _productIdController.dispose();
    _optionIdController.dispose();
    _rewardAmountController.dispose();
    _maxRewardsPerDayController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _loadPlatforms() async {
    setState(() => _isLoadingPlatforms = true);
    try {
      final platforms = await _platformService.getPlatforms(context);
      setState(() => _platforms = platforms);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() => _isLoadingPlatforms = false);
    }
  }

  Future<void> _loadPlatformDomains(String platformId) async {
    setState(() {
      _isLoadingDomains = true;
      _selectedDomain = null;
      _domains = [];
    });

    try {
      final domains = await _platformService.getPlatformDomains(context, platformId);
      setState(() {
        _domains = domains;
        if (domains.isNotEmpty) {
          _selectedDomain = domains[0]['domain'];
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('도메인 목록을 불러오는데 실패했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingDomains = false);
    }
  }

  void _updateCalculations() {
    setState(() {
      double rewardAmount = double.tryParse(_rewardAmountController.text.replaceAll(',', '')) ?? 0;
      _cpcAmount = rewardAmount * 3;

      int maxRewardsPerDay = int.tryParse(_maxRewardsPerDayController.text) ?? 0;
      int totalDays = _endDate != null && _startDate != null
          ? _endDate!.difference(_startDate!).inDays + 1
          : 0;
      _totalMaxAmount = _cpcAmount * maxRewardsPerDay * totalDays;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 360,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: CalendarDateRangePicker(
              initialStartDate: _startDate,
              initialEndDate: _endDate,
              firstDate: DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              ),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateRangeSelected: (start, end) {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _startDate = start;
                  _endDate = end;
                  if (start != null) {
                    _startDateController.text = _formatDate(start);
                  }
                  if (end != null) {
                    _endDateController.text = _formatDate(end);
                  }
                  _updateCalculations();
                });
              },
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showCpcInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF6B7280)),
              SizedBox(width: 8),
              Text(
                'CPC 단가란?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CPC(Cost Per Click)는 클릭당 비용을 의미합니다.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• 광고주가 실제로 지불하는 금액입다.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              Text(
                '• 리워드 단가에 수수료가 포함 금액입니다.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _handleSubmit() {
    if (widget.formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null || _selectedPlatform == null) {
        return;
      }

      widget.onSubmit({
        'rewardName': _rewardNameController.text,
        'platformId': _selectedPlatform,
        'storeName': _storeNameController.text,
        'productLink': _buildFullUrl(_selectedDomain, _productLinkController.text),
        'keyword': _keywordController.text,
        'productId': _productIdController.text,
        'optionId': _optionIdController.text,
        'startDate': _startDate,
        'endDate': _endDate,
        'rewardAmount': double.parse(_rewardAmountController.text.replaceAll(',', '')),
        'totalBudget': _totalMaxAmount,
        'maxRewardsPerDay': int.parse(_maxRewardsPerDayController.text),
        'tags': _tags,
      });
    }
  }

  void _handleDateInput(String value, bool isStartDate) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(value);
      if (date.isBefore(DateTime.now()) || 
          date.isAfter(DateTime.now().add(const Duration(days: 365)))) {
        return;
      }
      setState(() {
        if (isStartDate) {
          _startDate = date;
          if (_endDate != null && _endDate!.isBefore(date)) {
            _endDate = date;
            _endDateController.text = _formatDate(_endDate!);
          }
        } else {
          if (_startDate != null && date.isBefore(_startDate!)) {
            return;
          }
          _endDate = date;
        }
        _updateCalculations();
      });
    } catch (e) {
      // Invalid date format
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  String _buildFullUrl(String? domain, String productLink) {
    if (domain == null || domain.isEmpty || productLink.isEmpty) {
      throw Exception('도메인과 상품 링크를 모두 입력해주세요.');
    }

    // 이미 전체 URL인 경우 그대로 반환
    if (productLink.startsWith('http://') || productLink.startsWith('https://')) {
      return productLink;
    }

    // 슬래시로 시작하지 않는 경우 추가
    final cleanPath = productLink.startsWith('/') ? productLink : '/$productLink';
    
    // 도메인과 경로 결합하여 전체 URL 생성
    return 'https://$domain$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RewardBasicInfo(
            rewardNameController: _rewardNameController,
            storeNameController: _storeNameController,
          ),
          const SizedBox(height: 24),
          RewardPlatformInfo(
            platforms: _platforms,
            selectedPlatform: _selectedPlatform,
            isLoadingPlatforms: _isLoadingPlatforms,
            onPlatformChanged: (int? newValue) {
              setState(() {
                _selectedPlatform = newValue;
                if (newValue != null) {
                  final platform = _platforms.firstWhere(
                    (p) => p.id == newValue,
                  );
                  _loadPlatformDomains(platform.id.toString());
                }
              });
            },
            productLinkController: _productLinkController,
            selectedDomain: _selectedDomain,
            domains: _domains,
            isLoadingDomains: _isLoadingDomains,
            onDomainChanged: (String? newValue) {
              setState(() => _selectedDomain = newValue);
            },
            keywordController: _keywordController,
            productIdController: _productIdController,
            optionIdController: _optionIdController,
          ),
          const SizedBox(height: 24),
          RewardAmountInfo(
            rewardAmountController: _rewardAmountController,
            maxRewardsPerDayController: _maxRewardsPerDayController,
            cpcAmount: _cpcAmount,
            totalMaxAmount: 0,
            onCpcInfoPressed: () => _showCpcInfoDialog(context),
          ),
          const SizedBox(height: 24),
          RewardDateInfo(
            startDateController: _startDateController,
            endDateController: _endDateController,
            startDate: _startDate,
            endDate: _endDate,
            onDateInput: _handleDateInput,
            onCalendarPressed: () => _selectDateRange(context),
          ),
          if (_totalMaxAmount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calculate_outlined, color: Color(0xFF6B7280), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '예상 총 최대 차감 금액',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${NumberFormat('#,###').format(_totalMaxAmount)}원',
                          style: const TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          RewardTagInput(
            tags: _tags,
            onTagsChanged: (newTags) {
              setState(() => _tags = newTags);
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                '등록하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 