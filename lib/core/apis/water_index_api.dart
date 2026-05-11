import 'package:clean_water/data/configs/app_config.dart';

class WaterIndexApi {
  static const String list = '${AppConfig.apiUrl}/water-meter';
  static const String create = '${AppConfig.apiUrl}/water-history/store';
  static const String show = '${AppConfig.apiUrl}/water-meter/show';
}
