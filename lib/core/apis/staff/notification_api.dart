import 'package:clean_water/data/configs/app_config.dart';

class NotificationApi {
  static const String list = '${AppConfig.apiUrl}/student/notifications';
  static const String checkRead = '${AppConfig.apiUrl}/student/notification/isRead';
}
