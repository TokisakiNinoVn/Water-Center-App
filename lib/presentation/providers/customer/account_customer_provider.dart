import 'dart:io';

import 'package:clean_water/data/models/api_response.dart';
import 'package:clean_water/data/services/account_service.dart';
import 'package:clean_water/data/services/bill_service.dart';
import 'package:clean_water/data/services/notification_service.dart';
import 'package:clean_water/data/services/water_index_service.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';

class BillCustomerProvider extends ChangeNotifier {
  final BillCustomerService _billCustomerService = BillCustomerService();

  bool isLoadingDetails = false;
  bool isLoading = false;

  String? errorMessage;
  ApiResponse? response;

  late var detailsBills = {};

  // Customer
  Future<bool> loadDetailsBillCustomer(int id) async {
    isLoadingDetails = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _billCustomerService.getDetailsBill(id);
      response = res;

      if (res.success == true) {
        detailsBills = res.data;
        // appLog("List: ${notifications}");
        return true;
      } else {
        errorMessage = res.message;
        return false;
      }

    } catch (e) {
      errorMessage = 'Đã xảy ra lỗi: $e';
      appLog('Đã xảy ra lỗi: $e');
      return false;
    } finally {
      isLoadingDetails = false;
      notifyListeners();
    }
  }
}
