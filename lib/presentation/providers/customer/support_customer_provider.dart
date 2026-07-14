import 'dart:io';

import 'package:clean_water/data/models/api_response.dart';
import 'package:clean_water/data/services/support_service.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';

class SupportCustomerProvider extends ChangeNotifier {
  final SupportService _supportService = SupportService();

  bool isLoading = false;
  String? errorMessage;
  ApiResponse? response;
  Map<String, dynamic> showData = {};
  List<dynamic> listRequestsSupport = [];
  List<dynamic> detailSupportData = [];

  Future<bool> createSupport(Map<String, dynamic> payload) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _supportService.createSupport(payload);
      appLog("Response: $res");
      response = res;

      if (res.success == true) {
        showData = res.data;
        // appLog("List: ${showData}");
        return true;
      } else {
        errorMessage = res.message;
        appLog("Error: ${res.message}");
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

  Future<bool> listSupport() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _supportService.listSupport();
      // appLog("Response:", data: res);
      response = res;

      if (res.success == true) {
        listRequestsSupport = res.data['support'];
        // appLog("List requests support:", data: listRequestsSupport);
        return true;
      } else {
        errorMessage = res.message;
        appLog("Error: ${res.message}");
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

  Future<bool> detailSupport(id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _supportService.detailSupport(id);
      response = res;

      if (res.success == true) {
        detailSupportData = res.data;
        appLog("Detail support:", data: detailSupportData);
        return true;
      } else {
        errorMessage = res.message;
        appLog("Error: ${res.message}");
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
