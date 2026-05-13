import 'package:clean_water/core/apis/customer/auth_customer_api.dart';
import 'package:clean_water/core/apis/staff/auth_staff_api.dart';
import 'package:clean_water/core/network/api_methods_public.dart';
import 'package:clean_water/data/enums/http_method.dart';
import 'package:clean_water/data/enums/login_type_role.dart';
import 'package:clean_water/data/extensions/login_type_role_extension.dart';
import 'package:clean_water/data/models/api_response.dart';

class AuthService {
  Future<ApiResponse> login(LoginTypeRole loginTypeRole, data) async {
    return await ApiMethodsPublic.request(
      HttpMethod.post,
      loginTypeRole.isStaff ? AuthStaffApi.login : AuthCustomerApi.login,
      body: data,
    );
  }
}
