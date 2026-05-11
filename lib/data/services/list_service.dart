import 'dart:io';

import 'package:clean_water/core/apis/account_api.dart';
import 'package:clean_water/core/apis/customer_api.dart';
import 'package:clean_water/core/network/api_methods_private.dart';
import 'package:clean_water/data/enums/http_method.dart';
import 'package:clean_water/data/models/api_response.dart';

import '../../core/storage/index_storage.dart';
import '../configs/app_config.dart';

class CustomerService {
  // Future<ApiResponse> me() async {
  //   return await ApiMethodsPrivate.request(
  //     HttpMethod.get,
  //     AccountApi.me,
  //   );
  // }

  Future<ApiResponse> registerCustomerByStaff(Map<String, dynamic> body) async {
    return await ApiMethodsPrivate.request(
      HttpMethod.post,
      CustomerApi.registerCustomer,
      body: body,
    );
  }

  // SỬA: Thêm tham số avatarFile
  // Future<ApiResponse> updateWithAvatar(
  //     Map<String, dynamic> body, {
  //       required File avatarFile,
  //     }) async {
  //   // Chuyển đổi body Map thành Map<String, String> cho fields
  //   final Map<String, String> fields = {};
  //   body.forEach((key, value) {
  //     fields[key] = value.toString();
  //   });
  //
  //   return await ApiMethodsPrivate.postFormData(
  //     AccountApi.update,
  //     fields: fields,
  //     files: {
  //       'avatar': avatarFile, // Key 'avatar' là tên field trên server
  //     },
  //   );
  // }
}
