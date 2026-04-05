import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto/crypto.dart';

import 'package:mawlid_al_dhaki/features/auth/providers/auth_provider.dart';
import 'package:mawlid_al_dhaki/core/auth/auth0_service.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';

/// شاشة تسجيل الدخول — ألوان Coddy الداكنة ثابتة.
/// الخط: Baloo Bhaijaan 2 (عربي، دائري، مطابق لستايل Varela Round).
/// النصف الأيسر: بطاقات عرض ميزات المولد الذكي.
/// كل الأزرار مربوطة بوظائف حقيقية.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  bool _isRegisterMode = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _emailFocused = false;
  bool _passwordFocused = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // CODDY DARK THEME — ألوان ثابتة لا تتغير
  // ═══════════════════════════════════════════════════════════════

  static const _brandBright = Color(0xFF34B4E4);
  static const _brandPrimary = Color(0xFF1B78A0);
  static const _brandPrimaryDarker = Color(0xFF264D73);

  static const _bgPage = Color(0xFF252627);
  static const _bgCard = Color(0xFF2D2E2F);
  static const _bgInput = Color(0xFF252627);
  static const _bgLeftPanel = Color(0xFF1a1a2e);

  static const _textPrimary = Color(0xDEFFFFFF);
  static const _textSecondary = Color(0x99FFFFFF);
  static const _textDisabled = Color(0x4DFFFFFF);

  static const _borderColor = Color(0xFF3B3E41);
  static const _borderMid = Color(0xFF494D50);

  static const _coddyError = Color(0xFFA90404);

  // ═══════════════════════════════════════════════════════════════
  // الخط العربي — Baloo Bhaijaan 2
  // ═══════════════════════════════════════════════════════════════

  static const _font = 'BalooBhaijaan2';

  // ═══════════════════════════════════════════════════════════════
  // وظائف الأزرار — كل زر مربوط بوظيفة حقيقية
  // ═══════════════════════════════════════════════════════════════

  Future<void> _handleLogin() async {
    if (!_validateForm()) return;
    ref.read(authProvider.notifier).clearError();
    setState(() => _isLoading = true);
    try {
      final success = await ref.read(authProvider.notifier).loginWithAuth0();
      if (success && mounted) context.go('/dashboard');
    } catch (e) {
      debugPrint('Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ: ${e.toString()}'),
              backgroundColor: _coddyError),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    final url = Uri.parse(
      'https://${Auth0Config.domain}/authorize?'
      'response_type=code&client_id=${Auth0Config.clientId}&'
      'redirect_uri=${Auth0Config.redirectUri}&audience=${Auth0Config.audience}&'
      'scope=openid profile email&screen_hint=signup',
    );
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _handleForgotPassword() async {
    final url = Uri.parse(
      'https://${Auth0Config.domain}/dbconnections/change_password?'
      'client_id=${Auth0Config.clientId}&'
      'connection=Username-Password-Authentication&'
      'email=${Uri.encodeComponent(_emailController.text.trim())}',
    );
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _handleGoogleLogin() async {
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);
    final url = Uri.parse(
      'https://${Auth0Config.domain}/authorize?'
      'response_type=code&client_id=${Auth0Config.clientId}&'
      'redirect_uri=${Auth0Config.redirectUri}&audience=${Auth0Config.audience}&'
      'scope=openid profile email&connection=google-oauth2&'
      'code_challenge=$codeChallenge&code_challenge_method=S256&'
      'state=${_generateRandomString(32)}',
    );
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _handleGuestLogin() async {
    ref.read(authProvider.notifier).clearError();
    setState(() => _isLoading = true);
    try {
      final guestId = 'guest-${DateTime.now().millisecondsSinceEpoch}';
      await AppConvexConfig.setAuth('guest-token');
      ref.read(authProvider.notifier).state = AuthState(
        isAuthenticated: true,
        userId: guestId,
        accessToken: 'guest-token',
        role: UserRole.admin,
        isLoading: false,
      );
      if (mounted) context.go('/dashboard');
    } catch (e) {
      debugPrint('Guest login error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateForm() {
    bool valid = true;
    setState(() {
      _emailError = null;
      _passwordError = null;
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        _emailError = 'البريد الإلكتروني مطلوب';
        valid = false;
      } else if (!email.contains('@')) {
        _emailError = 'بريد إلكتروني غير صالح';
        valid = false;
      }
      if (_passwordController.text.isEmpty) {
        _passwordError = 'كلمة المرور مطلوبة';
        valid = false;
      }
    });
    return valid;
  }

  String _generateCodeVerifier() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = math.Random.secure();
    return List.generate(128, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url
        .encode(digest.bytes)
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
  }

  String _generateRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = math.Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  // ═══════════════════════════════════════════════════════════════
  // البناء
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final showLeftPanel = screenWidth >= 900;

    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Center(
          child: showLeftPanel
              ? _buildDesktopLayout(authState)
              : _buildMobileLayout(authState),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(AuthState authState) {
    return Row(
      children: [
        // ── النصف الأيسر: بطاقات عرض الميزات ─────────────────────
        Expanded(
          flex: 1,
          child: Container(
            color: _bgLeftPanel,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text('المولد الذكي', style: _headingStyle),
                const SizedBox(height: 8),
                Text('نظام إدارة مشتركي مولدات الكهرباء',
                    style: _subheadingStyle),
                const SizedBox(height: 48),
                _buildFeatureCard(
                  icon: Icons.dashboard_outlined,
                  title: 'لوحة تحكم شاملة',
                  desc: 'إدارة المشتركين والفواتير والمدفوعات',
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'فواتير آلية',
                  desc: 'إنشاء فواتير الكهرباء تلقائياً كل شهر',
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.notifications_active_outlined,
                  title: 'إشعارات واتساب',
                  desc: 'تنبيه المشتركين بالفواتير المتأخرة',
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.bar_chart_outlined,
                  title: 'تقارير مفصلة',
                  desc: 'إحصائيات الإيرادات والتحصيل الشهري',
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('الإصدار 1.0.0',
                        style: TextStyle(
                            fontSize: 12,
                            color: _textDisabled,
                            fontFamily: _font)),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── النصف الأيمن: بطاقة تسجيل الدخول ─────────────────────
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 375),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCard(authState),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AuthState authState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 375),
          child: _buildCard(authState),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      {required IconData icon, required String title, required String desc}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _brandBright.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _brandBright.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _brandBright.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: _brandBright),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _featureTitleStyle),
                const SizedBox(height: 2),
                Text(desc, style: _featureDescStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // بطاقة تسجيل الدخول
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCard(AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. الشعار والعنوان
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _brandBright.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.bolt, size: 36, color: _brandBright),
          ),
          const SizedBox(height: 12),
          Text('المولد الذكي', style: _cardTitleStyle),
          const SizedBox(height: 24),

          // 2. تبديل تسجيل / إنشاء حساب
          _buildTabs(),
          const SizedBox(height: 24),

          // 3. رسالة الخطأ
          if (authState.errorMessage != null)
            _buildErrorBanner(authState.errorMessage!),

          // 4. البريد الإلكتروني
          _buildInput(
            label: 'البريد الإلكتروني',
            icon: Icons.email_outlined,
            controller: _emailController,
            isPassword: false,
            errorText: _emailError,
            isFocused: _emailFocused,
            onFocusChange: (v) => setState(() => _emailFocused = v),
          ),
          const SizedBox(height: 16),

          // 5. كلمة المرور
          _buildInput(
            label: 'كلمة المرور',
            icon: Icons.lock_outline,
            controller: _passwordController,
            isPassword: true,
            errorText: _passwordError,
            isFocused: _passwordFocused,
            onFocusChange: (v) => setState(() => _passwordFocused = v),
          ),

          // 6. نسيت كلمة المرور
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _isLoading ? null : _handleForgotPassword,
              child: const Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  fontSize: 13,
                  color: _brandBright,
                  fontWeight: FontWeight.w500,
                  fontFamily: _font,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0x8034B4E4),
                ),
              ),
            ),
          ),

          // 7. زر الدخول الأساسي
          const SizedBox(height: 20),
          _buildPrimaryButton(),

          // 8. فاصل أو
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Container(height: 1, color: _borderColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('أو',
                    style: TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                        fontWeight: FontWeight.w600,
                        fontFamily: _font)),
              ),
              Expanded(child: Container(height: 1, color: _borderColor)),
            ],
          ),
          const SizedBox(height: 20),

          // 9. زر Google
          _buildSocialButton('GOOGLE', _handleGoogleLogin, const _GoogleLogo()),
          const SizedBox(height: 16),

          // 10. الدخول كضيف
          _buildGuestButton(),

          // 11. الشروط
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 11, color: _textSecondary, fontFamily: _font),
              children: [
                TextSpan(text: 'بالمتابعة فإنك توافق على '),
                TextSpan(
                    text: 'شروط الاستخدام',
                    style: TextStyle(
                        color: _brandBright, fontWeight: FontWeight.w600)),
                TextSpan(text: ' و'),
                TextSpan(
                    text: 'سياسة الخصوصية',
                    style: TextStyle(
                        color: _brandBright, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // التبويبات
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab('تسجيل الدخول', !_isRegisterMode),
        const SizedBox(width: 24),
        _buildTab('إنشاء حساب', _isRegisterMode),
      ],
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _isRegisterMode = label == 'إنشاء حساب'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontFamily: _font,
            color: isSelected ? _brandBright : _textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // حقول الإدخال
  // ═══════════════════════════════════════════════════════════════

  Widget _buildInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool isPassword,
    required String? errorText,
    required bool isFocused,
    required ValueChanged<bool> onFocusChange,
  }) {
    final hasError = errorText != null;
    final borderColor =
        hasError ? _coddyError : (isFocused ? _brandBright : _borderColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _bgInput,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(icon, size: 20, color: _textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Focus(
                  onFocusChange: onFocusChange,
                  child: TextField(
                    controller: controller,
                    obscureText: isPassword,
                    textDirection: TextDirection.rtl,
                    style: _inputTextStyle,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: label,
                      hintStyle: _hintStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 4),
            child: Text(errorText!,
                style: const TextStyle(
                    color: _coddyError, fontSize: 10, fontFamily: _font)),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // الزر الرئيسي
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPrimaryButton() {
    final label = _isRegisterMode ? 'إنشاء حساب' : 'تسجيل الدخول';
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () => _isRegisterMode ? _handleRegister() : _handleLogin(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
        decoration: BoxDecoration(
          color: _isLoading ? _brandPrimary.withOpacity(0.6) : _brandPrimary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isLoading
              ? []
              : const [
                  BoxShadow(
                      color: _brandPrimaryDarker,
                      offset: Offset(0, 4),
                      blurRadius: 0)
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Text(label, style: _primaryButtonTextStyle),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // زر Google
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSocialButton(String label, VoidCallback onTap, Widget logo) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: _bgCard,
          border: Border.all(color: _borderMid, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: _borderMid, offset: Offset(0, 3), blurRadius: 0)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20, height: 20, child: logo),
            const SizedBox(width: 8),
            Text(label, style: _socialButtonTextStyle),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // الدخول كضيف
  // ═══════════════════════════════════════════════════════════════

  Widget _buildGuestButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleGuestLogin,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: _bgCard,
          border: Border.all(color: _borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('الدخول كضيف',
              style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: _font)),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // رسالة الخطأ
  // ═══════════════════════════════════════════════════════════════

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _coddyError.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _coddyError.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: _coddyError, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(message,
                  style: const TextStyle(
                      fontSize: 11,
                      color: _coddyError,
                      fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // الأنماط الثابتة
  // ═══════════════════════════════════════════════════════════════

  static const _headingStyle = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: _textPrimary,
      fontFamily: _font);
  static const _subheadingStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: _textSecondary,
      fontFamily: _font);
  static const _cardTitleStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: _textPrimary,
      fontFamily: _font);
  static const _featureTitleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: _textPrimary,
      fontFamily: _font);
  static const _featureDescStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: _textSecondary,
      fontFamily: _font);
  static const _inputTextStyle =
      TextStyle(color: _textPrimary, fontSize: 16, fontFamily: _font);
  static const _hintStyle =
      TextStyle(color: _textDisabled, fontSize: 16, fontFamily: _font);
  static const _primaryButtonTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      fontFamily: _font,
      letterSpacing: 0.5);
  static const _socialButtonTextStyle = TextStyle(
      color: _brandBright,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      fontFamily: _font);
}

// ═════════════════════════════════════════════════════════════════
// شعار Google
// ═════════════════════════════════════════════════════════════════

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: const _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final blue = Paint()..color = const Color(0xFF4285F4);
    final red = Paint()..color = const Color(0xFFEA4335);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    final green = Paint()..color = const Color(0xFF34A853);

    final path = Path();
    path.moveTo(12 * s, 4 * s);
    path.cubicTo(8 * s, 4 * s, 4.5 * s, 6.5 * s, 3.5 * s, 10 * s);
    path.lineTo(6.5 * s, 12 * s);
    path.cubicTo(7 * s, 9 * s, 9.5 * s, 7 * s, 12 * s, 7 * s);
    path.cubicTo(14 * s, 7 * s, 15.5 * s, 8 * s, 16.5 * s, 9.5 * s);
    path.lineTo(19.5 * s, 7 * s);
    path.cubicTo(17.5 * s, 5 * s, 15 * s, 4 * s, 12 * s, 4 * s);
    canvas.drawPath(path, blue);

    final path2 = Path();
    path2.moveTo(3.5 * s, 10 * s);
    path2.cubicTo(3 * s, 11.5 * s, 3 * s, 13 * s, 3.5 * s, 14.5 * s);
    path2.lineTo(6.5 * s, 12 * s);
    path2.cubicTo(6.3 * s, 11.3 * s, 6.3 * s, 10.7 * s, 6.5 * s, 10 * s);
    path2.lineTo(3.5 * s, 10 * s);
    canvas.drawPath(path2, red);

    final path3 = Path();
    path3.moveTo(3.5 * s, 14.5 * s);
    path3.cubicTo(5 * s, 18 * s, 8.5 * s, 20.5 * s, 12 * s, 20.5 * s);
    path3.cubicTo(15 * s, 20.5 * s, 17.5 * s, 19 * s, 19 * s, 16.5 * s);
    path3.lineTo(16 * s, 14 * s);
    path3.cubicTo(15 * s, 15.5 * s, 13.5 * s, 17 * s, 12 * s, 17 * s);
    path3.cubicTo(9.5 * s, 17 * s, 7.5 * s, 15.5 * s, 6.5 * s, 12 * s);
    path3.lineTo(3.5 * s, 14.5 * s);
    canvas.drawPath(path3, green);

    final path4 = Path();
    path4.moveTo(19 * s, 16.5 * s);
    path4.cubicTo(20 * s, 15 * s, 20.5 * s, 13 * s, 20.5 * s, 12 * s);
    path4.cubicTo(20.5 * s, 11 * s, 20 * s, 9.5 * s, 19.5 * s, 8 * s);
    path4.lineTo(16.5 * s, 9.5 * s);
    path4.cubicTo(16.2 * s, 10.5 * s, 16.2 * s, 11.5 * s, 16.5 * s, 12.5 * s);
    path4.lineTo(19 * s, 16.5 * s);
    canvas.drawPath(path4, yellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
