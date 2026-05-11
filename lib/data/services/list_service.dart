import 'dart:io';

import 'package:clean_water/core/apis/account_api.dart';
import 'package:clean_water/core/apis/customer_api.dart';
import 'package:clean_water/core/apis/list_api.dart';
import 'package:clean_water/core/network/api_methods_private.dart';
import 'package:clean_water/data/enums/http_method.dart';
import 'package:clean_water/data/models/api_response.dart';

import '../../core/storage/index_storage.dart';
import '../configs/app_config.dart';

class ListService {
  Future<ApiResponse> getPricingObjects() async {
    return await ApiMethodsPrivate.request(
      HttpMethod.get,
      ListApi.pricingObjects,
    );
  }

  Future<ApiResponse> getWaterPrices() async {
    return await ApiMethodsPrivate.request(
      HttpMethod.get,
      ListApi.waterPrices,
    );
  }

  Future<ApiResponse> getClientTypes() async {
    return await ApiMethodsPrivate.request(
      HttpMethod.get,
      ListApi.clientTypes,
    );
  }

  Future<ApiResponse> getAreas() async {
    return await ApiMethodsPrivate.request(
      HttpMethod.get,
      ListApi.areas,
    );
  }

  Future<ApiResponse> getRegions() async {
    return await ApiMethodsPrivate.request(
      HttpMethod.get,
      ListApi.regions,
    );
  }
}
