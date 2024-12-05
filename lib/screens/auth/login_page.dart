import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import '../../constants/styles.dart';
import '../../models/api_response.dart';
import '../../widgets/common/filled_text_field.dart';
import '../../widgets/common/language_dropdown.dart';
import 'package:go_router/go_router.dart';
import '../../services/dio_service.dart';
import '../../widgets/auth/google_login_button.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import '../../models/token_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../utils/responsive.dart';
class LoginPage extends StatefulWidget {
  final Locale? locale;

  const LoginPage({super.key, this.locale});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  late Dio _dio;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('savedEmail') ?? '';
        _passwordController.text = prefs.getString('savedPassword') ?? '';
      }
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('savedEmail', _emailController.text);
      await prefs.setString('savedPassword', _passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('savedEmail');
      await prefs.remove('savedPassword');
      await prefs.setBool('rememberMe', false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dio = DioService.getInstance(context);
  }

  Future<void> _handleLogin() async {
    try {
      final response = await _dio.post(
        '/members/login',
        data: {
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => TokenDto.fromJson(json as Map<String, dynamic>),
      );

      if (mounted && apiResponse.success && apiResponse.data != null) {
        await _saveCredentials();

        final tokenDto = apiResponse.data!;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.setTokens(
          accessToken: tokenDto.accessToken,
          refreshToken: tokenDto.refreshToken,
        );

        final userInfo = await authProvider.fetchUserInfo();
        
        if (mounted && userInfo != null) {
          final currentLocale = Localizations.localeOf(context).languageCode;
          
          switch (userInfo.role.toLowerCase()) {
            case 'business':
              context.go('/$currentLocale/sales/inspect-listing');
              break;
            case 'admin':
              context.go('/$currentLocale/admin/dashboard');
              break;
            default:
              _handleRewardAppLink();
              break;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
    }
  }

  Future<void> _handleRewardAppLink() async {
    final url = Uri.parse(AppConfig.rewardAppUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        FilledTextField(
          controller: _emailController,
          label: AppLocalizations.of(context).emailLabel,
          keyboardType: TextInputType.emailAddress,
          required: true,
        ),
        const SizedBox(height: 16),
        FilledTextField(
          controller: _passwordController,
          label: AppLocalizations.of(context).passwordLabel,
          obscureText: true,
          required: true,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
            Text(
              AppLocalizations.of(context).rememberCredentials,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _handleLogin,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 0),
            minimumSize: const Size.fromHeight(kElementHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
          ),
          child: Text(AppLocalizations.of(context).loginButton),
        ),
        const SizedBox(height: 16),
        const GoogleLoginButton(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context).noAccount),
            TextButton(
              onPressed: () {
                final currentLocale =
                    Localizations.localeOf(context).languageCode;
                context.go('/$currentLocale/signin');
              },
              child: Text(
                AppLocalizations.of(context).signUpButton,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSideMenu() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context).appTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Text(
            AppLocalizations.of(context).loginTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).loginDescription,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: _handleRewardAppLink,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              side: const BorderSide(color: Colors.white),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.card_giftcard, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).rewardAppLink,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Row(
        children: [
          if (!isMobile(context))
            Expanded(
              flex: isDesktop(context) ? 2 : 1,
              child: Container(
                color: Colors.green.shade600,
                child: _buildSideMenu(),
              ),
            ),
          
          Expanded(
            flex: isDesktop(context) ? 1 : 2,
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Stack(
                children: [
                  if (isMobile(context))
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.card_giftcard),
                          onPressed: _handleRewardAppLink,
                        ),
                        actions: const [
                          LanguageDropdown(),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),
                  
                  if (!isMobile(context))
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const LanguageDropdown(),
                      ),
                    ),
                  
                  Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile(context) ? 16 : 32),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: isMobile(context) ? double.infinity : 400,
                        ),
                        child: _buildLoginForm(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _sub?.cancel();
    super.dispose();
  }
}
