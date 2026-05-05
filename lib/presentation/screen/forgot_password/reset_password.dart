import 'package:clean_water/data/configs/color_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/forgot_password_provider.dart';
import '../../routers/configs/app_router_config.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordScreen({Key? key, required this.email, required this.otp})
      : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  bool _obscureNewPass = true;
  bool _obscureRePass = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _rePasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ─── Validate ────────────────────────────────────────────────
  String? _validateNewPassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập mật khẩu mới.';
    if (value.trim().length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự.';
    return null;
  }

  String? _validateRePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập lại mật khẩu.';
    if (value.trim() != _newPasswordController.text.trim()) {
      return 'Mật khẩu nhập lại không khớp.';
    }
    return null;
  }

  // ─── Reset Password ──────────────────────────────────────────
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ForgotPasswordProvider>();
    final newPassword = _newPasswordController.text.trim();
    final rePassword = _rePasswordController.text.trim();

    final success = await provider.resetPassword({
      'email': widget.email,
      'password': newPassword,
      'otp_token': widget.otp,
      'password_confirmation': rePassword,
      'role': 'student',
    });

    if (!mounted) return;

    if (success) {
      _showSnackbar('Đặt lại mật khẩu thành công!', isError: false);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) context.go(AppRouterConfig.login);
    } else {
      _showSnackbar(
        provider.errorMessage ?? 'Đặt lại mật khẩu thất bại.',
        isError: true,
      );
    }
  }

  // ─── Snackbar ────────────────────────────────────────────────
  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ]),
        backgroundColor:
        isError ? const Color(0xFFE53935) : ColorConfig.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // ─── Password Field ──────────────────────────────────────────
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    required bool enabled,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
      style: TextStyle(fontSize: 15, color: ColorConfig.secondary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: ColorConfig.secondary, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF385D8E), size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFF38568E),
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB2DFDB), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E4E7D), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ForgotPasswordProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: ColorConfig.primary,
          onPressed: () => context.go(AppRouterConfig.login),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // ── Icon ──
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_reset_outlined,
                          size: 38,
                          color: ColorConfig.textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Tiêu đề ──
                    Text(
                      'Đặt lại mật khẩu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: ColorConfig.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B6B6B),
                            height: 1.5),
                        children: [
                          const TextSpan(text: 'Tạo mật khẩu mới cho tài khoản\n'),
                          TextSpan(
                            text: widget.email,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: ColorConfig.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Mật khẩu mới ──
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: 'Mật khẩu mới',
                      obscureText: _obscureNewPass,
                      onToggle: () =>
                          setState(() => _obscureNewPass = !_obscureNewPass),
                      validator: _validateNewPassword,
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 16),

                    // ── Nhập lại mật khẩu ──
                    _buildPasswordField(
                      controller: _rePasswordController,
                      label: 'Nhập lại mật khẩu mới',
                      obscureText: _obscureRePass,
                      onToggle: () =>
                          setState(() => _obscureRePass = !_obscureRePass),
                      validator: _validateRePassword,
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 12),

                    // ── Gợi ý mật khẩu ──
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 14, color: Color(0xFF90A4AE)),
                        const SizedBox(width: 6),
                        Text(
                          'Mật khẩu tối thiểu 6 ký tự.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Nút xác nhận ──
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConfig.primary,
                          disabledBackgroundColor: const Color(0xFFA5D6A7),
                          foregroundColor: Colors.white,
                          elevation: isLoading ? 0 : 3,
                          shadowColor: Colors.green.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Text(
                          'Xác nhận đặt lại',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Quay lại đăng nhập ──
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.go(AppRouterConfig.login),
                      style: TextButton.styleFrom(
                        foregroundColor: ColorConfig.primary,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_rounded, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Quay lại đăng nhập',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}