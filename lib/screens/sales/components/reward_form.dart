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
  final Map<String, dynamic>? formData;
  final Function(Map<String, dynamic>) onSubmit;

  const RewardForm({
    Key? key,
    this.formData,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<RewardForm> createState() => _RewardFormState();
}

class _RewardFormState extends State<RewardForm> {
  final _platformService = PlatformService();
  final _rewardAmountController = TextEditingController();
  final _maxRewardsPerDayController = TextEditingController();
  final _rewardNameController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _productLinkController = TextEditingController();
  final _keywordController = TextEditingController();
  final _productIdController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _domains = [];
  List<Platform> _platforms = [];
  bool _isLoadingDomains = false;
  bool _isLoadingPlatforms = false;
  String? _selectedDomain;
  int? _selectedPlatform;
  List<String> _tags = [];
  DateTime? _startDate;
  DateTime? _endDate;
  double _cpcAmount = 0;
  double _totalMaxAmount = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('RewardForm initState');
    debugPrint('Initial form data: ${widget.formData}');

    if (widget.formData != null) {
      debugPrint('Initializing form with data: ${widget.formData}');
      
      // Basic Info
      _rewardNameController.text = widget.formData!['rewardName']?.toString() ?? '';
      debugPrint('Reward Name: ${_rewardNameController.text}');
      
      // Platform Info
      _selectedPlatform = widget.formData!['platformId'];
      debugPrint('Selected Platform: $_selectedPlatform');
      
      _storeNameController.text = widget.formData!['storeName']?.toString() ?? '';
      _productLinkController.text = widget.formData!['productLink']?.toString() ?? '';
      _keywordController.text = widget.formData!['keyword']?.toString() ?? '';
      _productIdController.text = widget.formData!['productId']?.toString() ?? '';
      debugPrint('Store Info:');
      debugPrint('- Store Name: ${_storeNameController.text}');
      debugPrint('- Product Link: ${_productLinkController.text}');
      debugPrint('- Keyword: ${_keywordController.text}');
      debugPrint('- Product ID: ${_productIdController.text}');
      
      // Amount Info
      if (widget.formData!['rewardAmount'] != null) {
        _rewardAmountController.text = widget.formData!['rewardAmount'].toString();
      }
      if (widget.formData!['maxRewardsPerDay'] != null) {
        _maxRewardsPerDayController.text = widget.formData!['maxRewardsPerDay'].toString();
      }
      debugPrint('Amount Info:');
      debugPrint('- Reward Amount: ${_rewardAmountController.text}');
      debugPrint('- Max Rewards Per Day: ${_maxRewardsPerDayController.text}');
      
      // Date Info
      _startDate = widget.formData!['startDate'];
      _endDate = widget.formData!['endDate'];
      if (_startDate != null) {
        _startDateController.text = _formatDate(_startDate!);
      }
      if (_endDate != null) {
        _endDateController.text = _formatDate(_endDate!);
      }
      debugPrint('Date Info:');
      debugPrint('- Start Date: ${_startDateController.text}');
      debugPrint('- End Date: ${_endDateController.text}');
      
      // Tags
      _tags = List<String>.from(widget.formData!['tags'] ?? []);
      debugPrint('Tags: $_tags');
      
      _selectedDomain = widget.formData!['selectedDomain'];
      debugPrint('Selected Domain: $_selectedDomain');
      
      if (_selectedPlatform != null) {
        _loadPlatformDomains(_selectedPlatform.toString());
      }
    }

    _rewardAmountController.addListener(_updateCalculations);
    _maxRewardsPerDayController.addListener(_updateCalculations);
    _loadPlatforms();
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
      _domains = [];
      _selectedDomain = null;  // Reset selected domain when loading new domains
    });

    try {
      debugPrint('Loading domains for platform: $platformId');
      final domains = await _platformService.getPlatformDomains(context, platformId);
      debugPrint('Loaded domains: $domains');
      
      setState(() {
        _domains = domains;
        if (domains.isNotEmpty) {
          if (widget.formData != null && widget.formData!['selectedDomain'] != null) {
            // Try to find the previously selected domain
            final previousDomain = widget.formData!['selectedDomain'];
            final domainExists = domains.any((d) => d['domain'] == previousDomain);
            if (domainExists) {
              _selectedDomain = previousDomain;
            } else {
              _selectedDomain = domains[0]['domain'];
            }
          } else {
            _selectedDomain = domains[0]['domain'];
          }
        }
      });
      debugPrint('Selected domain: $_selectedDomain');
    } catch (e) {
      debugPrint('Error loading domains: $e');
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
    final rewardAmount = double.tryParse(_rewardAmountController.text.replaceAll(',', '')) ?? 0;
    final maxRewardsPerDay = int.tryParse(_maxRewardsPerDayController.text) ?? 0;
    
    setState(() {
      _cpcAmount = rewardAmount * 3;
      
      if (_startDate != null && _endDate != null) {
        final difference = _endDate!.difference(_startDate!);
        final totalDays = difference.inDays + 1;
        _totalMaxAmount = _cpcAmount * maxRewardsPerDay * totalDays;
      } else {
        _totalMaxAmount = 0;
      }
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

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      debugPrint('Form submission - Selected Platform: $_selectedPlatform');
      debugPrint('Form submission - Selected Domain: $_selectedDomain');
      debugPrint('Form submission - Product Link: ${_productLinkController.text}');

      if (_selectedPlatform == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('플랫폼을 선택해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String fullUrl;
      try {
        fullUrl = _buildFullUrl(_productLinkController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final data = {
        'rewardName': _rewardNameController.text,
        'storeName': _storeNameController.text,
        'platformId': _selectedPlatform,
        'selectedDomain': _selectedDomain,
        'productLink': fullUrl,
        'keyword': _keywordController.text,
        'productId': _productIdController.text,
        'startDate': _startDate,
        'endDate': _endDate,
        'rewardAmount': int.tryParse(_rewardAmountController.text.replaceAll(',', '')) ?? 0,
        'totalBudget': _totalMaxAmount,
        'maxRewardsPerDay': int.tryParse(_maxRewardsPerDayController.text) ?? 0,
        'tags': _tags,
      };

      debugPrint('Submitting form data: $data');
      widget.onSubmit(data);
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

  String _buildFullUrl(String productLink) {
    if (productLink.isEmpty) {
      throw Exception('상품 링크를 입력해주세요.');
    }

    if (productLink.startsWith('http://') || productLink.startsWith('https://')) {
      return productLink;
    }

    if (_selectedDomain == null) {
      throw Exception('도메인을 선택해주세요.');
    }

    final cleanPath = productLink.startsWith('/') ? productLink.substring(1) : productLink;
    return 'https://${_selectedDomain}/$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RewardBasicInfo(
            rewardNameController: _rewardNameController,
          ),
          const SizedBox(height: 24),
          RewardPlatformInfo(
            platforms: _platforms,
            selectedPlatform: _selectedPlatform,
            onPlatformChanged: (newValue) {
              setState(() {
                _selectedPlatform = newValue;
                _selectedDomain = null;
              });
              if (newValue != null) {
                _loadPlatformDomains(newValue.toString());
              }
            },
            domains: _domains,
            selectedDomain: _selectedDomain,
            onDomainChanged: (newValue) {
              setState(() => _selectedDomain = newValue);
            },
            isLoadingPlatforms: _isLoadingPlatforms,
            isLoadingDomains: _isLoadingDomains,
            storeNameController: _storeNameController,
            productLinkController: _productLinkController,
            keywordController: _keywordController,
            productIdController: _productIdController,
          ),
          const SizedBox(height: 24),
          RewardAmountInfo(
            rewardAmountController: _rewardAmountController,
            maxRewardsPerDayController: _maxRewardsPerDayController,
            cpcAmount: _cpcAmount,
            totalMaxAmount: _totalMaxAmount,
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