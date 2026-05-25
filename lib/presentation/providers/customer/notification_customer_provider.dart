import 'dart:io';

import 'package:clean_water/data/models/api_response.dart';
import 'package:clean_water/data/services/account_service.dart';
import 'package:clean_water/data/services/notification_service.dart';
import 'package:clean_water/data/services/water_index_service.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool isLoadingList = false;

  String? errorMessage;
  ApiResponse? response;

  List notifications = [];

  // Customer
  Future<bool> loadListNotificationCustomer() async {
    isLoadingList = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _notificationService.getList();
      response = res;

      if (res.success == true) {
        notifications = res.data;
        appLog("List: ${notifications}");
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

  Future<bool> isReadNotification(int id) async {
    isLoadingList = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _notificationService.checkRead(id);
      response = res;

      if (res.success == true) {
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
