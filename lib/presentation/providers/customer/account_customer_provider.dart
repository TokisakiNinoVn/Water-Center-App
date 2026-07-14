import 'dart:io';

import 'package:clean_water/data/models/api_response.dart';
import 'package:clean_water/data/services/account_service.dart';
import 'package:clean_water/data/services/bill_service.dart';
import 'package:clean_water/data/services/notification_service.dart';
import 'package:clean_water/data/services/water_index_service.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';

class AccountCustomerProvider extends ChangeNotifier {
  final AccountService _accountService = AccountService();

  bool isLoadingDetails = false;
  bool isLoading = false;

  String? errorMessage;
  ApiResponse? response;

  // Customer
  Future<bool> deleteAccountProvider() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _accountService.deleteAccount();
      response = res;
      // appLog('response xóa tài khoản: $res');

      if (res.success == true) {
        return true;
      } else {
        errorMessage = res.message;
        appLog("Error message deleteAccountProvider: ${errorMessage}");
        return false;
      }

    } catch (e) {
      errorMessage = 'Đã xảy ra lỗi: $e';
      appLog('Đã xảy ra lỗi: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
