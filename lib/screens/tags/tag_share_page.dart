import 'package:flutter/material.dart';
import 'package:reward/models/tag/tag_share_request.dart';
import 'package:reward/services/tag_service.dart';

class TagSharePage extends StatefulWidget {
  final String tagId;

  const TagSharePage({super.key, required this.tagId});

  @override
  State<TagSharePage> createState() => _TagSharePageState();
}

class _TagSharePageState extends State<TagSharePage> {
  final TextEditingController _userIdController = TextEditingController();
  TagSharePermission _permission = TagSharePermission.READ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('태그 공유'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: '공유할 사용자 ID',
                hintText: '사용자 ID를 입력하세요',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('권한 설정'),
            RadioListTile<TagSharePermission>(
              title: const Text('읽기 권한'),
              value: TagSharePermission.READ,
              groupValue: _permission,
              onChanged: (value) {
                setState(() {
                  _permission = value!;
                });
              },
            ),
            RadioListTile<TagSharePermission>(
              title: const Text('읽기/쓰기 권한'),
              value: TagSharePermission.WRITE,
              groupValue: _permission,
              onChanged: (value) {
                setState(() {
                  _permission = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _shareTag(context),
                child: const Text('공유하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareTag(BuildContext context) async {
    try {
      final userId = int.parse(_userIdController.text);
      await TagService.shareTag(
        context: context,
        tagId: widget.tagId,
        request: TagShareRequest(
          sharedWithId: userId,
          permission: _permission,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('태그가 성공적으로 공유되었습니다.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('태그 공유 실패: $e')),
        );
      }
    }
  }
}
