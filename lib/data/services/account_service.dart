import 'dart:io';

import 'package:clean_water/core/apis/customer/account_customer_api.dart';
import 'package:clean_water/core/apis/staff/account_api.dart';
import 'package:clean_water/core/network/api_methods_private.dart';
import 'package:clean_water/data/enums/http_method.dart';
import 'package:clean_water/data/models/api_response.dart';

import '../../core/storage/index_storage.dart';
import '../configs/app_config.dart';

class AccountService {
  Future<ApiResponse> me({bool isCustomer = false}) async {
    return await ApiMethodsPrivate.request(
      HttpMethod.get,
      isCustomer? AccountCustomerApi.informationAccountCustomer : AccountApi.me,
    );

  }
  Future<ApiResponse> deleteAccount() async {
    return await ApiMethodsPrivate.request(
      HttpMethod.delete,
      AccountCustomerApi.deleteAccountApi,
    );

  }

  Future<ApiResponse> update(Map<String, dynamic> body, {bool isCustomer = false}) async {
    return await ApiMethodsPrivate.request(
      HttpMethod.post,
      isCustomer ? AccountCustomerApi.updateAccountCustomer : AccountApi.update,
      body: body,
    );
  }

  // SỬA: Thêm tham số avatarFile
  Future<ApiResponse> updateWithAvatar(Map<String, dynamic> body, {required File avatarFile, bool isCustomer = false}) async {
    // Chuyển đổi body Map thành Map<String, String> cho fields
    final Map<String, String> fields = {};
    body.forEach((key, value) {
      fields[key] = value.toString();
    });

    return await ApiMethodsPrivate.postFormData(
      isCustomer ? AccountCustomerApi.updateAccountCustomer : AccountApi.update,
      fields: fields,
      files: {
        'avatar': avatarFile,
      },
    );
  }
}
