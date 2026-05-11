import 'dart:io';

import 'package:clean_water/data/models/api_response.dart';
import 'package:clean_water/data/services/account_service.dart';
import 'package:clean_water/data/services/customer_service.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';
import '../../core/storage/index_storage.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _customerService = CustomerService();

  bool isLoading = false;

  String? errorMessage;
  ApiResponse? apiResponse;
  // Map<String, dynamic> userData = {};

  // Future<bool> loadInformationAccount() async {
  //   isLoading = true;
  //   errorMessage = null;
  //   notifyListeners();
  //
  //   try {
  //     final res = await _accountService.me();
  //     accountResponse = res;
  //
  //     if (res.success == true) {
  //       userData = res.data;
  //       // appLog("Data user: ${userData}");
  //       return true;
  //     } else {
  //       errorMessage = res.message;
  //       return false;
  //     }
  //
  //   } catch (e) {
  //     errorMessage = 'Đã xảy ra lỗi: $e';
  //     return false;
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Method 1: Update không có avatar (JSON)
  // Future<bool> updateWithoutAvatar(Map<String, dynamic> body) async {
  //   isLoading = true;
  //   errorMessage = null;
  //   notifyListeners();
  //
  //   try {
  //     final res = await _accountService.update(body);
  //
  //     if (res.success == true) {
  //       await SharedPrefsService.saveValue(PrefType.string, 'user', res.data);
  //       return true;
  //     } else {
  //       errorMessage = res.message;
  //       return false;
  //     }
  //   } catch (e) {
  //     errorMessage = 'Đã xảy ra lỗi: $e';
  //     return false;
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Method 2: Update có avatar (có thể có hoặc không có file)
  Future<bool> registerCustomer(Map<String, dynamic> body) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final ApiResponse res;
      res = await _customerService.registerCustomerByStaff(body);


      if (res.success == true) {
        // Lưu lại thông tin user mới
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
