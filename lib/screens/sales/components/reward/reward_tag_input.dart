import 'package:flutter/material.dart';
import '../../../../services/store_mission_service.dart';

class RewardTagInput extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) onTagsChanged;

  const RewardTagInput({
    Key? key,
    required this.tags,
    required this.onTagsChanged,
  }) : super(key: key);

  @override
  State<RewardTagInput> createState() => _RewardTagInputState();
}

class _RewardTagInputState extends State<RewardTagInput> {
  final _tagController = TextEditingController();
  List<String> _suggestedTags = [];
  bool _isLoading = false;

  Future<void> _searchTags(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestedTags = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final tags = await StoreMissionService.searchTags(context, query);
      setState(() => _suggestedTags = tags);
    } catch (e) {
      debugPrint('Error searching tags: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '태그',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF344054),
          ),
        ),
        const SizedBox(height: 6),
        // 태그 입력 필드
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            _searchTags(textEditingValue.text);
            return _suggestedTags.where((tag) => tag
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (String tag) {
            if (!widget.tags.contains(tag)) {
              final newTags = [...widget.tags, tag];
              widget.onTagsChanged(newTags);
            }
            _tagController.clear();
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: '태그 입력 또는 검색 (#여름세일)',
                prefixIcon: const Icon(Icons.tag),
                suffixIcon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty && !widget.tags.contains(value)) {
                  final newTags = [...widget.tags, value];
                  widget.onTagsChanged(newTags);
                  controller.clear();
                }
              },
            );
          },
        ),
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () {
                  final newTags = widget.tags.where((t) => t != tag).toList();
                  widget.onTagsChanged(newTags);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
