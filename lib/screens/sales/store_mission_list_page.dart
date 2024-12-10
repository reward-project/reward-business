import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/store_mission_command_service.dart';
import '../../services/store_mission_query_service.dart';
import '../../models/store_mission/store_mission_response.dart';
import '../../models/store_mission/store_mission_stats.dart';
import '../../widgets/custom_date_range_picker.dart';
import 'store_mission_detail_page.dart';

class StoreMissionListPage extends StatefulWidget {
  const StoreMissionListPage({super.key});

  @override
  State<StoreMissionListPage> createState() => _StoreMissionListPageState();
}

class _StoreMissionListPageState extends State<StoreMissionListPage> {
  List<StoreMissionResponse> _missions = [];
  StoreMissionStats? _stats;
  final Set<int> _selectedMissionIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '전체';
  String _selectedPlatform = '전체';
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;
  List<StoreMissionResponse> _filteredMissions = [];

  @override
  void initState() {
    super.initState();
    debugPrint('initState called');
    _searchController.addListener(_filterMissions);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      debugPrint('Current auth state - isAuthenticated: ${authProvider.isAuthenticated}');
      debugPrint('User info already exists, loading missions...');
      _loadStoreMissions();
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStoreMissions() async {
    debugPrint('_loadStoreMissions started');
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      debugPrint('Auth state - isAuthenticated: ${authProvider.isAuthenticated}');
      final userInfo = await authProvider.user;
      debugPrint('User info: ${userInfo?.toString()}');

      if (!authProvider.isAuthenticated || userInfo?.userId == null) {
        debugPrint('No valid user found - showing error');
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.')),
        );
        return;
      }

      final userId = userInfo!.userId;
      debugPrint('Fetching missions for user: $userId');
      final missions = await StoreMissionQueryService.getStoreMissionsByRegistrant(context, userId);
      debugPrint('Missions fetched: ${missions.length}');
      
      final stats = await StoreMissionQueryService.getStoreMissionStats(context, userId);
      debugPrint('Stats fetched');

      if (!mounted) return;

      setState(() {
        _missions = missions;
        _filteredMissions = missions;
        _stats = stats;
        _isLoading = false;
      });
      debugPrint('State updated with missions');
    } catch (e) {
      debugPrint('Error in _loadStoreMissions: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('미션 목록을 불러오는데 실패했습니다: $e')),
      );
    }
  }

  void _filterMissions() {
    if (_missions.isEmpty) return;

    setState(() {
      _filteredMissions = _missions.where((mission) {
        // 검색어 필터
        if (_searchController.text.isNotEmpty) {
          final searchTerm = _searchController.text.toLowerCase();
          if (!mission.reward.rewardName.toLowerCase().contains(searchTerm) &&
              !mission.store.storeName.toLowerCase().contains(searchTerm)) {
            return false;
          }
        }

        // 상태 필터
        if (_selectedStatus != '전체' && _selectedStatus != '') {
          if (mission.status != _getStatusValue(_selectedStatus)) {
            return false;
          }
        }

        // 플랫폼 필터
        if (_selectedPlatform != '전체' && _selectedPlatform != '') {
          if (mission.platform.name != _selectedPlatform) {
            return false;
          }
        }

        // 날짜 범위 필터
        if (_selectedDateRange != null) {
          if (mission.reward.startDate.isBefore(_selectedDateRange!.start) ||
              mission.reward.endDate.isAfter(_selectedDateRange!.end)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  String _getStatusValue(String displayStatus) {
    switch (displayStatus) {
      case '진행중':
        return 'ACTIVE';
      case '완료':
        return 'COMPLETED';
      case '실패':
        return 'FAILED';
      default:
        return displayStatus;
    }
  }

  Future<void> _updateMissionStatus(BuildContext context, int missionId, String newStatus) async {
    try {
      await StoreMissionCommandService.updateMissionStatus(
        context: context,
        missionId: missionId,
        newStatus: newStatus,
      );
      await _loadStoreMissions();
    } catch (e) {
      debugPrint('Error updating mission status: $e');
    }
  }

  Future<void> _deleteSelectedMissions(BuildContext context) async {
    try {
      await StoreMissionCommandService.deleteStoreMissions(
        context: context,
        missionIds: _selectedMissionIds.toList(),
      );
      await _loadStoreMissions();
    } catch (e) {
      debugPrint('Error deleting selected missions: $e');
    }
  }

  Widget _buildStatsCard() {
    if (_stats == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('전체 미션', _stats!.totalMissions.toString()),
            _buildStatItem('진행중', _stats!.activeMissions.toString()),
            _buildStatItem('완료', _stats!.completedMissions.toString()),
            _buildStatItem('성공률', '${_stats!.successRate.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '미션명, 상품명 검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: ['전체', '진행중', '완료', '실패']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedStatus = value!);
                      _filterMissions();
                    },
                    decoration: const InputDecoration(
                      labelText: '상태',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPlatform,
                    items: ['전체', '쿠팡', '네이버']
                        .map((platform) => DropdownMenuItem(
                              value: platform,
                              child: Text(platform),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedPlatform = value!);
                      _filterMissions();
                    },
                    decoration: const InputDecoration(
                      labelText: '플랫폼',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomDateRangePicker(
              dateRange: _selectedDateRange,
              onDateRangeChanged: (range) {
                setState(() => _selectedDateRange = range);
                _filterMissions();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionTable() {
    if (_missions.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: SizedBox(
        height: 500,
        child: DataTable2(
          columns: const [
            DataColumn2(label: Text('No.'), size: ColumnSize.S),
            DataColumn2(label: Text('상태'), size: ColumnSize.S),
            DataColumn2(label: Text('플랫폼'), size: ColumnSize.S),
            DataColumn2(label: Text('미션명')),
            DataColumn2(label: Text('상품명')),
            DataColumn2(label: Text('리워드'), numeric: true, size: ColumnSize.S),
            DataColumn2(label: Text('사용량'), numeric: true, size: ColumnSize.S),
            DataColumn2(label: Text('잔액'), numeric: true, size: ColumnSize.S),
            DataColumn2(label: Text('시작일'), size: ColumnSize.M),
            DataColumn2(label: Text('종료일'), size: ColumnSize.M),
            DataColumn2(label: Text('액션'), size: ColumnSize.M),
          ],
          rows: _missions.asMap().entries.map((entry) {
            final index = entry.key;
            final mission = entry.value;
            return DataRow2(
              selected: _selectedMissionIds.contains(mission.id),
              onSelectChanged: (selected) {
                setState(() {
                  if (selected!) {
                    _selectedMissionIds.add(mission.id);
                  } else {
                    _selectedMissionIds.remove(mission.id);
                  }
                });
              },
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(_buildStatusChip(mission.status)),
                DataCell(Text(mission.platform.name)),
                DataCell(Text(mission.reward.rewardName)),
                DataCell(Text(mission.store.storeName)),
                DataCell(Text('${NumberFormat('#,###').format(mission.reward.rewardAmount)}원')),
                DataCell(Text('${NumberFormat('#,###').format(mission.totalRewardUsage)}원')),
                DataCell(Text('${NumberFormat('#,###').format(mission.remainingRewardBudget)}원')),
                DataCell(Text(DateFormat('yy/MM/dd').format(mission.reward.startDate))),
                DataCell(Text(DateFormat('yy/MM/dd').format(mission.reward.endDate))),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoreMissionDetailPage(
                              mission: mission,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: 수정 구현
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('미션 삭제'),
                            content: const Text('선택한 미션을 삭제하겠습니까?'),
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
                            missionIds: [mission.id],
                          );
                          _loadStoreMissions();
                        }
                      },
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'ACTIVE':
        color = Colors.blue;
        label = '진행중';
        break;
      case 'COMPLETED':
        color = Colors.green;
        label = '완���';
        break;
      case 'FAILED':
        color = Colors.red;
        label = '실패';
        break;
      default:
        color = Colors.grey;
        label = '알 수 없음';
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
    );
  }

  Widget _buildBottomActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('새 미션 등록'),
              onPressed: () {
                final locale = Localizations.localeOf(context).languageCode;
                context.go('/$locale/sales/reward-write');
              },
            ),
            if (_selectedMissionIds.isNotEmpty) ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: Text('선택 미션 삭제 (${_selectedMissionIds.length})'),
                onPressed: () async {
                  await _deleteSelectedMissions(context);
                },
              ),
              const SizedBox(width: 16),
              PopupMenuButton<String>(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.update),
                  label: Text('상태 변경 (${_selectedMissionIds.length})'),
                  onPressed: null,
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'ACTIVE',
                    child: Text('진행중으로 변경'),
                  ),
                  const PopupMenuItem(
                    value: 'COMPLETED',
                    child: Text('완료로 변경'),
                  ),
                  const PopupMenuItem(
                    value: 'FAILED',
                    child: Text('실패로 변경'),
                  ),
                ],
                onSelected: (status) async {
                  for (final missionId in _selectedMissionIds) {
                    await _updateMissionStatus(context, missionId, status);
                  }
                  setState(() => _selectedMissionIds.clear());
                  _loadStoreMissions();
                },
              ),
            ],
          ],
        ),
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
        title: const Text('스토어 미션 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '정렬 기준',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...['등록일', '시작일', '종료일', '리워드'].map((field) {
                        return ListTile(
                          title: Text(field),
                          onTap: () {
                            setState(() => _selectedStatus = field);
                            _filterMissions();
                            Navigator.pop(context);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildStatsCard(),
                const SizedBox(height: 16),
                _buildFilterSection(),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildMissionTable(),
                ),
                const SizedBox(height: 16),
                _buildBottomActions(),
              ],
            ),
    );
  }
}
