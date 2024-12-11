import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reward/models/store_mission/store_mission_response.dart';
import 'package:reward/screens/sales/widgets/mission_status_chip.dart';
import 'package:reward/services/store_mission_command_service.dart';

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
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Checkbox(
              value: selectedMissionIds.length == missions.length,
              tristate: selectedMissionIds.isNotEmpty && selectedMissionIds.length != missions.length,
              onChanged: (bool? value) {
                if (value == true) {
                  onSelectionChanged(missions.map((m) => m.id).toSet());
                } else {
                  onSelectionChanged({});
                }
              },
            ),
          ),
          const Expanded(flex: 3, child: Text('미션명', style: TextStyle(fontWeight: FontWeight.w600))),
          const Expanded(child: Text('상태', style: TextStyle(fontWeight: FontWeight.w600))),
          const Expanded(flex: 2, child: Text('리워드 단가', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
          const Expanded(flex: 2, child: Text('사용량', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
          const Expanded(flex: 2, child: Text('잔액', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
          const Expanded(flex: 2, child: Text('종료일', style: TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTableBody(BuildContext context) {
    return ListView.separated(
      itemCount: missions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final mission = missions[index];
        return _MissionTableRow(
          mission: mission,
          isSelected: selectedMissionIds.contains(mission.id),
          onTap: () => onMissionTap(mission),
          onSelectionChanged: (selected) {
            final newSelection = Set<int>.from(selectedMissionIds);
            if (selected) {
              newSelection.add(mission.id);
            } else {
              newSelection.remove(mission.id);
            }
            onSelectionChanged(newSelection);
          },
          onStatusChanged: (status) async {
            await StoreMissionCommandService.updateMissionStatus(
              context: context,
              missionId: mission.id,
              newStatus: status,
            );
            onRefresh();
          },
        );
      },
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
                  content: Text('선택한 ${selectedMissionIds.length}개의 미션을 삭제하시겠습니까?'),
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
                await StoreMissionCommandService.deleteStoreMissions(
                  context: context,
                  missionIds: selectedMissionIds.toList(),
                );
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

class _MissionTableRow extends StatelessWidget {
  final StoreMissionResponse mission;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(bool) onSelectionChanged;
  final Function(String) onStatusChanged;

  const _MissionTableRow({
    required this.mission,
    required this.isSelected,
    required this.onTap,
    required this.onSelectionChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = mission.status == 'ACTIVE';
    final bool isPending = mission.status == 'PENDING';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1)
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (selected) => onSelectionChanged(selected!),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  mission.reward.rewardName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: MissionStatusChip(status: mission.status),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${NumberFormat('#,###').format(mission.reward.rewardAmount)}원',
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${NumberFormat('#,###').format(mission.totalRewardUsage)}원',
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${NumberFormat('#,###').format(mission.remainingRewardBudget)}원',
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(DateFormat('yy/MM/dd').format(mission.reward.endDate)),
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
                    if (isActive || isPending) ...[
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('수정'),
                      ),
                    ],
                    if (isPending) ...[
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('삭제'),
                      ),
                    ],
                    if (isActive) ...[
                      const PopupMenuItem(
                        value: 'COMPLETED',
                        child: Text('완료로 변경'),
                      ),
                      const PopupMenuItem(
                        value: 'FAILED',
                        child: Text('실패로 변경'),
                      ),
                    ] else if (isPending) ...[
                      const PopupMenuItem(
                        value: 'ACTIVE',
                        child: Text('진행중으로 변경'),
                      ),
                    ],
                  ],
                  onSelected: (value) {
                    if (value == 'view') {
                      onTap();
                    } else {
                      onStatusChanged(value);
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
}
