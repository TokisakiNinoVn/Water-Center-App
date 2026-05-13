import 'dart:io';

import 'package:clean_water/core/apis/customer/water_index_api.dart';
import 'package:clean_water/core/apis/staff/account_api.dart';
import 'package:clean_water/core/apis/staff/water_index_api.dart';
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

  // Customer
  Future<ApiResponse> listWaterMeterCustomer() async {
    return await ApiMethodsPrivate.request(
      HttpMethod.get,
      WaterIndexCustomerApi.listWaterMeter,
    );
  }

  Future<ApiResponse> saveIndexCustomer(
    Map<String, dynamic> data,
    { required File imageFile }
  ) async {

    final Map<String, String> fields = {};
    data.forEach((key, value) {
      fields[key] = value.toString();
    });
    // appLog("Data save water index: $data");

    return await ApiMethodsPrivate.postFormData(
      WaterIndexCustomerApi.recordIndex,
      fields: fields,
      files: {
        'anh_minh_chung': imageFile,
      },
    );
  }
}
