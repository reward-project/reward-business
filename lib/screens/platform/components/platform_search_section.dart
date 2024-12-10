import 'package:flutter/material.dart';
import '../../../models/platform/platform.dart';

class PlatformSearchSection extends StatelessWidget {
  final TextEditingController searchController;
  final bool isSearching;
  final List<Platform> searchResults;
  final Platform? selectedPlatform;
  final Function(String) onSearch;
  final Function(Platform) onSelect;
  final VoidCallback onClear;

  const PlatformSearchSection({
    super.key,
    required this.searchController,
    required this.isSearching,
    required this.searchResults,
    required this.selectedPlatform,
    required this.onSearch,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSearchField(),
          if (isSearching) _buildLoadingIndicator(),
          if (searchResults.isNotEmpty) _buildSearchResults(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
        if (selectedPlatform != null)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClear,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 20,
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      decoration: const InputDecoration(
        hintText: '플랫폼 이름 또는 표시 이름으로 검색',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: onSearch,
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(top: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildSearchResults() {
    return Container(
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
        itemCount: searchResults.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final platform = searchResults[index];
          return ListTile(
            title: Text(
              platform.name ?? '',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              platform.displayName ?? '',
              style: TextStyle(color: Colors.grey[600]),
            ),
            onTap: () => onSelect(platform),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }
} 