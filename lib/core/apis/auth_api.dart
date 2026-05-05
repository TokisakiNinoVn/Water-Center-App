import 'package:clean_water/data/configs/app_config.dart';

class AuthApi {
  static const String login = '${AppConfig.apiUrl}/login';
  static const String logout = '${AppConfig.apiUrl}/auth/logout';
  static const String register = '${AppConfig.apiUrl}/auth/register';
  static const String checkToken = '${AppConfig.apiUrl}/auth/me';

  static const String getOTP = '${AppConfig.apiUrl}/auth/send-otp';
  static const String verifyOTP = '${AppConfig.apiUrl}/auth/check-otp';
  static const String verifyOTPLogin = '${AppConfig.apiUrl}/auth/verify-otp-login';
  static const String changePassword = '${AppConfig.apiUrl}/auth/reset-password';
}
