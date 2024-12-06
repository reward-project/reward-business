import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/store_mission_service.dart';
import '../../services/reward_service.dart';
import '../../services/platform_service.dart';
import '../../models/platform/platform.dart';

class RewardWritePage extends StatefulWidget {
  const RewardWritePage({super.key});

  @override
  State<RewardWritePage> createState() => _RewardWritePageState();
}

class _RewardWritePageState extends State<RewardWritePage> {
  final _formKey = GlobalKey<FormState>();
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

  String? _selectedPlatform;
  String? _selectedDomain;
  DateTime? _startDate;
  DateTime? _endDate;
  double _cpcAmount = 0;
  double _totalMaxAmount = 0;
  List<Platform> _platforms = [];
  List<Map<String, dynamic>> _domains = [];
  bool _isLoadingPlatforms = false;
  bool _isLoadingDomains = false;

  @override
  void initState() {
    super.initState();
    _rewardAmountController.addListener(_updateCalculations);
    _maxRewardsPerDayController.addListener(_updateCalculations);
    
    _startDateController.addListener(() {
      if (_startDateController.text.length == 10) {
        _handleDateInput(_startDateController.text, true);
      }
    });
    
    _endDateController.addListener(() {
      if (_endDateController.text.length == 10) {
        _handleDateInput(_endDateController.text, false);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlatforms();
    });
  }

  Future<void> _loadPlatforms() async {
    setState(() {
      _isLoadingPlatforms = true;
    });

    try {
      final platforms = await _platformService.getPlatforms(context);
      setState(() {
        _platforms = platforms;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingPlatforms = false;
      });
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
      setState(() {
        _isLoadingDomains = false;
      });
    }
  }

  String _formatDate(String value) {
    value = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.length > 8) {
      value = value.substring(0, 8);
    }
    if (value.length >= 4) {
      value = '${value.substring(0, 4)}-${value.substring(4)}';
    }
    if (value.length >= 7) {
      value = '${value.substring(0, 7)}-${value.substring(7)}';
    }
    return value;
  }

