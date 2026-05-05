import 'package:clean_water/core/apis/auth_api.dart';
import 'package:clean_water/core/network/api_methods_public.dart';
import 'package:clean_water/data/enums/http_method.dart';
import 'package:clean_water/data/models/api_response.dart';

class ForgotPasswordService {
  Future<ApiResponse> getOTP(data) async {
    return await ApiMethodsPublic.request(
      HttpMethod.post,
      AuthApi.getOTP,
      body: data,
    );
  }

  Future<ApiResponse> verifyOTP(data) async {
    return await ApiMethodsPublic.request(
      HttpMethod.post,
      AuthApi.verifyOTP,
      body: data,
    );
  }

  Future<ApiResponse> resetPassword(data) async {
    return await ApiMethodsPublic.request(
      HttpMethod.post,
      AuthApi.changePassword,
      body: data,
    );
  }
}
