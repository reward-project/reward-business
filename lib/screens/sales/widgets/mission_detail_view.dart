import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reward/models/store_mission/store_mission_response.dart';
import 'package:intl/intl.dart';
import 'package:reward/screens/sales/widgets/mission_status_chip.dart';

class MissionDetailView extends StatelessWidget {
  final StoreMissionResponse mission;
  final VoidCallback? onClose;
  final bool showActions;

  const MissionDetailView({
    super.key,
    required this.mission,
    this.onClose,
    this.showActions = true,
  });

  Widget _buildDetailRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }

  Widget _buildDetailText(String value) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildMoneyText(num amount) {
    return Text(
      '${NumberFormat('#,###').format(amount)}원',
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.month}월 ${date.day}일';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy년 MM월 dd일 HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.reward.rewardName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  MissionStatusChip(status: mission.status),
                ],
              ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(),
          ),
          _buildDetailRow('플랫폼', _buildDetailText(mission.platform.name)),
          _buildDetailRow('스토어', _buildDetailText(mission.store.storeName)),
          _buildDetailRow('리워드', _buildMoneyText(mission.reward.rewardAmount)),
          _buildDetailRow('시작일', _buildDetailText(_formatDateTime(mission.reward.startDate))),
          _buildDetailRow('종료일', _buildDetailText(_formatDateTime(mission.reward.endDate))),
          if (mission.tags.isNotEmpty)
            _buildDetailRow(
              '태그',
              Wrap(
                spacing: 8,
                children: mission.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ))
                    .toList(),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(),
          ),
          _buildDetailRow('총 리워드 사용', _buildMoneyText(mission.totalRewardUsage)),
          _buildDetailRow('남은 리워드', _buildMoneyText(mission.remainingRewardBudget)),
          if (showActions) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onClose,
                  child: const Text('닫기'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    onClose?.call();
                    final locale = Localizations.localeOf(context).languageCode;
                    context.go(
                      '/$locale/sales/store-mission/${mission.id}/edit',
                      extra: {'mission': mission},
                    );
                  },
                  child: const Text('수정'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
