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

/// Pixel-perfect Coddy.tech login screen recreation.
/// Static light theme colors — no dark mode switching.
/// Exact specs from coddy.tech/login CSS + reference images.
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

  // ── Static Coddy Light Theme Colors ───────────────────────────
  // These never change — no dark mode branching.

  static const _brandPrimary = Color(0xFF0077FF);
  static const _brandPrimaryDarker = Color(0xFF005DC8);
  static const _brandBright = Color(0xFF29ABE2);
  static const _bgPage = Color(0xFFFFFFFF);
  static const _bgCard = Color(0xFFFFFFFF);
  static const _bgInput = Color(0xFFFFFFFF);
  static const _bgLeftPanel = Color(0xFFF1F5F9);
  static const _textPrimary = Color(0xDE000000);
  static const _textSecondary = Color(0x8A000000);
  static const _textDisabled = Color(0x4D000000);
  static const _borderColor = Color(0xFFE6E6E6);
  static const _borderMid = Color(0xFFB3B3B3);
  static const _coddyError = Color(0xFFF44336);

  // ── Actions ───────────────────────────────────────────────────

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

  Future<void> _handleFacebookLogin() async {
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);
    final url = Uri.parse(
      'https://${Auth0Config.domain}/authorize?'
      'response_type=code&client_id=${Auth0Config.clientId}&'
      'redirect_uri=${Auth0Config.redirectUri}&audience=${Auth0Config.audience}&'
      'scope=openid profile email&connection=facebook&'
      'code_challenge=$codeChallenge&code_challenge_method=S256&'
      'state=${_generateRandomString(32)}',
    );
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _handleAppleLogin() async {
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);
    final url = Uri.parse(
      'https://${Auth0Config.domain}/authorize?'
      'response_type=code&client_id=${Auth0Config.clientId}&'
      'redirect_uri=${Auth0Config.redirectUri}&audience=${Auth0Config.audience}&'
      'scope=openid profile email&connection=apple&'
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
        _emailError = 'Email is required';
        valid = false;
      } else if (!email.contains('@')) {
        _emailError = 'Invalid email address';
        valid = false;
      }
      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password is required';
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

  // ── Build ─────────────────────────────────────────────────────

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
        // Left panel — "Unlock your Coding Journey"
        Expanded(
          flex: 1,
          child: Container(
            color: _bgLeftPanel,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Unlock your Coding Journey',
                  style: _headingStyle,
                ),
                const SizedBox(height: 40),
                _buildFeatureItem(Icons.code_rounded, 'Practice-Driven'),
                const SizedBox(height: 20),
                _buildFeatureItem(Icons.repeat, 'Unlimited'),
                const SizedBox(height: 20),
                _buildFeatureItem(Icons.emoji_events_outlined, 'Fun'),
                const SizedBox(height: 20),
                _buildFeatureItem(Icons.person_outline, 'Personalized'),
                const SizedBox(height: 20),
                _buildFeatureItem(Icons.auto_awesome, 'AI Enhanced'),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: GestureDetector(
                      onTap: () => context.go('/'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back,
                              size: 18, color: _brandBright),
                          const SizedBox(width: 4),
                          const Text('Back',
                              style:
                                  TextStyle(fontSize: 14, color: _brandBright)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right panel — Login card
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

  Widget _buildFeatureItem(IconData icon, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _brandBright.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: _brandBright),
        ),
        const SizedBox(width: 12),
        Text(label, style: _featureLabelStyle),
      ],
    );
  }

  // ── Login Card (exact Coddy specs) ────────────────────────────

  Widget _buildCard(AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000), // rgba(0,0,0,0.25)
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tab switcher: Log in | Register
          _buildTabs(),
          const SizedBox(height: 24),

          // Error banner
          if (authState.errorMessage != null)
            _buildErrorBanner(authState.errorMessage!),

          // Email input
          _buildInput(
            label: 'Email Address',
            icon: Icons.email_outlined,
            controller: _emailController,
            isPassword: false,
            errorText: _emailError,
            isFocused: _emailFocused,
            onFocusChange: (v) => setState(() => _emailFocused = v),
          ),
          const SizedBox(height: 16),

          // Password input
          _buildInput(
            label: 'Password',
            icon: Icons.lock_outline,
            controller: _passwordController,
            isPassword: true,
            errorText: _passwordError,
            isFocused: _passwordFocused,
            onFocusChange: (v) => setState(() => _passwordFocused = v),
          ),

          // LOG IN button (Coddy 3D style)
          const SizedBox(height: 24),
          _buildPrimaryButton(),

          // Forgot password
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _isLoading ? null : _handleForgotPassword,
            child: const Text(
              'Forgot password',
              style: TextStyle(
                fontSize: 13,
                color: _brandBright,
                fontWeight: FontWeight.w500,
                fontFamily: 'Varela Round',
                decoration: TextDecoration.underline,
                decorationColor: Color(0x8029ABE2),
              ),
            ),
          ),

          // OR divider
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Container(height: 1, color: _borderColor)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR',
                    style: TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                        fontWeight: FontWeight.w600)),
              ),
              Expanded(child: Container(height: 1, color: _borderColor)),
            ],
          ),
          const SizedBox(height: 20),

          // Social buttons: GOOGLE | FACEBOOK
          Row(
            children: [
              Expanded(
                  child: _buildSocialButton(
                      'GOOGLE', _handleGoogleLogin, _GoogleLogo())),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildSocialButton(
                      'FACEBOOK', _handleFacebookLogin, _FacebookLogo())),
            ],
          ),
          const SizedBox(height: 12),

          // APPLE button (full width)
          _buildSocialButton('APPLE', _handleAppleLogin, const _AppleLogo()),
          const SizedBox(height: 16),

          // Guest access
          _buildGuestButton(),

          // Terms
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 11,
                  color: _textSecondary,
                  fontFamily: 'Varela Round'),
              children: [
                TextSpan(text: 'By continuing you agree to our '),
                TextSpan(
                  text: 'Terms of Use',
                  style: TextStyle(
                      color: _brandBright, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                      color: _brandBright, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tabs ──────────────────────────────────────────────────────

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab('Log in', !_isRegisterMode),
        const SizedBox(width: 24),
        _buildTab('Register', _isRegisterMode),
      ],
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _isRegisterMode = label == 'Register'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Varela Round',
            color: isSelected ? _brandBright : _textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ── Inputs (exact Coddy style) ───────────────────────────────

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
            children: [
              Icon(icon, size: 20, color: _textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Focus(
                  onFocusChange: onFocusChange,
                  child: TextField(
                    controller: controller,
                    obscureText: isPassword,
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
            padding: const EdgeInsets.only(top: 2, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                  color: _coddyError, fontSize: 10, fontFamily: 'Varela Round'),
            ),
          ),
      ],
    );
  }

  // ── Primary Button (Coddy 3D style) ──────────────────────────

  Widget _buildPrimaryButton() {
    final label = _isRegisterMode ? 'SIGN UP' : 'LOG IN';
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
                    blurRadius: 0,
                  ),
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
              : Text(
                  label,
                  style: _primaryButtonTextStyle,
                ),
        ),
      ),
    );
  }

  // ── Social Buttons ───────────────────────────────────────────

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
            BoxShadow(
              color: _borderMid,
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20, height: 20, child: logo),
            const SizedBox(width: 8),
            Text(
              label,
              style: _socialButtonTextStyle,
            ),
          ],
        ),
      ),
    );
  }

  // ── Guest Button ─────────────────────────────────────────────

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
          child: Text(
            'الدخول كضيف',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Varela Round',
            ),
          ),
        ),
      ),
    );
  }

  // ── Error Banner ─────────────────────────────────────────────

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
            child: Text(
              message,
              style: const TextStyle(
                  fontSize: 11,
                  color: _coddyError,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ── Static Text Styles ───────────────────────────────────────

  static const _headingStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: _textPrimary,
    fontFamily: 'Varela Round',
  );

  static const _featureLabelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: _textPrimary,
    fontFamily: 'Varela Round',
  );

  static const _inputTextStyle = TextStyle(
    color: _textPrimary,
    fontSize: 16,
    fontFamily: 'Varela Round',
  );

  static const _hintStyle = TextStyle(
    color: _textDisabled,
    fontSize: 16,
    fontFamily: 'Varela Round',
  );

  static const _primaryButtonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontFamily: 'Varela Round',
    letterSpacing: 0.5,
  );

  static const _socialButtonTextStyle = TextStyle(
    color: _brandBright,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontFamily: 'Varela Round',
  );
}

