import 'package:clean_water/core/network/dio_client.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';

class AuthRemote {
  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await DioClient.dio.post(
      "/student/login/auth",
      data: {"email": email, "password": password},
    );

    return res.data;
  }
}
