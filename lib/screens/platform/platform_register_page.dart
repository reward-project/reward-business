import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/platform_service.dart';
import '../../models/platform/platform.dart';

class PlatformRegisterPage extends StatefulWidget {
  const PlatformRegisterPage({super.key});

  @override
  State<PlatformRegisterPage> createState() => _PlatformRegisterPageState();
}

class _PlatformRegisterPageState extends State<PlatformRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _platformNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _searchController = TextEditingController();
  final List<TextEditingController> _domainControllers = [
    TextEditingController()
  ];
  final _platformService = PlatformService();
  Timer? _debounce;
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isEditing = false;
  List<Platform> _searchResults = [];
  Platform? _selectedPlatform;
  final Map<String, List<Platform>> _searchCache = {};
  List<Map<String, dynamic>>? _existingDomains;

  @override
  void dispose() {
    _platformNameController.dispose();
    _displayNameController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    for (var controller in _domainControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addDomainField() {
    setState(() {
      _domainControllers.add(TextEditingController());
    });
  }

  void _removeDomainField(int index) {
    if (_domainControllers.length > 1) {
      setState(() {
        _domainControllers[index].dispose();
        _domainControllers.removeAt(index);
      });
    }
  }

  void _clearSelectedPlatform() {
    setState(() {
      _selectedPlatform = null;
      _platformNameController.clear();
      _displayNameController.clear();
      // 도메인 컨트롤러 초기화
      for (var controller in _domainControllers) {
        controller.dispose();
      }
      _domainControllers.clear();
      _domainControllers.add(TextEditingController());
      _existingDomains = null;
    });
  }

  Future<void> _searchPlatforms(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    // 최소 2글자 이상 입력해야 검색
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    // 디바운싱 적용
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      _isSearching = true;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        // 캐시된 결과가 있는지 확인
        if (_searchCache.containsKey(query)) {
          setState(() {
            _searchResults = _searchCache[query]!;
            _isSearching = false;
          });
          return;
        }

        // 실제 API 호출
        final results = await _platformService.searchPlatforms(context, query);

        // 캐시에 결과 저장
        _searchCache[query] = results;

        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('플랫폼 검색 중 오류가 발생했습니다: $e')),
          );
        }
      }
    });
  }

  void _selectPlatform(Platform platform) {
    setState(() {
      _selectedPlatform = platform;
      _platformNameController.text = platform.name!;
      _displayNameController.text = platform.displayName!;

      // 기존 도메인 컨트롤러들 정리
      for (var controller in _domainControllers) {
        controller.dispose();
      }
      _domainControllers.clear();

      // 선택된 플랫폼의 도메인들로 컨트롤러 초기화
      if (platform.domains?.isEmpty ?? true) {
        _domainControllers.add(TextEditingController());
      } else {
        for (var domain in platform.domains ?? []) {
          _domainControllers.add(TextEditingController(text: domain));
        }
      }
    });
    _loadExistingDomains();
  }

  Future<void> _loadExistingDomains() async {
    if (_selectedPlatform != null) {
      try {
        final domains = await _platformService.getPlatformDomains(
          context,
          _selectedPlatform!.id.toString(),
        );
        setState(() {
          _existingDomains = domains;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  Widget _buildDomainsList() {
    if (_existingDomains == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_existingDomains!.isEmpty) {
      return const Center(child: Text('등록된 도메인이 없습니다.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('등록된 도메인 목록:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...(_existingDomains!.map((domain) {
          final status = domain['status'] as String;
          final statusText = switch (status) {
            'ACTIVE' => '승인됨',
            'PENDING' => '대기중',
            'REJECTED' => '거절됨',
            _ => '알 수 없음'
          };

          return ListTile(
            title: Text(domain['domain'] as String),
            subtitle: Text(statusText),
            leading: Icon(
              switch (status) {
                'ACTIVE' => Icons.check_circle,
                'PENDING' => Icons.hourglass_empty,
                'REJECTED' => Icons.cancel,
                _ => Icons.help
              },
              color: switch (status) {
                'ACTIVE' => Colors.green,
                'PENDING' => Colors.orange,
                'REJECTED' => Colors.red,
                _ => Colors.grey
              },
            ),
          );
        }).toList()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          _selectedPlatform != null ? '플랫폼 수정' : '플랫폼 등록',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: _selectedPlatform != null
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearSelectedPlatform,
                ),
              ]
            : null,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 플랫폼 검색 섹션
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEAECF0)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '플랫폼 검색',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                        ),
                      ),
                      if (_selectedPlatform != null)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _clearSelectedPlatform,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '플랫폼 이름 또는 표시 이름으로 검색',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _searchPlatforms,
                  ),
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final platform = _searchResults[index];
                          return ListTile(
                            title: Text(
                              platform.name ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              platform.displayName ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            onTap: () => _selectPlatform(platform),
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        },
                      ),
                    ),
                  if (_isSearching) ...[
                    const SizedBox(height: 16),
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 플랫폼 등록 폼
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEAECF0)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _selectedPlatform != null ? '플랫폼 수정' : '플랫폼 등록',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344054),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '플랫폼 이름 (시스템용)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF344054),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '영문, 숫자, 언더스코어(_)만 사용. 예: naver_shopping',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF667085),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _platformNameController,
                          decoration: const InputDecoration(
                            hintText: '플랫폼 이름을 입력하세요',
                            border: OutlineInputBorder(),
                          ),
                          enabled: _selectedPlatform == null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '플랫폼 이름을 입력해주세요';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                              return '영문, 숫자, 언더스코어(_)만 사용 가능합니다';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '플랫폼 이름 (표시용)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF344054),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '플랫폼의 이름을 입력하세요. 예: 네이버 쇼핑',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF667085),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            hintText: '플랫폼 이름을 입력하세요',
                            border: OutlineInputBorder(),
                          ),
                          enabled: _selectedPlatform == null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '플랫폼 이름을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '도메인',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF344054),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '플랫폼의 기본 도메인. 예: shopping.naver.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF667085),
                          ),
                        ),
                        const SizedBox(height: 6),
                        ..._domainControllers.asMap().entries.map((entry) {
                          int index = entry.key;
                          return Column(
                            key: Key('domain-$index'),
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: entry.value,
                                      decoration: const InputDecoration(
                                        hintText: '도메인을 입력하세요',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '도메인을 입력해주세요';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (index == _domainControllers.length - 1)
                                    ElevatedButton(
                                      onPressed: _addDomainField,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        '추가',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  else
                                    ElevatedButton(
                                      onPressed: () =>
                                          _removeDomainField(index),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        '삭제',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }),
                      ],
                    ),
                    if (_selectedPlatform != null) ...[
                      const SizedBox(height: 16),
                      _buildDomainsList(),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _selectedPlatform != null
                                  ? '플랫폼 수정하기'
                                  : '플랫폼 등록하기',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final domains = _domainControllers
          .map((controller) => controller.text.trim())
          .where((domain) => domain.isNotEmpty)
          .toList();

      // 도메인 중복 검사
      for (var domain in domains) {
        if (!await _platformService.isDomainAvailable(context, domain)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('중복된 도메인이 있습니다: $domain'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }

      if (_selectedPlatform != null) {
        if (_selectedPlatform!.id == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('플랫폼 ID가 없습니다'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // ID가 유효한 숫자인지 확인
        final platformId = _selectedPlatform!.id.toString();
        if (int.tryParse(platformId) == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('유효하지 않은 플랫폼 ID입니다: $platformId'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // 플랫폼 수정
        await _platformService.updatePlatform(
          context,
          platformId,
          _platformNameController.text.trim(),
          _displayNameController.text.trim(),
          domains,
        );
      } else {
        // 새 플랫폼 등록
        await _platformService.registerPlatform(
          context,
          _platformNameController.text.trim(),
          _displayNameController.text.trim(),
          domains,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedPlatform != null
                ? '플랫폼 도메인이 수정되었습니다. 관리자 승인이 필요합니다.'
                : '플랫폼이 등록되었습니다. 관리자 승인이 필요합니다.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      final errorMessage = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }
}
