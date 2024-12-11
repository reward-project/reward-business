import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reward/models/store_mission/store_mission_response.dart';
import 'package:reward/screens/sales/widgets/mission_status_chip.dart';
import 'package:reward/services/store_mission_command_service.dart';
import 'package:reward/utils/responsive.dart';

class MissionTable extends StatelessWidget {
  final List<StoreMissionResponse> missions;
  final Set<int> selectedMissionIds;
  final Function(StoreMissionResponse) onMissionTap;
  final Function(Set<int>) onSelectionChanged;
  final Function() onRefresh;

  const MissionTable({
    super.key,
    required this.missions,
    required this.selectedMissionIds,
    required this.onMissionTap,
    required this.onSelectionChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '등록된 미션이 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTableHeader(context),
            const Divider(height: 1),
            Expanded(child: _buildTableBody(context)),
            if (selectedMissionIds.isNotEmpty) _buildSelectionActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final bool isDesktopView = isDesktop(context);

    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Checkbox(
              value: selectedMissionIds.length == missions.length,
              tristate: selectedMissionIds.isNotEmpty &&
                  selectedMissionIds.length != missions.length,
              onChanged: (bool? value) {
                if (value == true) {
                  onSelectionChanged(missions.map((m) => m.id).toSet());
                } else {
                  onSelectionChanged({});
                }
              },
            ),
          ),
          const Expanded(
              flex: 4,
              child:
                  Text('미션명', style: TextStyle(fontWeight: FontWeight.w600))),
          const Expanded(
            flex: 2,
            child: Text(
              '상태',
              style: TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              '단가',
              style: TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 24),
          if (isDesktopView)
            const Expanded(
              flex: 3,
              child: Text(
                '기간',
                style: TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          const Expanded(
            flex: 2,
            child: Text(
              '사용량',
              style: TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(
              flex: 2,
              child: Text('잔액',
                  style: TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right)),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, StoreMissionResponse mission) {
    final bool isDesktopView = isDesktop(context);
    final bool isActive = mission.status == 'ACTIVE';
    final bool isScheduled = mission.status == 'SCHEDULED';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onMissionTap(mission),
        child: Container(
          color: selectedMissionIds.contains(mission.id)
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1)
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Checkbox(
                  value: selectedMissionIds.contains(mission.id),
                  onChanged: (selected) => onSelectionChanged(
                    selected == true
                        ? {...selectedMissionIds, mission.id}
                        : selectedMissionIds
                            .where((id) => id != mission.id)
                            .toSet(),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  mission.reward.rewardName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: MissionStatusChip(status: mission.status),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${NumberFormat('#,###').format(mission.reward.rewardAmount)}원',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 24),
              if (isDesktopView)
                Expanded(
                  flex: 3,
                  child: Text(
                    '${DateFormat('MM/dd').format(mission.reward.startDate)} - ${DateFormat('MM/dd').format(mission.reward.endDate)}',
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                flex: 2,
                child: Text(
                  '${NumberFormat('#,###').format(mission.totalRewardUsage)}원',
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${NumberFormat('#,###').format(mission.remainingRewardBudget)}원',
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 48,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('상세보기'),
                    ),
                    if (isActive || isScheduled) ...[
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('수정'),
                      ),
                    ],
                    if (isScheduled) ...[
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('삭제'),
                      ),
                    ],
                    if (isActive) ...[
                      const PopupMenuItem(
                        value: 'ACTIVE',
                        child: Text('진행중으로 변경'),
                      ),
                    ] else if (isScheduled) ...[
                      const PopupMenuItem(
                        value: 'ACTIVE',
                        child: Text('진행중으로 변경'),
                      ),
                    ],
                  ],
                  onSelected: (value) async {
                    if (value == 'view') {
                      onMissionTap(mission);
                    } else if (value == 'edit') {
                      final locale =
                          Localizations.localeOf(context).languageCode;
                      context.go('/$locale/sales/reward-write',
                          extra: {'mission': mission});
                    } else if (value == 'delete') {
                      // _handleDeleteids: selectedMissionIds.toList()(context, mission);
                    } else {
                      onSelectionChanged(
                        selectedMissionIds
                            .where((id) => id != mission.id)
                            .toSet(),
                      );
                      onRefresh();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDelete(BuildContext context, StoreMissionResponse mission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('리워드 삭제'),
        content: const Text('정말로 이 리워드를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              StoreMissionCommandService.deleteStoreMission(
                context: context,
                id: mission.id,
              );
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Widget _buildTableBody(BuildContext context) {
    return ListView.separated(
      itemCount: missions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => _buildTableRow(context, missions[index]),
    );
  }

  Widget _buildSelectionActions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            '${selectedMissionIds.length}개 선택됨',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          FilledButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('선택 삭제'),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('미션 삭제'),
                  content:
                      Text('선택한 ${selectedMissionIds.length}개의 미션을 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                // await StoreMissionCommandService.deleteStoreMissions(
                  // context: context,
                  // ids: selectedMissionIds.toList(),
                // );
                onSelectionChanged({});
                onRefresh();
              }
            },
          ),
        ],
      ),
    );
  }
}