  void _handleDateInput(String value, bool isStartDate) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(value);
      if (date.isBefore(DateTime.now()) || date.isAfter(DateTime.now().add(const Duration(days: 365)))) {
        return;
      }
      setState(() {
        if (isStartDate) {
          _startDate = date;
          if (_endDate != null && _endDate!.isBefore(date)) {
            _endDate = date;
            _endDateController.text = _formatDate(DateFormat('yyyyMMdd').format(date));
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

  void _updateCalculations() {
    setState(() {
      // 리워드 단가 계산
      double rewardAmount = double.tryParse(_rewardAmountController.text) ?? 0;
      // CPC 단가 계산 (리워드 단가 + 200% 수수료)
      _cpcAmount = rewardAmount * 3; // 원래 금액 + (원래 금액 * 200%)

      // 예상 총 최대 차감 금액 계산
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
      builder: (BuildContext context) {
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
                setState(() {
                  _startDate = start;
                  _endDate = end;
                  _updateCalculations();
                  if (start != null) {
                    _startDateController.text = _formatDate(DateFormat('yyyyMMdd').format(start));
                  }
                  if (end != null) {
                    _endDateController.text = _formatDate(DateFormat('yyyyMMdd').format(end));
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  void _showCpcInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              const Text(
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
                '• 광고주가 실제로 지불하는 금액입니다.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              Text(
                '• 리워드 단가에 수수료가 포함된 금액입니다.',
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    String? placeholder,
    bool isMultiline = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF344054),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: isMultiline ? 3 : 1,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFF667085)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          '리워드 등록',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  label: '리워드명',
                  controller: _rewardNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '리워드명을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  label: '스토어명',
                  controller: _storeNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '스토어명을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '플랫폼',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF344054),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFD0D5DD)),
                            ),
                            child: _isLoadingPlatforms
                                ? const Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedPlatform,
                                      hint: const Text(
                                        '플랫폼을 선택해주세요',
                                        style: TextStyle(color: Color(0xFF667085)),
                                      ),
                                      isExpanded: true,
                                      items: _platforms.map((Platform platform) {
                                        return DropdownMenuItem<String>(
                                          value: platform.name,
                                          child: Text(platform.displayName ?? platform.name),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedPlatform = newValue;
                                          if (newValue != null) {
                                            final platform = _platforms.firstWhere(
                                              (p) => p.name == newValue,
                                            );
                                            _loadPlatformDomains(platform.id.toString());
                                          }
                                        });
                                      },
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            final locale = Localizations.localeOf(context).languageCode;
                            context.push('/$locale/platform/register').then((_) {
                              // Refresh platforms list when returning from registration
                              _loadPlatforms();
                            });
                          },
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('플랫폼 추가'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '상품 링크',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF344054),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(8),
                              ),
                              border: Border.all(color: const Color(0xFFD0D5DD)),
                            ),
                            child: _isLoadingDomains
                                ? const Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedDomain,
                                      hint: const Text(
                                        '도메인 선택',
                                        style: TextStyle(color: Color(0xFF667085)),
                                      ),
                                      isExpanded: true,
                                      items: _domains.map((domain) {
                                        return DropdownMenuItem<String>(
                                          value: domain['domain'],
                                          child: Text(domain['domain']),
                                        );
                                      }).toList(),
                                      onChanged: _selectedPlatform == null
                                          ? null
                                          : (String? newValue) {
                                              setState(() {
                                                _selectedDomain = newValue;
                                              });
                                            },
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _productLinkController,
                            decoration: InputDecoration(
                              hintText: '상품 링크를 입력하세요',
                              hintStyle: const TextStyle(color: Color(0xFF667085)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8),
                                ),
                                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8),
                                ),
                                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8),
                                ),
                                borderSide: BorderSide(color: Theme.of(context).primaryColor),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8),
                                ),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '상품 링크를 입력해주세요.';
                              }
                              if (_selectedDomain == null) {
                                return '도메인을 선택해주세요.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  label: '키워드',
                  controller: _keywordController,
                  placeholder: '키워드를 입력하세요',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '키워드를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: '상품 ID',
                        controller: _productIdController,
                        placeholder: '상품 ID를 입력하세요',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '상품 ID를 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        label: '옵션 ID',
                        controller: _optionIdController,
                        placeholder: '옵션 ID를 입력하세요',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '옵션 ID를 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  label: '리워드 입찰가 (원)',
                  controller: _rewardAmountController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '리워드 단가를 입력해주세요.';
                    }
                    if (double.tryParse(value) == null) {
                      return '숫자만 입력해주세요.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
                if (_cpcAmount > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: IconButton(
                            onPressed: () => _showCpcInfoDialog(context),
                            icon: const Icon(Icons.info_outline, color: Color(0xFF6B7280), size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                            tooltip: 'CPC 단가 정보',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'CPC 단가: ${NumberFormat('#,###').format(_cpcAmount)}원',
                          style: const TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _buildInputField(
                  label: '하루 최대 소진량',
                  controller: _maxRewardsPerDayController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '하루 최대 소진량을 입력해주세요.';
                    }
                    if (int.tryParse(value) == null) {
                      return '숫자만 입력해주세요.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '작업 기간',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF344054),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startDateController,
                            decoration: InputDecoration(
                              hintText: 'YYYY-MM-DD',
                              hintStyle: const TextStyle(color: Color(0xFF667085)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                              ),
                            ),
                            onChanged: (value) {
                              final formattedValue = _formatDate(value);
                              if (formattedValue != value) {
                                _startDateController.value = TextEditingValue(
                                  text: formattedValue,
                                  selection: TextSelection.collapsed(offset: formattedValue.length),
                                );
                              }
                            },
                            validator: (value) => value?.isEmpty ?? true ? '시작일을 입력해주세요' : null,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('~'),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _endDateController,
                            decoration: InputDecoration(
                              hintText: 'YYYY-MM-DD',
                              hintStyle: const TextStyle(color: Color(0xFF667085)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                              ),
                            ),
                            onChanged: (value) {
                              final formattedValue = _formatDate(value);
                              if (formattedValue != value) {
                                _endDateController.value = TextEditingValue(
                                  text: formattedValue,
                                  selection: TextSelection.collapsed(offset: formattedValue.length),
                                );
                              }
                            },
                            validator: (value) => value?.isEmpty ?? true ? '종료일을 입력해주세요' : null,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month, size: 24),
                          onPressed: () => _selectDateRange(context),
                          color: Theme.of(context).primaryColor,
                          tooltip: '달력으로 선택',
                        ),
                      ],
                    ),
                  ],
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
                const SizedBox(height: 32),
                ElevatedButton(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null || _selectedPlatform == null || _selectedDomain == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('날짜, 플랫폼, 도메인을 선택해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그인이 필요합니다.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await StoreMissionService.createStoreMission(
          context: context,
          rewardName: _rewardNameController.text,
          platform: _selectedPlatform!,
          storeName: _storeNameController.text,
          productLink: _productLinkController.text,
          keyword: _keywordController.text,
          productId: _productIdController.text,
          optionId: _optionIdController.text,
          startDate: _startDate!,
          endDate: _endDate!,
          registrantId: user.userId,
          rewardAmount: double.parse(_rewardAmountController.text),
          maxRewardsPerDay: int.parse(_maxRewardsPerDayController.text),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('리워드가 성공적으로 등록되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
          final locale = Localizations.localeOf(context).languageCode;
          context.go('/$locale/sales/store-mission');
        }
      } catch (e) {
        // Error will be handled by DioService
      }
    }
  }
}

class CalendarDateRangePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const CalendarDateRangePicker({
    Key? key,
    this.initialStartDate,
    this.initialEndDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateRangeSelected,
  }) : super(key: key);

  @override
  _CalendarDateRangePickerState createState() => _CalendarDateRangePickerState();
}

class _CalendarDateRangePickerState extends State<CalendarDateRangePicker> {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _focusedMonth = DateTime.now();
  final _monthFormat = DateFormat('yyyy년 MM월');

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  bool _isSelectedDate(DateTime date) {
    return (_startDate != null && isSameDay(date, _startDate)) ||
        (_endDate != null && isSameDay(date, _endDate));
  }

  bool _isInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!) && date.isBefore(_endDate!);
  }

  bool isSameDay(DateTime? dateA, DateTime? dateB) {
    return dateA?.year == dateB?.year &&
        dateA?.month == dateB?.month &&
        dateA?.day == dateB?.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month - 1,
                    );
                  });
                },
              ),
              Text(
                _monthFormat.format(_focusedMonth),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
              return SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: day == '일' ? Colors.red : day == '토' ? Colors.blue : const Color(0xFF666666),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: _getDaysInMonth(_focusedMonth),
            itemBuilder: (context, index) {
              final date = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                index + 1,
              );
              final isSelected = _isSelectedDate(date);
              final isInRange = _isInRange(date);
              final isDisabled = date.isBefore(widget.firstDate) ||
                  date.isAfter(widget.lastDate);
              final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
              final isToday = _isToday(date);

              return InkWell(
                onTap: isDisabled
                    ? null
                    : () {
                        setState(() {
                          if (_startDate == null || _endDate != null) {
                            _startDate = date;
                            _endDate = null;
                          } else {
                            if (date.isBefore(_startDate!)) {
                              _startDate = date;
                              _endDate = null;
                            } else {
                              _endDate = date;
                              widget.onDateRangeSelected(_startDate, _endDate);
                            }
                          }
                        });
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isInRange
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                    border: isToday
                        ? Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white
                            : isDisabled
                                ? Colors.grey.shade400
                                : isInRange
                                    ? Theme.of(context).primaryColor
                                    : isWeekend
                                        ? date.weekday == DateTime.sunday
                                            ? Colors.red
                                            : Colors.blue
                                        : isToday
                                            ? Theme.of(context).primaryColor
                                            : null,
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _startDate == null
                    ? null
                    : () {
                        widget.onDateRangeSelected(_startDate, _endDate);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('선택'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }
}