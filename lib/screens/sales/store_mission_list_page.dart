import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/reward.dart';
import '../../services/dio_service.dart';
import '../../providers/auth_provider.dart';

class StoreMissionListPage extends StatefulWidget {
  const StoreMissionListPage({super.key});

  @override
  State<StoreMissionListPage> createState() => _StoreMissionListPageState();
}

class _StoreMissionListPageState extends State<StoreMissionListPage> {
  List<Reward> salesRewards = [];
  final Set<String> selectedRewards = {};
  bool selectAll = false;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSalesRewards();
  }

  Future<void> _fetchSalesRewards() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.userId;
      if (userId != null) {
        final dio = DioService.getInstance(context);
        final response =
            await dio.post('/reward/sales/list', data: {'userId': userId});

        if (response.data['success'] && response.data['data'] != null) {
          setState(() {
            salesRewards = (response.data['data'] as List)
                .map((item) => Reward.fromJson(item))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching rewards: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            final currentLocale = Localizations.localeOf(context).languageCode;
            context.go('/$currentLocale/home');
          },
        ),
        title: Text(
          '리워드 관리',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 정보 카드
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue.shade50,
                                  child: const Icon(Icons.person, color: Colors.blue),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.read<AuthProvider>().user?.userName ?? "",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '관리자',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildInfoItem(
                              icon: Icons.inventory_2,
                              label: '슬롯 전체 개수',
                              value: '50',
                            ),
                            const SizedBox(height: 12),
                            _buildInfoItem(
                              icon: Icons.check_circle,
                              label: '가용 개수',
                              value: '5',
                              valueColor: Colors.green,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.swap_horiz),
                              label: const Text('사용자 변경'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                final currentLocale = Localizations.localeOf(context).languageCode;
                                context.go('/$currentLocale/sales/reward-write');
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('리워드 추가'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 24,
                                ),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 검색 및 필터 영역
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: '리워드 검색',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('선택 삭제'),
                    onPressed: selectedRewards.isEmpty ? null : () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 데이터 테이블
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  height: 400,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 600,
                      smRatio: 0.75,
                      lmRatio: 1.5,
                      columns: const [
                        DataColumn2(label: Text('선택'), size: ColumnSize.S),
                        DataColumn2(label: Text('No'), size: ColumnSize.S),
                        DataColumn2(label: Text('사용자ID')),
                        DataColumn2(label: Text('리워드ID')),
                        DataColumn2(label: Text('관리자')),
                        DataColumn2(label: Text('생성여부')),
                        DataColumn2(label: Text('상품URL')),
                        DataColumn2(label: Text('키워드')),
                      ],
                      rows: salesRewards.asMap().entries.map((entry) {
                        final index = entry.key;
                        final reward = entry.value;
                        return DataRow(
                          cells: [
                            DataCell(Checkbox(
                              value: selectedRewards.contains(reward.rewardId),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedRewards.add(reward.rewardId);
                                  } else {
                                    selectedRewards.remove(reward.rewardId);
                                  }
                                });
                              },
                            )),
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(reward.advertiserId)),
                            DataCell(Text(reward.rewardId)),
                            DataCell(Text(
                                context.read<AuthProvider>().user?.userName ??
                                    "")),
                            DataCell(Text(reward.rewardStatus)),
                            DataCell(Text(reward.productUrl)),
                            DataCell(Text(reward.keyword)),
                          ],
                        );
                      }).toList(),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
