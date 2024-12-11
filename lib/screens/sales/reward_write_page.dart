import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/store_mission/store_mission_response.dart';
import '../../services/dio_service.dart';
import '../../providers/auth_provider.dart';
import '../../services/store_mission_command_service.dart';
import 'components/reward_form.dart';

class RewardWritePage extends StatefulWidget {
  final StoreMissionResponse? mission;
  final String? missionId;

  const RewardWritePage({
    super.key,
    this.mission,
    this.missionId,
  });

  @override
  State<RewardWritePage> createState() => _RewardWritePageState();
}

class _RewardWritePageState extends State<RewardWritePage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _formData;
  bool _isLoading = false;

  Future<void> _handleSubmit(Map<String, dynamic> data) async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('폼 데이터가 없습니다.')),
        );
        return;
      }

      try {
        String? missionId = widget.mission?.id?.toString() ?? widget.missionId;
        if (missionId != null) {
          // 수정
          await StoreMissionCommandService.updateStoreMission(
            context: context,
            id: int.parse(missionId),
            formData: data,
          );
        } else {
          // 생성
          await StoreMissionCommandService.createStoreMission(
            context: context,
            formData: data,
          );
        }
      } catch (e) {
        debugPrint('Error submitting form: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMissionData();
  }

  Future<void> _loadMissionData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? missionId = widget.mission?.id?.toString() ?? widget.missionId;
      if (missionId == null) {
        _initFormData();
        return;
      }

      print('Fetching mission data for ID: $missionId'); // 디버깅용 로그
      final response = await DioService.instance.get('/store-missions/$missionId/edit');
      print('Response received: ${response.data}'); // 디버깅용 로그

      if (response.statusCode == 200) {
        final mission = StoreMissionResponse.fromJson(response.data['data']);
        setState(() {
          _formData = {
            'rewardName': mission.reward.rewardName,
            'platformId': mission.platform.id,
            'storeName': mission.store.storeName,
            'productLink': mission.store.productLink,
            'keyword': mission.store.keyword,
            'productId': mission.store.productId,
            'rewardAmount': mission.reward.rewardAmount,
            'maxRewardsPerDay': mission.reward.maxRewardsPerDay,
            'startDate': mission.reward.startDate,
            'endDate': mission.reward.endDate,
            'tags': mission.tags.toList(),
          };
        });
      }
    } catch (e) {
      print('Error loading mission data: $e'); // 디버깅용 로그
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('미션 데이터를 불러오는데 실패했습니다: $e')),
      );
      _initFormData();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _getMissionIdFromUrl() {
    final uri = Uri.base;
    final pathSegments = uri.pathSegments;
    // URL 패턴이 /store-missions/1/edit 형식이라고 가정
    if (pathSegments.length >= 2 && pathSegments[0] == 'store-missions') {
      return pathSegments[1];
    }
    return null;
  }

  void _initFormData() {
    setState(() {
      _formData = {
        'rewardName': '',
        'platformId': null,
        'storeName': '',
        'productLink': '',
        'keyword': '',
        'productId': '',
        'rewardAmount': 0,
        'maxRewardsPerDay': 0,
        'startDate': DateTime.now(),
        'endDate': DateTime.now().add(const Duration(days: 7)),
        'tags': <String>[],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mission != null ? '리워드 수정' : '리워드 등록'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: RewardForm(
                          formData: _formData,
                          onSubmit: (data) async {
                            await _handleSubmit(data);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
