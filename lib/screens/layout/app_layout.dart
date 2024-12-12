import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive.dart';
import 'package:flutter/foundation.dart';

class AppLayout extends StatelessWidget {
  final Locale locale;
  final Widget child;

  const AppLayout({super.key, required this.locale, required this.child});

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
            child: FutureBuilder<UserInfo?>(
              future: context.read<AuthProvider>().user,
              builder: (context, snapshot) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person, size: 30),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.data?.userName ?? "사용자",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      snapshot.data?.email ?? "",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ExpansionTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('재무 관리'),
            initiallyExpanded: true,
            children: [
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('리워드 충전'),
                contentPadding: const EdgeInsets.only(left: 72),
                onTap: () => context.go('/$currentLocale/charge'),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('거래 내역'),
                contentPadding: const EdgeInsets.only(left: 72),
                onTap: () => context.go('/$currentLocale/finance/transactions'),
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.list),
            title: const Text('리워드 관리'),
            children: [
              ListTile(
                leading: const Icon(Icons.view_list),
                title: const Text('리워드 목록'),
                contentPadding: const EdgeInsets.only(left: 72),
                selected: true,
                onTap: () => context.go('/$currentLocale/sales/store-mission'),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('리워드 추가'),
                contentPadding: const EdgeInsets.only(left: 72),
                onTap: () => context.go('/$currentLocale/sales/reward-write'),
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
    final currentRoute = GoRouterState.of(context).uri.toString();
    final isMainPage = currentRoute.endsWith('/sales/store-mission') || 
                      currentRoute.endsWith('/home');
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !isMainPage,
        leading: isMainPage 
          ? (isMobileDevice ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ) : null)
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
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
