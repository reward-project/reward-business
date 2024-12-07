import 'package:flutter/material.dart';

class RewardProductLinkField extends StatefulWidget {
  final TextEditingController productLinkController;
  final String? selectedDomain;
  final List<Map<String, dynamic>> domains;
  final bool isLoadingDomains;
  final int? selectedPlatform;
  final Function(String?) onDomainChanged;

  const RewardProductLinkField({
    Key? key,
    required this.productLinkController,
    required this.selectedDomain,
    required this.domains,
    required this.isLoadingDomains,
    required this.selectedPlatform,
    required this.onDomainChanged,
  }) : super(key: key);

  @override
  State<RewardProductLinkField> createState() => _RewardProductLinkFieldState();
}

class _RewardProductLinkFieldState extends State<RewardProductLinkField> {
  String _fullUrl = '';

  void _updateFullUrl() {
    final domain = widget.selectedDomain;
    final path = widget.productLinkController.text;
    
    if (domain == null || domain.isEmpty || path.isEmpty) {
      setState(() => _fullUrl = '');
      return;
    }
    
    if (path.startsWith('http')) {
      setState(() => _fullUrl = path);
      return;
    }
    
    final cleanPath = path.startsWith('/') ? path : '/$path';
    setState(() => _fullUrl = 'https://$domain$cleanPath');
  }

  @override
  void initState() {
    super.initState();
    widget.productLinkController.addListener(_updateFullUrl);
  }

  @override
  void dispose() {
    widget.productLinkController.removeListener(_updateFullUrl);
    super.dispose();
  }

  @override
  void didUpdateWidget(RewardProductLinkField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDomain != widget.selectedDomain) {
      _updateFullUrl();
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

  String _buildFullUrl(String? domain, String path) {
    if (domain == null || domain.isEmpty || path.isEmpty) return '';
    
    if (path.startsWith('http')) return path;
    
    final cleanPath = path.startsWith('/') ? path : '/$path';
    
    return 'https://$domain$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(8),
                    ),
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                  ),
                  child: widget.isLoadingDomains
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
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                              value: widget.selectedDomain,
                              hint: const Text(
                                '도메인 선택',
                                style: TextStyle(color: Color(0xFF667085)),
                              ),
                              isExpanded: true,
                              items: widget.domains.map((domain) {
                                return DropdownMenuItem<String>(
                                  value: domain['domain'],
                                  child: Text(domain['domain']),
                                );
                              }).toList(),
                              onChanged: widget.selectedPlatform == null ? null : (value) {
                                widget.onDomainChanged(value);
                                _updateFullUrl();
                              },
                            ),
                          ),
                        ),
                ),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: widget.productLinkController,
                  decoration: InputDecoration(
                    hintText: '상품 링크를 입력하세요 (예: products/123)',
                    hintStyle: const TextStyle(color: Color(0xFF667085)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
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
                    if (widget.selectedDomain == null) {
                      return '도메인을 선택해주세요.';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        if (_fullUrl.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '전체 URL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  _fullUrl,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
} 
