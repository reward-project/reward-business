import 'package:flutter/material.dart';

class StoreMissionList extends StatelessWidget {
  final searchController = TextEditingController();
  final tagController = TextEditingController();

  StoreMissionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 태그 검색 필드
        TextField(
          controller: tagController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.tag),
            hintText: '태그로 검색 (#여름세일, #네이버쇼핑)',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // 태그 검색 실행
                StoreMissionService.getStoreMissionsByTag(
                  context, 
                  tagController.text.trim(),
                );
              },
            ),
          ),
        ),
        // 리워드 목록 표시
        Expanded(
          child: StoreMissionListView(),
        ),
      ],
    );
  }
} 