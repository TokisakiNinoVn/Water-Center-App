import 'dart:async';
import 'package:clean_water/presentation/providers/auth/forgot_password_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:clean_water/presentation/providers/auth/auth_provider.dart';
import 'package:clean_water/presentation/routers/configs/app_router_config.dart';
import 'package:clean_water/data/configs/color_config.dart';

class ConfirmOTPScreen extends StatefulWidget {
  final String email;
  const ConfirmOTPScreen({super.key, required this.email});

  @override
  _ConfirmOTPScreenState createState() => _ConfirmOTPScreenState();
}

class _ConfirmOTPScreenState extends State<ConfirmOTPScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _countdown = 0;
  Timer? _timer;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Track ô nào đang focused để highlight
  int _focusedIndex = -1;

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
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        setState(() => _focusedIndex = _focusNodes[i].hasFocus ? i : _focusedIndex);
      });
    }

    _startCountdown();
    // Auto focus ô đầu tiên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var n in _focusNodes) n.dispose();
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  // ─── Countdown ──────────────────────────────────────────────
  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        setState(() => _countdown = 0);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  // ─── Verify OTP ─────────────────────────────────────────────
  Future<void> _verifyOTP() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      _showSnackbar('Vui lòng nhập đầy đủ 6 chữ số OTP.', isError: true);
      return;
    }

    final authProvider = context.read<ForgotPasswordProvider>();
    final success = await authProvider.verifyOTP({
      'email': widget.email,
      'otp': otp,
      'role': 'student',
    });

    if (!mounted) return;

    if (success) {
      final currentData = (GoRouterState.of(context).extra as Map<String, dynamic>? ?? {});
      final otpToken = authProvider.authResponse?.data['otp_token'] ?? '';
      _showSnackbar('Xác minh OTP thành công!', isError: false);
      context.go(AppRouterConfig.resetPassword,  extra: {
        ...currentData,
        'otp': otpToken,
      },);
    } else {
      _clearAllFields();
      FocusScope.of(context).requestFocus(_focusNodes[0]);
      _showSnackbar(
        authProvider.errorMessage ?? 'Mã OTP không chính xác.',
        isError: true,
      );
    }
  }

  // ─── Resend OTP ──────────────────────────────────────────────
  Future<void> _resendOTP() async {
    final authProvider = context.read<ForgotPasswordProvider>();
    final success = await authProvider.getOTP({
      'email': widget.email,
      'role': 'student',
    });

    if (!mounted) return;

    if (success) {
      _clearAllFields();
      FocusScope.of(context).requestFocus(_focusNodes[0]);
      _startCountdown();
      _showSnackbar('Mã OTP mới đã được gửi.', isError: false);
    } else {
      _showSnackbar(
        authProvider.errorMessage ?? 'Gửi lại OTP thất bại.',
        isError: true,
      );
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────
  void _onFieldChanged(String value, int index) {
    if (value.length > 1) {
      // Xử lý paste cả chuỗi OTP
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length == 6) {
        for (int i = 0; i < 6; i++) {
          _controllers[i].text = digits[i];
        }
        FocusScope.of(context).unfocus();
        _verifyOTP();
        return;
      }
      _controllers[index].text = value[0];
    }

    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }

    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyOTP();
    }
  }

  void _onKeyEvent(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      _controllers[index - 1].clear();
    }
  }

  void _clearAllFields() {
    for (var c in _controllers) c.clear();
  }

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
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          onPressed: () => context.go(AppRouterConfig.forgotPassword),
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
                        Icons.lock_open_outlined,
                        size: 38,
                        color: ColorConfig.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Tiêu đề ──
                  Text(
                    'Nhập mã xác thực',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ColorConfig.primary,
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
                        const TextSpan(text: 'Mã OTP đã được gửi tới\n'),
                        TextSpan(
                          text: widget.email,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: ColorConfig.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── 6 ô OTP ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final isFocused = _focusedIndex == index;
                      final isFilled = _controllers[index].text.isNotEmpty;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 46,
                        height: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: isFilled
                              ? const Color(0xFFE8F5E9)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isFocused
                                ? ColorConfig.primary
                                : isFilled
                                ? const Color(0xFF668EBB)
                                : const Color(0xFFB2DFDB),
                            width: isFocused ? 2 : 1.5,
                          ),
                          boxShadow: isFocused
                              ? [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                              : [],
                        ),
                        child: RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey: (event) => _onKeyEvent(event, index),
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            enabled: !isLoading,
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(bottom: 2),
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B5E20),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 1,
                            onChanged: (value) =>
                                _onFieldChanged(value, index),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 36),

                  // ── Nút xác nhận ──
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _verifyOTP,
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
                        'Xác nhận OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Gửi lại OTP ──
                  Column(
                    children: [
                      Text(
                        'Không nhận được mã?',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 10),

                      if (_countdown > 0) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _countdown / 60,
                            backgroundColor: const Color(0xFFE8F5E9),
                            valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF66BB6A)),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gửi lại sau $_countdown giây',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ] else
                        TextButton.icon(
                          onPressed: isLoading ? null : _resendOTP,
                          icon: Icon(Icons.refresh_rounded,
                              size: 18, color: ColorConfig.primary),
                          label: Text(
                            'Gửi lại mã OTP',
                            style: TextStyle(
                              color: ColorConfig.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}