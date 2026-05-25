import 'package:clean_water/data/services/forgot_password_service.dart';
import 'package:flutter/material.dart';
import '../../data/models/api_response.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  final ForgotPasswordService _forgotPasswordService = ForgotPasswordService();
  bool isLoading = false;
  String? errorMessage;
  ApiResponse? authResponse;

  Future<bool> getOTP(Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _forgotPasswordService.getOTP(data);

      authResponse = res;

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

  Future<bool> verifyOTP(Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _forgotPasswordService.verifyOTP(data);
      authResponse = res;
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

  Future<bool> resetPassword(Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _forgotPasswordService.resetPassword(data);
      authResponse = res;
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
