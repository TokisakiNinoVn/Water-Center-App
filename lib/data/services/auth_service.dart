import 'package:clean_water/core/apis/auth_api.dart';
import 'package:clean_water/core/network/api_methods_public.dart';
import 'package:clean_water/data/enums/http_method.dart';
import 'package:clean_water/data/models/api_response.dart';

class AuthService {
  Future<ApiResponse> login(data) async {
    return await ApiMethodsPublic.request(
      HttpMethod.post,
      AuthApi.login,
      body: data,
    );
  }
}
