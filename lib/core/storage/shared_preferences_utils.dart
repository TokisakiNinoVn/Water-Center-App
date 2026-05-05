import 'package:clean_water/presentation/utils/logger_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtils {
  static Future<bool> listAllKeyValue() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final keys = prefs.getKeys();

      if (keys.isEmpty) {
        appLog("No data found in SharedPreferences.");
        return true;
      }

      int index = 1;

      for (final key in keys) {
        final value = prefs.get(key);
        appLog(
            "[$index] Key: $key | Value: $value | Type: ${value.runtimeType}"
        );
        index++;
      }

      return true;
    } catch (e) {
      appLog("Error while listing SharedPreferences: $e");
      return false;
    }
  }

  static Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('isLogin', false);
  }
}