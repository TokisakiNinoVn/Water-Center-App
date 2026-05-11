import 'package:clean_water/data/configs/app_config.dart';

class AccountApi {
  static const String me = '${AppConfig.apiUrl}/user-info';
  static const String update = '${AppConfig.apiUrl}/change-info';
}
