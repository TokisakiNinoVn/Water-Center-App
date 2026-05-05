import 'dart:io';

import 'package:clean_water/data/models/api_response.dart';
import 'package:clean_water/data/services/notification_service.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';
import '../../core/storage/index_storage.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool isLoading = false;
  String? errorMessage;
  ApiResponse? notificationResponse;

  Future<bool> loadList() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _notificationService.getList();
      notificationResponse = res;
      
      appLog('Notification Response: ${res.data}');

      if (res.success == true) {
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

  Future<bool> checkRead(Map<String, dynamic> body) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _notificationService.checkRead(body);

      if (res.success == true) {
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
