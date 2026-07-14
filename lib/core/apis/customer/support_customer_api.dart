import 'package:clean_water/data/configs/app_config.dart';

class SupportCustomerApi {
  static const String create =
      '${AppConfig.apiUrl}/customer/support/store-new-support';
  static const String list = '${AppConfig.apiUrl}/customer/support';
  static const String detail =
      '${AppConfig.apiUrl}/customer/support/show-support';
}
