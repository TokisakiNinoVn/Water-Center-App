import 'dart:io';

import 'package:clean_water/data/models/api_response.dart';
import 'package:clean_water/data/services/account_service.dart';
import 'package:clean_water/data/services/water_index_service.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';
import '../../core/storage/index_storage.dart';

class WaterIndexProvider extends ChangeNotifier {
  final WaterIndexService _waterIndexService = WaterIndexService();

  bool isLoadingList = false;

  String? errorMessage;
  ApiResponse? response;
  Map<String, dynamic> showData = {};
  List waterIndex = [];

  Future<bool> loadList() async {
    isLoadingList = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _waterIndexService.list();
      response = res;

      if (res.success == true) {
        waterIndex = res.data;
        // appLog("List: ${waterIndex}");
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
      isLoadingList = false;
      notifyListeners();
    }
  }

  Future<bool> detailsWaterIndex(int id) async {
    isLoadingList = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _waterIndexService.show(id);
      response = res;

      if (res.success == true) {
        showData = res.data;
        appLog("List: ${showData}");
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
      isLoadingList = false;
      notifyListeners();
    }
  }

  Future<bool> saveWaterIndex(Map<String, dynamic> body) async {
    isLoadingList = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _waterIndexService.saveIndex(body);
      response = res;

      if (res.success == true) {
        showData = res.data;
        // appLog("List: ${showData}");
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
      isLoadingList = false;
      notifyListeners();
    }
  }
}
