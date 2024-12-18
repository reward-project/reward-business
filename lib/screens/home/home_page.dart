import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive.dart';
import 'package:flutter/foundation.dart';

class HomePage extends StatelessWidget {
  final Locale locale;
  final Widget child;

  const HomePage({super.key, required this.locale, required this.child});

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
            onTap: () => context.go('/$currentLocale/sales/store-mission'),
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
      await authProvider.logout();

      if (kDebugMode) {
        print('Local logout completed');
        print('Auth state: ${authProvider.isAuthenticated}');
      }

      if (context.mounted) {
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

  @override
  Widget build(BuildContext context) {
    final isMobileDevice = isMobile(context);
    
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
            child: child,
          ),
        ],
      ),
    );
  }
}
