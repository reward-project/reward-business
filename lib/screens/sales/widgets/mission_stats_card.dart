import 'package:flutter/material.dart';
import 'package:reward/models/store_mission/store_mission_response.dart';

class MissionStatsCard extends StatelessWidget {
  final List<StoreMissionResponse> missions;

  const MissionStatsCard({
    super.key,
    required this.missions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                '진행중인 미션',
                missions.where((m) => m.status == 'ACTIVE').length.toString(),
                Theme.of(context).colorScheme.primary,
              ),
            ),
            VerticalDivider(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              thickness: 1,
            ),
            Expanded(
              child: _buildStatItem(
                context,
                '대기중인 미션',
                missions.where((m) => m.status == 'PENDING').length.toString(),
                Theme.of(context).colorScheme.secondary,
              ),
            ),
            VerticalDivider(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              thickness: 1,
            ),
            Expanded(
              child: _buildStatItem(
                context,
                '완료된 미션',
                missions.where((m) => m.status == 'COMPLETED').length.toString(),
                Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}
