import 'package:clean_water/core/apis/staff/auth_staff_api.dart';
import 'package:clean_water/core/network/api_methods_public.dart';
import 'package:clean_water/data/enums/http_method.dart';
import 'package:clean_water/data/models/api_response.dart';

class ForgotPasswordService {
  Future<ApiResponse> getOTP(data) async {
    return await ApiMethodsPublic.request(
      HttpMethod.post,
      AuthStaffApi.getOTP,
      body: data,
    );
  }

  Future<ApiResponse> verifyOTP(data) async {
    return await ApiMethodsPublic.request(
      HttpMethod.post,
      AuthStaffApi.verifyOTP,
      body: data,
    );
  }

  Future<ApiResponse> resetPassword(data) async {
    return await ApiMethodsPublic.request(
      HttpMethod.post,
      AuthStaffApi.changePassword,
      body: data,
    );
  }
}
