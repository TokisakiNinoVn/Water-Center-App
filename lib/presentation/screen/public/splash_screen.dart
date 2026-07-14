// File: splash_screen.dart
import 'package:clean_water/core/storage/index_storage.dart';
import 'package:clean_water/data/configs/app_config.dart';
import 'package:clean_water/data/extensions/login_type_role_extension.dart';
import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:clean_water/presentation/routers/configs/customer_router_config.dart';
import 'package:clean_water/presentation/routers/configs/staff_router_config.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:clean_water/presentation/helper/check_login_helper.dart';

import '../../routers/configs/app_router_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasInternet = true;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final hasNet = await checkInternetFast();

    if (!mounted) return;

    if (!hasNet) {
      setState(() {
        _hasInternet = false;
        _isChecking = false;
      });
      return;
    }

    await _requestPermissions();
    await _checkToken();
  }

  Future<bool> checkInternetFast() async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 3);

      final request = await client.getUrl(
        Uri.parse('https://clients3.google.com/generate_204'),
      );

      final response = await request.close();

      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  Future<void> _retry() async {
    setState(() {
      _isChecking = true;
      _hasInternet = true;
    });
    await _initialize();
  }

  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.storage,
      Permission.photos,
      Permission.microphone,
    ];

    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        await permission.request();
      }
    }
  }

  Future<void> _checkToken() async {
    final isLogin = await SharedPrefsService.getValue(PrefType.bool, "isLogin") ?? false;
    final token = await SharedPrefsService.getValue(PrefType.string, "token") ?? "";
    final isFirstLaunch = await SharedPrefsService.getValue(PrefType.bool, "is_first_launch") ?? true;

    bool isSkipGettingStarted = AppConfig.isSkipGettingStarted;

    if (!isSkipGettingStarted && isFirstLaunch) {
      if (mounted) context.go(AppRouterConfig.gettingStartedFirst);
      return;
    }

    final roleValue = await SharedPrefsService.getValue(
      PrefType.string,
      'role',
    );

    final role = LoginTypeRoleExtension.fromValue(roleValue);

    if (isLogin && token.isNotEmpty) {
      if (role.isCustomer) {
        if (mounted) context.go(CustomerRouterConfig.homeCustomer);
      } else if (role.isStaff) {
        if (mounted) context.go(StaffRouterConfig.homeStaff);
      } else {
        if (mounted) SnackBarHelper.showWarning(context, "Role: $role chưa có màn hình!");
      }
      return;
    }

    if (mounted) context.go(AppRouterConfig.homePublic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF4A90E2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: _isChecking
              ? _buildLoading()
              : _hasInternet
              ? _buildLoading() // fallback, thực tế không dùng đến
              : _buildNoInternet(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            'assets/images/logo-no-background.png',
            width: 200,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          AppConfig.appName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          AppConfig.appSlogan,
          style: TextStyle(
            fontSize: 16,
            // fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 40),
        const CircularProgressIndicator(
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildNoInternet() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.wifi_off,
          size: 80,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        const Text(
          "Không có kết nối Internet",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Vui lòng kiểm tra lại mạng của bạn",
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _retry,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text("Kiểm tra lại"),
        ),
      ],
    );
  }
}