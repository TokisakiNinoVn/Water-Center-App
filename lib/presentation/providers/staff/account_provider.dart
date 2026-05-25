import 'dart:io';

import 'package:clean_water/data/models/api_response.dart';
import 'package:clean_water/data/services/account_service.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';
import '../../../core/storage/index_storage.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _accountService = AccountService();

  bool isLoading = false;

  String? errorMessage;
  ApiResponse? accountResponse;
  Map<String, dynamic> userData = {};

  Future<bool> loadInformationAccount({bool isCustomer = false}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      ApiResponse response;
      response = await _accountService.me(isCustomer: isCustomer);
      accountResponse = response;

      if (response.success == true) {
        userData = response.data;
        // appLog("Data user: ${userData}");
        return true;
      } else {
        errorMessage = response.message;
        return false;
      }

    } catch (e) {
      errorMessage = 'Đã xảy ra lỗi: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Method 1: Update không có avatar (JSON)
  Future<bool> updateWithoutAvatar(Map<String, dynamic> body) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _accountService.update(body);

      if (res.success == true) {
        await SharedPrefsService.saveValue(PrefType.string, 'user', res.data);
        return true;
      } else {
        errorMessage = res.message;
        return false;
      }
    } catch (e) {
      errorMessage = 'Đã xảy ra lỗi: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Method 2: Update có avatar (có thể có hoặc không có file)
  Future<bool> update(Map<String, dynamic> body, {File? avatar, bool isCustomer = false}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final ApiResponse res;

      if (avatar != null) {
        res = await _accountService.updateWithAvatar(body, avatarFile: avatar, isCustomer: isCustomer);
      } else {
        // Gửi JSON thông thường
        res = await _accountService.update(body, isCustomer: isCustomer);
      }

      if (res.success == true) {
        // Lưu lại thông tin user mới
        await SharedPrefsService.saveValue(PrefType.string, 'user', res.data);
        return true;
      } else {
        errorMessage = res.message;
        return false;
      }
    } catch (e) {
      errorMessage = 'Đã xảy ra lỗi: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
