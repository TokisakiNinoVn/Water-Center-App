import 'package:clean_water/core/apis/customer/support_customer_api.dart';
import 'package:clean_water/core/network/api_methods_private.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import '../enums/http_method.dart';
import '../models/api_response.dart';

class SupportService {
  Future<ApiResponse> createSupport(payload) async {
    return await ApiMethodsPrivate.request(
      HttpMethod.post,
      SupportCustomerApi.create,
      body: payload,
    );
  }

  Future<ApiResponse> listSupport() async {
    return await ApiMethodsPrivate.request(
      HttpMethod.get,
      SupportCustomerApi.list,
    );
  }

  Future<ApiResponse> detailSupport(id) async {
    return await ApiMethodsPrivate.request(
      HttpMethod.get,
      "${SupportCustomerApi.detail}/$id",
    );
  }
}