// ── Social Logos ─────────────────────────────────────────────────

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final blue = Paint()..color = const Color(0xFF4285F4);
    final red = Paint()..color = const Color(0xFFEA4335);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    final green = Paint()..color = const Color(0xFF34A853);

    // Top arc (blue)
    final path = Path();
    path.moveTo(12 * s, 4 * s);
    path.cubicTo(8 * s, 4 * s, 4.5 * s, 6.5 * s, 3.5 * s, 10 * s);
    path.lineTo(6.5 * s, 12 * s);
    path.cubicTo(7 * s, 9 * s, 9.5 * s, 7 * s, 12 * s, 7 * s);
    path.cubicTo(14 * s, 7 * s, 15.5 * s, 8 * s, 16.5 * s, 9.5 * s);
    path.lineTo(19.5 * s, 7 * s);
    path.cubicTo(17.5 * s, 5 * s, 15 * s, 4 * s, 12 * s, 4 * s);
    canvas.drawPath(path, blue);

    // Left (red)
    final path2 = Path();
    path2.moveTo(3.5 * s, 10 * s);
    path2.cubicTo(3 * s, 11.5 * s, 3 * s, 13 * s, 3.5 * s, 14.5 * s);
    path2.lineTo(6.5 * s, 12 * s);
    path2.cubicTo(6.3 * s, 11.3 * s, 6.3 * s, 10.7 * s, 6.5 * s, 10 * s);
    path2.lineTo(3.5 * s, 10 * s);
    canvas.drawPath(path2, red);

    // Bottom (green)
    final path3 = Path();
    path3.moveTo(3.5 * s, 14.5 * s);
    path3.cubicTo(5 * s, 18 * s, 8.5 * s, 20.5 * s, 12 * s, 20.5 * s);
    path3.cubicTo(15 * s, 20.5 * s, 17.5 * s, 19 * s, 19 * s, 16.5 * s);
    path3.lineTo(16 * s, 14 * s);
    path3.cubicTo(15 * s, 15.5 * s, 13.5 * s, 17 * s, 12 * s, 17 * s);
    path3.cubicTo(9.5 * s, 17 * s, 7.5 * s, 15.5 * s, 6.5 * s, 12 * s);
    path3.lineTo(3.5 * s, 14.5 * s);
    canvas.drawPath(path3, green);

    // Right (yellow)
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

