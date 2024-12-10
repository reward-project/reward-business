import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/dio_service.dart';
import '../../utils/responsive.dart';
import 'package:flutter/foundation.dart';

class HomePage extends StatelessWidget {
  final Locale locale;

  const HomePage({super.key, required this.locale});

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        final currentLocale = Localizations.localeOf(context).languageCode;
        context.go('/$currentLocale/sales/store-mission');
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.1), width: 1),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.1),
              ],
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Icon(icon, color: color, size: 28),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '최근 활동',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('전체보기'),
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: 5,
                separatorBuilder: (context, index) => const Divider(height: 32),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.notifications, color: Colors.blue),
                    ),
                    title: Row(
                      children: [
                        Text(
                          '활동 ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '완료',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text('상세 내용'),
                    ),
                    trailing: const Text(
                      '방금 전',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobileDevice = isMobile(context);
    
    Widget mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '대시보드',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '오늘도 좋은 하루 되세요!',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('보고서 다운로드'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: isMobileDevice ? 1 : 
                        isTablet(context) ? 2 : 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildStatCard(
              context,
              '총 리워드',
              '1,234',
              Icons.card_giftcard,
              Colors.blue,
            ),
            _buildStatCard(
              context,
              '활성 리워드',
              '789',
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              context,
              '대기 중',
              '123',
              Icons.pending,
              Colors.orange,
            ),
            _buildStatCard(
              context,
              '완료됨',
              '322',
              Icons.done_all,
              Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (isMobileDevice)
          SizedBox(
            height: 400,
            child: _buildRecentActivityCard(),
          )
        else
          Expanded(
            child: _buildRecentActivityCard(),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      drawer: isMobileDevice ? _buildDrawer(context) : null,
      body: Row(
        children: [
          if (!isMobileDevice)
            SizedBox(
              width: 250,
              child: _buildDrawer(context),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isMobileDevice
                  ? SingleChildScrollView(child: mainContent)
                  : mainContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 30),
                ),
                const SizedBox(height: 8),
                Text(
                  context.read<AuthProvider>().currentUser?.userName ?? "사용자",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  context.read<AuthProvider>().currentUser?.email ?? "",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('대시보드'),
            selected: true,
            onTap: () => context.go('/$currentLocale/home'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('리워드 충전'),
            onTap: () => context.go('/$currentLocale/charge'),
          ),
          ExpansionTile(
            leading: const Icon(Icons.list),
            title: const Text('리워드 관리'),
            children: [
              ListTile(
                leading: const Icon(Icons.view_list),
                title: const Text('리워드 목록'),
                contentPadding: const EdgeInsets.only(left: 72),
                onTap: () => context.go('/$currentLocale/sales/store-mission'),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('리워드 추가'),
                contentPadding: const EdgeInsets.only(left: 72),
                onTap: () {},
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('설정'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      if (kDebugMode) print('Attempting logout');
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dio = DioService.instance;
      await dio.post('/members/logout');
      
      if (kDebugMode) print('Server logout successful');

      if (context.mounted) {
        await authProvider.logout();

        if (kDebugMode) {
          print('Local logout completed');
          print('Auth state: ${authProvider.isAuthenticated}');
        }

        final currentLocale = Localizations.localeOf(context).languageCode;
        context.go('/$currentLocale/login');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
      if (context.mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();
        
        final currentLocale = Localizations.localeOf(context).languageCode;
        context.go('/$currentLocale/login');
      }
    }
  }
}
