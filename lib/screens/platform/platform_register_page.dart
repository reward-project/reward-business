import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/platform_service.dart';
import '../../models/platform/platform.dart';
import 'components/platform_search_section.dart';
import 'components/platform_form_section.dart';

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
  final List<TextEditingController> _domainControllers = [TextEditingController()];
  final _platformService = PlatformService();
  
  Timer? _debounce;
  bool _isLoading = false;
  bool _isSearching = false;
  Platform? _selectedPlatform;
  List<Platform> _searchResults = [];
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
      for (var controller in _domainControllers) {
        controller.dispose();
      }
      _domainControllers.clear();
      _domainControllers.add(TextEditingController());
      _existingDomains = null;
    });
  }

  Future<void> _searchPlatforms(String query) async {
    if (query.isEmpty || query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() => _isSearching = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        if (_searchCache.containsKey(query)) {
          setState(() {
            _searchResults = _searchCache[query]!;
            _isSearching = false;
          });
          return;
        }

        final results = await _platformService.searchPlatforms(context, query);
        _searchCache[query] = results;

        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearching = false);
          _showErrorSnackBar('플랫폼 검색 중 오류가 발생했습니다: $e');
        }
      }
    });
  }

  void _selectPlatform(Platform platform) {
    setState(() {
      _selectedPlatform = platform;
      _platformNameController.text = platform.name ?? '';
      _displayNameController.text = platform.displayName ?? '';
    });
    _loadExistingDomains();
  }

  Future<void> _loadExistingDomains() async {
    if (_selectedPlatform?.id == null) return;

    try {
      final domains = await _platformService.getPlatformDomains(
        context,
        _selectedPlatform!.id.toString(),
      );
      setState(() => _existingDomains = domains);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final domains = _domainControllers
          .map((controller) => controller.text.trim())
          .where((domain) => domain.isNotEmpty)
          .toList();

      // 도메인 중복 검사
      for (var domain in domains) {
        if (!await _platformService.isDomainAvailable(context, domain)) {
          _showErrorSnackBar('중복된 도메인이 있습니다: $domain');
          return;
        }
      }

      if (_selectedPlatform != null) {
        await _updatePlatform(domains);
      } else {
        await _registerPlatform(domains);
      }

      _showSuccessSnackBar(
        _selectedPlatform != null
            ? '플랫폼 도메인이 수정되었습니다. 관리자 승인이 필요합니다.'
            : '플랫폼이 등록되었습니다. 관리자 승인이 필요합니다.',
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updatePlatform(List<String> domains) async {
    if (_selectedPlatform?.id == null) {
      throw Exception('플랫폼 ID가 없습니다');
    }

    final platformId = _selectedPlatform!.id.toString();
    if (int.tryParse(platformId) == null) {
      throw Exception('유효하지 않은 플랫폼 ID입니다: $platformId');
    }

    await _platformService.updatePlatform(
      context,
      platformId,
      _platformNameController.text.trim(),
      _displayNameController.text.trim(),
      domains,
    );
  }

  Future<void> _registerPlatform(List<String> domains) async {
    await _platformService.registerPlatform(
      context,
      _platformNameController.text.trim(),
      _displayNameController.text.trim(),
      domains,
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
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            PlatformSearchSection(
              searchController: _searchController,
              isSearching: _isSearching,
              searchResults: _searchResults,
              selectedPlatform: _selectedPlatform,
              onSearch: _searchPlatforms,
              onSelect: _selectPlatform,
              onClear: _clearSelectedPlatform,
            ),
            const SizedBox(height: 24),
            PlatformFormSection(
              formKey: _formKey,
              platformNameController: _platformNameController,
              displayNameController: _displayNameController,
              domainControllers: _domainControllers,
              selectedPlatform: _selectedPlatform,
              existingDomains: _existingDomains,
              isLoading: _isLoading,
              onAddDomain: _addDomainField,
              onRemoveDomain: _removeDomainField,
              onSubmit: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