class _FacebookLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _FacebookLogoPainter());
  }
}

class _FacebookLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1877F2);
    final s = size.width / 24;

    final path = Path();
    path.moveTo(12 * s, 2 * s);
    path.cubicTo(6.477 * s, 2 * s, 2 * s, 6.477 * s, 2 * s, 12 * s);
    path.cubicTo(
        2 * s, 16.991 * s, 5.657 * s, 21.128 * s, 10.438 * s, 21.878 * s);
    path.lineTo(10.438 * s, 14.891 * s);
    path.lineTo(7.992 * s, 14.891 * s);
    path.lineTo(7.992 * s, 12 * s);
    path.lineTo(10.438 * s, 12 * s);
    path.lineTo(10.438 * s, 9.881 * s);
    path.cubicTo(
        10.438 * s, 7.477 * s, 11.864 * s, 6.156 * s, 14.04 * s, 6.156 * s);
    path.cubicTo(
        15.083 * s, 6.156 * s, 16.172 * s, 6.343 * s, 16.172 * s, 6.343 * s);
    path.lineTo(16.172 * s, 8.719 * s);
    path.cubicTo(
        14.969 * s, 8.719 * s, 14.594 * s, 9.469 * s, 14.594 * s, 10.234 * s);
    path.lineTo(14.594 * s, 12 * s);
    path.lineTo(16.078 * s, 12 * s);
    path.lineTo(15.844 * s, 14.891 * s);
    path.lineTo(14.594 * s, 14.891 * s);
    path.lineTo(14.594 * s, 21.878 * s);
    path.cubicTo(
        19.373 * s, 21.128 * s, 23.031 * s, 16.991 * s, 23.031 * s, 12 * s);
    path.cubicTo(23.031 * s, 6.477 * s, 18.554 * s, 2 * s, 12 * s, 2 * s);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AppleLogo extends StatelessWidget {
  const _AppleLogo();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: const _AppleLogoPainter());
  }
}

class _AppleLogoPainter extends CustomPainter {
  const _AppleLogoPainter();
  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFF000000);
    final paint = Paint()..color = color;
    final s = size.width / 24;

    // Simplified apple
    final path = Path();
    path.moveTo(17.5 * s, 12 * s);
    path.cubicTo(17.5 * s, 15 * s, 15 * s, 17.5 * s, 12 * s, 17.5 * s);
    path.cubicTo(9 * s, 17.5 * s, 6.5 * s, 15 * s, 6.5 * s, 12 * s);
    path.cubicTo(6.5 * s, 9 * s, 9 * s, 6.5 * s, 12 * s, 6.5 * s);
    path.cubicTo(15 * s, 6.5 * s, 17.5 * s, 9 * s, 17.5 * s, 12 * s);
    canvas.drawPath(path, paint);

    // Leaf
    final leafPath = Path();
    leafPath.moveTo(12 * s, 6.5 * s);
    leafPath.cubicTo(12 * s, 6.5 * s, 13 * s, 3 * s, 15 * s, 3 * s);
    leafPath.cubicTo(14 * s, 5 * s, 13 * s, 6 * s, 12 * s, 6.5 * s);
    canvas.drawPath(leafPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
