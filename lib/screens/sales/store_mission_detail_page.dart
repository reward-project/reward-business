import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/store_mission/store_mission_response.dart';

class StoreMissionDetailPage extends StatelessWidget {
  final StoreMissionResponse mission;

  const StoreMissionDetailPage({
    Key? key,
    required this.mission,
  }) : super(key: key);

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('미션 상세 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 수정 페이지로 이동
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(
              '기본 정보',
              [
                _buildInfoRow('미션 ID', mission.id),
                _buildInfoRow('상태', mission.status),
                _buildInfoRow('등록자', mission.registrantInfo.name),
                _buildInfoRow('등록일', DateFormat('yyyy-MM-dd').format(mission.createdAt)),
              ],
            ),
            _buildInfoSection(
              '리워드 정보',
              [
                _buildInfoRow('리워드명', mission.rewardInfo.name),
                _buildInfoRow('금액', '${NumberFormat('#,###').format(mission.rewardInfo.amount)}원'),
                _buildInfoRow('시작일', DateFormat('yyyy-MM-dd').format(mission.startDate)),
                _buildInfoRow('종료일', DateFormat('yyyy-MM-dd').format(mission.endDate)),
              ],
            ),
            _buildInfoSection(
              '플랫폼 정보',
              [
                _buildInfoRow('플랫폼', mission.platformInfo.name),
                _buildInfoRow('스토어명', mission.storeInfo.name),
                _buildInfoRow('상품명', mission.storeInfo.productName),
                _buildInfoRow('상품 URL', mission.storeInfo.productUrl),
                _buildInfoRow('검색어', mission.storeInfo.keyword),
              ],
            ),
            if (mission.tags.isNotEmpty)
              _buildInfoSection(
                '태그',
                [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: mission.tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
