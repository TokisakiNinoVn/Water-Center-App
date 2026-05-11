import 'dart:io';

import 'package:clean_water/core/apis/account_api.dart';
import 'package:clean_water/core/apis/water_index_api.dart';
import 'package:clean_water/core/network/api_methods_private.dart';
import 'package:clean_water/data/enums/http_method.dart';
import 'package:clean_water/data/models/api_response.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';

import '../../core/storage/index_storage.dart';
import '../configs/app_config.dart';

class WaterIndexService {
  Future<ApiResponse> list() async {
    return await ApiMethodsPrivate.request(
      HttpMethod.get,
      WaterIndexApi.list,
    );
  }

  Future<ApiResponse> saveIndex(Map<String, dynamic> data) async {
    appLog("Data save water index: $data");
    return await ApiMethodsPrivate.request(
      HttpMethod.post,
      WaterIndexApi.create,
      body: data,
    );
  }

  Future<ApiResponse> show(int id) async {
    return await ApiMethodsPrivate.request(
      HttpMethod.get,
      "${WaterIndexApi.show}/$id",
    );
  }

  // Future<ApiResponse> update(Map<String, dynamic> body) async {
  //   return await ApiMethodsPrivate.request(
  //     HttpMethod.post,
  //     AccountApi.update,
  //     body: body,
  //   );
  // }
  //
  // // SỬA: Thêm tham số avatarFile
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
