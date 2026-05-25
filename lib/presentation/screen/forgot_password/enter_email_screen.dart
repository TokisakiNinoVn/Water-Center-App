import 'dart:async';
import 'package:clean_water/presentation/providers/auth/forgot_password_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:clean_water/presentation/providers/auth/auth_provider.dart';
import 'package:clean_water/presentation/routers/configs/app_router_config.dart';
import 'package:clean_water/data/configs/color_config.dart';

class EnterEmailScreen extends StatefulWidget {
  const EnterEmailScreen({super.key});

  @override
  _EnterEmailScreenState createState() => _EnterEmailScreenState();
}

class _EnterEmailScreenState extends State<EnterEmailScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _countdown = 0;
  Timer? _timer;
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
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        setState(() => _countdown = 0);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _requestOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<ForgotPasswordProvider>();
    final email = _emailController.text.trim();

    final success = await authProvider.getOTP({
      'email': email,
      'role': 'student',
    });

    if (!mounted) return;

    if (success) {
      _startCountdown();
      _showSnackbar('Mã OTP đã được gửi tới $email', isError: false);
      context.go(AppRouterConfig.confirmOTP,  extra: {
        'email': email,
      });
    } else {
      _showSnackbar(
        authProvider.errorMessage ?? 'Yêu cầu OTP thất bại.',
        isError: true,
      );
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFE53935) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email.';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không hợp lệ.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<ForgotPasswordProvider>();
    final isLoading = authProvider.isLoading;
    final isButtonDisabled = isLoading || _countdown > 0;

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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // Icon minh hoạ
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EDF5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.mark_email_unread_outlined,
                          size: 38,
                          color: ColorConfig.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'Xác minh Email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ColorConfig.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Nhập email của bạn để nhận mã OTP xác thực tài khoản.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B6B6B),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      style: TextStyle(
                        fontSize: 15,
                        color: ColorConfig.primary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Địa chỉ Email',
                        labelStyle: TextStyle(
                          color: ColorConfig.primary,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: ColorConfig.primary,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFB2CFDF),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ColorConfig.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE53935)),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE53935),
                            width: 2,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isButtonDisabled ? null : _requestOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConfig.primary,
                          disabledBackgroundColor: ColorConfig.secondary,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white70,
                          elevation: isButtonDisabled ? 0 : 3,
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
                            : Text(
                          _countdown > 0
                              ? 'Gửi lại sau $_countdown giây'
                              : 'Lấy mã OTP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Countdown progress bar
                    if (_countdown > 0) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _countdown / 60,
                          backgroundColor: const Color(0xFFE8EDF5),
                          valueColor: const AlwaysStoppedAnimation(Color(
                              0xFF446DAA)),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'OTP đã được gửi. Vui lòng kiểm tra hộp thư.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Quay lại đăng nhập
                    TextButton(
                      onPressed: () => context.go(AppRouterConfig.login),
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