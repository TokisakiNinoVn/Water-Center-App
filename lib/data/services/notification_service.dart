import 'package:clean_water/core/apis/staff/notification_api.dart';
import 'package:clean_water/core/network/api_methods_private.dart';
import 'package:clean_water/data/enums/http_method.dart';
import 'package:clean_water/data/models/api_response.dart';

class NotificationService {
  Future<ApiResponse> checkRead(data) async {
    return await ApiMethodsPrivate.request(
      HttpMethod.post,
      NotificationApi.checkRead,
      body: data,
    );
  }

  Future<ApiResponse> getList() async {
    return await ApiMethodsPrivate.request(
      HttpMethod.get,
      NotificationApi.list,
    );
  }
}
