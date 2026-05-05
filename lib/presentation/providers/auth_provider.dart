import 'package:clean_water/data/models/api_response.dart';
import 'package:clean_water/data/services/auth_service.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import '../../core/storage/index_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  ApiResponse? authResponse;

  Future<bool> login(Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.login(data);

      authResponse = res;
      final dataLogin = res.data['data'];

      if (res.success == true) {
        SharedPrefsService.saveValue(PrefType.string, 'token', dataLogin['access_token'] ?? '');
        SharedPrefsService.saveValue(PrefType.bool, 'isLogin', true);
        SharedPrefsService.saveValue(PrefType.string, 'role', dataLogin['permission']); //nv
        SharedPrefsService.saveValue(
          PrefType.string,
          'user',
          dataLogin['user'] ?? {},
        );
        return true;
      } else {
        errorMessage = res.message;
        return false;
      }

    } catch (e) {
      errorMessage = 'Đã xảy ra lỗi: $e';
      appLog("Đã xảy ra lỗi: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
