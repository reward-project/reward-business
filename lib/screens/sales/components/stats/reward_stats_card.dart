import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../models/store_mission/store_mission_stats.dart';

class RewardStatsCard extends StatelessWidget {
  final StoreMissionStats stats;

  const RewardStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicStats(),
            const Divider(height: 32),
            _buildRewardUsageStats(),
            const SizedBox(height: 24),
            _buildPlatformDistribution(),
            const SizedBox(height: 24),
            _buildDailyRewardChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('총 리워드', '${NumberFormat('#,###').format(stats.totalRewardAmount)}원'),
        _buildStatItem('평균 리워드', '${NumberFormat('#,###').format(stats.averageRewardAmount)}원'),
        _buildStatItem('성공률', '${stats.successRate.toStringAsFixed(1)}%'),
      ],
    );
  }

  Widget _buildPlatformDistribution() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: stats.missionsByPlatform.entries.map((entry) {
            return PieChartSectionData(
              value: entry.value.toDouble(),
              title: entry.key,
              radius: 80,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDailyRewardChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: stats.dailyStats.map((stat) {
                return FlSpot(
                  stat.date.millisecondsSinceEpoch.toDouble(),
                  stat.rewardAmount,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardUsageStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '리워드 사용 현황',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('총 리워드', '${NumberFormat('#,###').format(stats.totalRewardAmount)}원'),
            _buildStatItem('평균 리워드', '${NumberFormat('#,###').format(stats.averageRewardAmount)}원'),
            _buildStatItem('성공률', '${stats.successRate.toStringAsFixed(1)}%'),
          ],
        ),
      ],
    );
  }
} 