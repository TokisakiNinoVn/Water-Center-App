// import 'package:dio/dio.dart';
// import 'package:clean_water/domain/entities/user_entity.dart';
// import 'package:clean_water/domain/repositories/auth_repository.dart';
// import 'package:clean_water/data/datasources/auth_remote.dart';
// import 'package:clean_water/data/models/user_model.dart';
// import 'package:clean_water/presentation/utils/logger_utils.dart';
//
// class AuthRepositoryImpl implements AuthRepository {
//   final AuthRemote remote;
//
//   AuthRepositoryImpl(this.remote);
//
//   @override
//   Future<UserEntity> login(String email, String pass) async {
//     final data = await remote.login(email, pass);
//
//     appLog("AuthRepositoryImpl login response: $data");
//
//     if (data['token'] == null) {
//       throw DioException(
//         requestOptions: RequestOptions(path: '/student/login/auth'),
//         response: Response(
//           requestOptions: RequestOptions(path: '/student/login/auth'),
//           data: data,
//           statusCode: 401,
//         ),
//         error: data['message'] ?? "Đăng nhập thất bại",
//       );
//     }
//
//     return UserModel.fromJson(data);
//   }
// }
