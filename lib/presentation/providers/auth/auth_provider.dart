import 'package:clean_water/data/configs/role_user_config.dart';
import 'package:clean_water/data/enums/login_type_role.dart';
import 'package:clean_water/data/extensions/login_type_role_extension.dart';
import 'package:clean_water/data/models/api_response.dart';
import 'package:clean_water/data/services/auth_service.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import '../../../core/storage/index_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  ApiResponse? authResponse;

  // Role hiện tại sau khi login
  LoginTypeRole? currentLoginRole;

  Future<bool> login(Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.login(data);
      // appLog("Save role: ${res}");

      authResponse = res;
      final dataLogin = res.data['data'];

      if (res.success == true) {

        final roleValue = dataLogin['permission'];

        // Convert sang enum/object
        currentLoginRole = LoginTypeRoleExtension.fromValue(roleValue);

        // Save local
        await SharedPrefsService.saveValue(
          PrefType.string,
          'role',
          roleValue,
        );

        await SharedPrefsService.saveValue(
          PrefType.string,
          'token',
          dataLogin['access_token'] ?? '',
        );

        await SharedPrefsService.saveValue(
          PrefType.bool,
          'isLogin',
          true,
        );

        if (currentLoginRole?.isStaff == true) {
          await SharedPrefsService.saveValue(
            PrefType.string,
            'user',
            dataLogin['user'] ?? {},
          );
        } else {
          await SharedPrefsService.saveValue(
            PrefType.string,
            'user',
            dataLogin['khach_hang'] ?? {},
          );
        }

        // appLog("Save role: ${currentLoginRole?.value}");

        return true;
      } else {
        errorMessage = res.message;
        return false;
      }

    } catch (e) {
      String messageError = 'Đã xảy ra lỗi: $e';
      errorMessage = messageError;
      appLog(messageError);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerAccountProvider(Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.registerServicer(data);
      authResponse = res;
      final dataRegister = res.data['data'];

      if (res.success == true) {
        final roleValue = 'khach_hang';
        // Convert sang enum/object
        currentLoginRole = LoginTypeRoleExtension.fromValue(roleValue);

        // Save local
        await SharedPrefsService.saveValue(
          PrefType.string,
          'role',
          roleValue,
        );

        await SharedPrefsService.saveValue(
          PrefType.string,
          'token',
          dataRegister['access_token'] ?? '',
        );

        await SharedPrefsService.saveValue(
          PrefType.bool,
          'isLogin',
          true,
        );

        await SharedPrefsService.saveValue(
          PrefType.string,
          'user',
          dataRegister['user'] ?? {},
        );

        return true;
      } else {
        errorMessage = res.message;
        appLog("$errorMessage");
        return false;
      }

    } catch (e) {
      String messageError = 'Đã xảy ra lỗi: $e';
      errorMessage = messageError;
      appLog(messageError);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}