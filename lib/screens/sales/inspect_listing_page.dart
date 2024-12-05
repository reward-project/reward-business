import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:provider/provider.dart';
import '../../models/reward.dart';
import '../../services/dio_service.dart';
import '../../providers/auth_provider.dart';

class InspectListingPage extends StatefulWidget {
  const InspectListingPage({super.key});

  @override
  State<InspectListingPage> createState() => _InspectListingPageState();
}

class _InspectListingPageState extends State<InspectListingPage> {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '리워드 관리: ${context.read<AuthProvider>().user?.userName ?? ""}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 사용자 정보 카드와 버튼들
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '사용자: ${context.read<AuthProvider>().user?.userName ?? ""}'),
                            const Text('슬롯 전체 개수: 50'),
                            const Text('전체 개수중 가용 개수: 5'),
                            const Text('등록자: A1'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Text('사용자변경'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'KKY',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('리워드 추가 신청하기'),
                            onPressed: () {
                              // 리워드 추가 페이지로 이동
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 검색 및 액션 버튼
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'KKY 검색',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('선택 삭제'),
                    onPressed: selectedRewards.isEmpty
                        ? null
                        : () {
                            // 선택된 항목 삭제 로직
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 데이터 테이블
              SizedBox(
                width: double.infinity,
                height: 600, // 테이블 높이 지정
                child: Card(
                  child: DataTable2(
                    columns: const [
                      DataColumn2(label: Text('선택'), size: ColumnSize.S),
                      DataColumn2(label: Text('No'), size: ColumnSize.S),
                      DataColumn2(label: Text('사용자ID')),
                      DataColumn2(label: Text('리워드ID')),
                      DataColumn2(label: Text('관리자')),
                      DataColumn2(label: Text('생성여부')),
                      DataColumn2(label: Text('상품URL')),
                      DataColumn2(label: Text('키워드')),
                      // ... 나머지 컬럼들
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
                          // ... 나머지 셀들
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
