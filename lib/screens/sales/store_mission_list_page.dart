import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reward/models/store_mission/store_mission_response.dart';
import 'package:reward/models/store_mission/store_mission_stats.dart';
import 'package:reward/screens/sales/widgets/mission_detail_view.dart';
import 'package:reward/screens/sales/widgets/mission_stats_card.dart';
import 'package:reward/screens/sales/widgets/mission_table.dart';
import 'package:reward/services/store_mission_query_service.dart';
import 'widgets/mission_filter_section.dart';
import 'widgets/mission_filter_dialog.dart';
import 'widgets/mission_sort_dialog.dart';

class StoreMissionListPage extends StatefulWidget {
  const StoreMissionListPage({super.key});

  @override
  State<StoreMissionListPage> createState() => _StoreMissionListPageState();
}

class _StoreMissionListPageState extends State<StoreMissionListPage> {
  bool _isLoading = false;
  List<StoreMissionResponse> _missions = [];
  List<StoreMissionResponse> _filteredMissions = [];
  Set<int> _selectedMissionIds = {};
  StoreMissionStats? _stats;
  String _selectedPlatform = '전체';
  DateTimeRange? _selectedDateRange;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;
  MissionSortField? _sortField;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _loadStoreMissions();
  }

  Future<void> _loadStoreMissions() async {
    setState(() => _isLoading = true);
    try {
      final response = await StoreMissionQueryService.getStoreMissionsByRegistrant(
        context,
        '1',  // TODO: Get actual registrant ID
      );
      setState(() {
        _missions = response;
        _filteredMissions = _missions;
      });
      await _loadStoreMissionStats();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStoreMissionStats() async {
    try {
      final stats = await StoreMissionQueryService.getStoreMissionStats(context, '1');
      setState(() => _stats = stats);
    } catch (e) {
      // 통계 로딩 실패는 무시
    }
  }

  void _navigateToDetail(StoreMissionResponse mission) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: MissionDetailView(
          mission: mission,
          onClose: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredMissions = _missions.where((mission) {
        // 상태 필터
        if (_selectedStatus != null && mission.status != _selectedStatus) {
          return false;
        }

        // 날짜 필터
        if (_startDate != null && mission.reward.startDate.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && mission.reward.endDate.isAfter(_endDate!)) {
          return false;
        }

        return true;
      }).toList();
      if (_sortField != null) {
        _applySorting();
      }
    });
  }

  void _applySorting() {
    if (_sortField == null) return;
    
    setState(() {
      _filteredMissions.sort((a, b) {
        int comparison;
        switch (_sortField!) {
          case MissionSortField.rewardAmount:
            comparison = a.reward.rewardAmount.compareTo(b.reward.rewardAmount);
            break;
          case MissionSortField.startDate:
            comparison = a.reward.startDate.compareTo(b.reward.startDate);
            break;
          case MissionSortField.endDate:
            comparison = a.reward.endDate.compareTo(b.reward.endDate);
            break;
          case MissionSortField.createdAt:
            if (a.createdAt == null && b.createdAt == null) {
              comparison = 0;
            } else if (a.createdAt == null) {
              comparison = -1;  // null을 가장 앞으로
            } else if (b.createdAt == null) {
              comparison = 1;   // null을 가장 앞으로
            } else {
              comparison = a.createdAt!.compareTo(b.createdAt!);
            }
            break;
        }
        return _isAscending ? comparison : -comparison;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: const Text('미션 관리', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final locale = Localizations.localeOf(context).languageCode;
              context.go('/$locale/sales/reward-write');
            },
            tooltip: '새 미션 추가',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStoreMissions,
            tooltip: '새로고침',
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        '전체 미션 ${_missions.length}개',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.filter_list),
                            label: const Text('필터'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => MissionFilterDialog(
                                  startDate: _startDate,
                                  endDate: _endDate,
                                  selectedStatus: _selectedStatus,
                                  onApply: (start, end, status) {
                                    setState(() {
                                      _startDate = start;
                                      _endDate = end;
                                      _selectedStatus = status;
                                    });
                                    _applyFilters();
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.sort),
                            label: const Text('정렬'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => MissionSortDialog(
                                  currentSortField: _sortField,
                                  isAscending: _isAscending,
                                  onApply: (field, ascending) {
                                    setState(() {
                                      _sortField = field;
                                      _isAscending = ascending;
                                    });
                                    _applySorting();
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_stats != null) MissionStatsCard(missions: _missions),
                  const SizedBox(height: 24),
                  Expanded(
                    child: MissionTable(
                      missions: _filteredMissions,
                      selectedMissionIds: _selectedMissionIds,
                      onMissionTap: _navigateToDetail,
                      onSelectionChanged: (newSelection) {
                        setState(() => _selectedMissionIds = newSelection);
                      },
                      onRefresh: _loadStoreMissions,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
