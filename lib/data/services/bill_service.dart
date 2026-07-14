import 'package:clean_water/core/apis/customer/bill_customer_api.dart';
import 'package:clean_water/core/apis/staff/auth_staff_api.dart';
import 'package:clean_water/core/network/api_methods_private.dart';

import '../../core/network/api_methods_public.dart';
import '../../presentation/helper/url_builder.dart';
import '../enums/http_method.dart';
import '../models/api_response.dart';

class BillCustomerService {
  // Future<ApiResponse> postService(data) async {
  //   return await ApiMethodsPublic.request(
  //     HttpMethod.post,
  //     AuthStaffApi.login,
  //     body: data,
  //   );
  // }
  //
  // Future<ApiResponse> putService(int? id, data) async {
  //   return await ApiMethodsPublic.request(
  //     HttpMethod.put,
  //     UrlBuilder.withId(AuthStaffApi.login, id),
  //     body: data,
  //   );
  // }

  Future<ApiResponse> getDetailsBill(int id) async {
    return await ApiMethodsPrivate.request(
      HttpMethod.get,
      "${BillCustomerApi.details}/$id",
    );
  }

  // Future<ApiResponse> getV2Service(String? id) async {
  //   return await ApiMethodsPublic.request(
  //     HttpMethod.get,
  //     UrlBuilder.withId(AuthStaffApi.getOTP, id),
  //   );
  // }
  //
  // Future<ApiResponse> getV3Service(String? id, String? name) async {
  //   return await ApiMethodsPublic.request(
  //     HttpMethod.get,
  //     AuthStaffApi.getOTP,
  //     queryParams: {
  //       'id': id,
  //       'name': name,
  //     },
  //   );
  // }
  //
  // Future<ApiResponse> deleteService(String? id) async {
  //   return await ApiMethodsPublic.request(
  //     HttpMethod.delete,
  //     UrlBuilder.withId(AuthStaffApi.getOTP, id),
  //   );
  // }
}
