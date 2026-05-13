import 'package:clean_water/data/configs/app_config.dart';

class WaterIndexCustomerApi {
  static const String listWaterMeter = '${AppConfig.apiUrl}/customer/meter-get-list';
  static const String recordIndex = '${AppConfig.apiUrl}/customer/water/meter-record';


  static const String show = '${AppConfig.apiUrl}/water-meter/show';
}
