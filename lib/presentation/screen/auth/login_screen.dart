import 'package:clean_water/data/configs/app_config.dart';
import 'package:clean_water/data/configs/color_config.dart';
import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:clean_water/presentation/routers/configs/customer_router_config.dart';
import 'package:clean_water/presentation/routers/configs/staff_router_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clean_water/core/storage/index_storage.dart';
import 'package:clean_water/presentation/routers/configs/app_router_config.dart';
import 'package:clean_water/presentation/providers/auth_provider.dart';

// ─── Constants ─────────────────────────────────────────────────────────────
const _kRememberKey = 'remember_me';
const _kSavedPhoneKey = 'saved_phone';

// ─── Colors ────────────────────────────────────────────────────────────────
const _cBg = Color(0xFFF0F6FF);
const _cSurface = Color(0xFFFFFFFF);
const _cCard = Color(0xFFFFFFFF);
const _cBorder = Color(0xFFDDE6F5);
const _cAccent1 = Color(0xFF2563EB);
const _cAccent2 = Color(0xFF7C3AED);
const _cAccent3 = Color(0xFF06D6A0);
const _cTextPrimary = Color(0xFF0F172A);
const _cTextSecondary = Color(0xFF475569);
const _cTextMuted = Color(0xFF94A3B8);
const _cInputBg = Color(0xFFF8FAFF);
const _cError = Color(0xFFEF4444);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController(); // ← đổi từ email sang phone
  final _passCtrl = TextEditingController();
  final _phoneFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscurePass = true;
  bool _rememberMe = false;
  bool _phoneFocused = false;
  bool _passFocused = false;

  // ─── Lời chào theo giờ ──────────────────────────────────────────────────
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Chào buổi sáng ☀️';
    if (hour >= 11 && hour < 13) return 'Chào buổi trưa 🌤️';
    if (hour >= 13 && hour < 18) return 'Chào buổi chiều 🌇';
    if (hour >= 18 && hour < 22) return 'Chào buổi tối 🌙';
    return 'Chào đêm khuya 🌟';
  }

  @override
  void initState() {
    super.initState();
    _loadSavedPrefs();

    _phoneFocus.addListener(() => setState(() => _phoneFocused = _phoneFocus.hasFocus));
    _passFocus.addListener(() => setState(() => _passFocused = _passFocus.hasFocus));
  }

  Future<void> _loadSavedPrefs() async {
    await SharedPrefsService.saveValue(PrefType.bool, "is_first_launch", true);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool(_kRememberKey) ?? false;
      if (_rememberMe) {
        _phoneCtrl.text = prefs.getString(_kSavedPhoneKey) ?? '';
      }
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRememberKey, _rememberMe);
    if (_rememberMe) {
      await prefs.setString(_kSavedPhoneKey, _phoneCtrl.text);
    } else {
      await prefs.remove(_kSavedPhoneKey);
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _cBg,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ── Background image: full screen, top half ──────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.45,
              child: Image.asset(
                'assets/images/background_login.png',
                fit: BoxFit.cover,
              ),
            ),

            // ── Gradient overlay phía dưới ảnh ──────────────────────────
            Positioned(
              top: size.height * 0.30,
              left: 0,
              right: 0,
              height: size.height * 0.18,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      _cBg,
                    ],
                  ),
                ),
              ),
            ),

            // ── Phần dưới: nền màu đồng nhất ────────────────────────────
            Positioned(
              top: size.height * 0.45,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(color: _cBg),
            ),

            // ── Nội dung chính ───────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // Lời chào – góc trên bên trái
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _greeting,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Scroll content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            SizedBox(height: size.height * 0.26),
                            _buildCard(authProvider),
                            const SizedBox(height: 20),
                            _buildRegisterButton(),
                            const SizedBox(height: 20),
                            _buildFooter(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Card đăng nhập ──────────────────────────────────────────────────────
  Widget _buildCard(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _cBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _cTextPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Chào mừng bạn trở lại 👋',
                    style: TextStyle(
                      fontSize: 12,
                      color: _cTextSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Mô tả nhỏ
          Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _cAccent1.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 13, color: _cAccent1),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'Nhập số điện thoại để đăng nhập và sử dụng dịch vụ',
                    style: TextStyle(
                      fontSize: 11,
                      color: _cAccent1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Số điện thoại
          _buildFieldLabel('Số điện thoại'),
          const SizedBox(height: 8),
          _buildInputField(
            controller: _phoneCtrl,
            focusNode: _phoneFocus,
            isFocused: _phoneFocused,
            hint: 'Vui lòng nhập số điện thoại',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 16),

          // Mật khẩu
          _buildFieldLabel('Mật khẩu'),
          const SizedBox(height: 8),
          _buildInputField(
            controller: _passCtrl,
            focusNode: _passFocus,
            isFocused: _passFocused,
            hint: 'Nhập mật khẩu',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePass,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePass = !_obscurePass),
              child: Icon(
                _obscurePass
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _obscurePass ? _cTextMuted : _cAccent1,
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Ghi nhớ & Quên mật khẩu
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: _rememberMe
                            ? const LinearGradient(colors: [_cAccent1, _cAccent2])
                            : null,
                        color: _rememberMe ? null : _cInputBg,
                        border: Border.all(
                          color: _rememberMe ? Colors.transparent : _cBorder,
                          width: 1.5,
                        ),
                      ),
                      child: _rememberMe
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ghi nhớ đăng nhập',
                      style: TextStyle(
                        fontSize: 13,
                        color: _cTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go(AppRouterConfig.forgotPassword),
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    fontSize: 13,
                    color: _cAccent1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildLoginButton(authProvider),
        ],
      ),
    );
  }

  // ─── Nút chuyển sang màn hình Đăng ký ────────────────────────────────────
  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: _cCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go(AppRouterConfig.register), // ← đổi route cho phù hợp
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Chưa có tài khoản? ',
                style: TextStyle(
                  fontSize: 14,
                  color: _cTextSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Text(
                'Đăng ký ngay',
                style: TextStyle(
                  fontSize: 14,
                  color: _cAccent1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, color: _cAccent1, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _cBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline_rounded, size: 12, color: _cTextMuted),
              const SizedBox(width: 6),
              Text(
                '${AppConfig.appName} v${AppConfig.appVersion} (build ${AppConfig.appVersionBuild})',
                style: const TextStyle(fontSize: 11, color: _cTextMuted),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _cAccent2.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'STABLE',
                  style: TextStyle(
                    fontSize: 9,
                    color: _cAccent2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppConfig.appFooterCopyright,
          style: TextStyle(
            fontSize: 11,
            color: _cTextMuted.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  // ─── Nút đăng nhập ───────────────────────────────────────────────────────
  Widget _buildLoginButton(AuthProvider authProvider) {
    return GestureDetector(
      onTap: authProvider.isLoading ? null : () => _handleLogin(authProvider),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: authProvider.isLoading
              ? LinearGradient(
            colors: [
              ColorConfig.primary,
              ColorConfig.primary
            ],
          )
              : LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              ColorConfig.primary,
              ColorConfig.primary.withOpacity(.7)
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: authProvider.isLoading
              ? []
              : [
            BoxShadow(
              color: _cAccent1.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: authProvider.isLoading
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Đang đăng nhập...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Đăng nhập',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Xử lý đăng nhập ─────────────────────────────────────────────────────
  Future<void> _handleLogin(AuthProvider authProvider) async {
    await _savePrefs();

    final data = {
      'phone': _phoneCtrl.text,
      'password': _passCtrl.text,
    };

    final response = await authProvider.login(data);

    if (response && mounted) {
      final role = await SharedPrefsService.getValue(PrefType.string, 'role');

      if (role == 'customer') {
        context.go(CustomerRouterConfig.homeCustomer);
      } else if (role == 'nv') {
        context.go(StaffRouterConfig.homeStaff);
      } else {
        SnackBarHelper.showWaring(context, "Role: $role chưa có màn hình!");
      }

    } else if (mounted) {
      SnackBarHelper.showError(
        context,
        authProvider.errorMessage ?? 'Lỗi không xác định',
      );
    }
  }


  // ─── Helpers ──────────────────────────────────────────────────────────────
  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _cTextSecondary,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: _cInputBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused ? _cAccent1 : _cBorder,
          width: isFocused ? 1.5 : 1,
        ),
        boxShadow: isFocused
            ? [
          BoxShadow(
            color: _cAccent1.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          color: _cTextPrimary,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: _cAccent1,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _cTextMuted, fontSize: 14),
          prefixIcon: Icon(
            icon,
            color: isFocused ? _cAccent1 : _cTextMuted,
            size: 18,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // SnackBar _buildSnackBar(String message, {required bool isSuccess}) {
  //   return SnackBar(
  //     content: Row(
  //       children: [
  //         Icon(
  //           isSuccess ? Icons.check_circle_outline : Icons.error_outline,
  //           color: isSuccess ? _cAccent3 : _cError,
  //           size: 18,
  //         ),
  //         const SizedBox(width: 10),
  //         Expanded(
  //           child: Text(
  //             message,
  //             style: const TextStyle(color: _cTextPrimary, fontSize: 13),
  //           ),
  //         ),
  //       ],
  //     ),
  //     backgroundColor: _cSurface,
  //     behavior: SnackBarBehavior.floating,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(14),
  //       side: BorderSide(
  //         color: isSuccess
  //             ? _cAccent3.withOpacity(0.3)
  //             : _cError.withOpacity(0.3),
  //         width: 1,
  //       ),
  //     ),
  //     margin: const EdgeInsets.all(16),
  //     duration: const Duration(seconds: 3),
  //   );
  // }
}