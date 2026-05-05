import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:clean_water/presentation/routers/app_router.dart';
import 'package:clean_water/presentation/routers/configs/app_router_config.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:clean_water/data/configs/app_config.dart';
import 'package:clean_water/core/storage/index_storage.dart';

class DioClient {
  static final Dio dio = Dio(BaseOptions(baseUrl: AppConfig.apiUrl));

  static void init(BuildContext context) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await LocalStorage.getToken();
          final email = await LocalStorage.getEmail();
          if (token != null && email != null) {
            options.headers['Authorization'] = "Bearer $token";
            options.headers['X-user-email'] = email;
          }
          handler.next(options);
        },
          onError: (e, handler) async {
            final statusCode = e.response?.statusCode;
            final path = e.requestOptions.path;
            appLog("Dio error: $statusCode - ${e.response?.data}");

            final isLoginApi = path.contains('/auth') || path.contains('/auth/login-otp') || path.contains('/auth/confirm-login-otp');
            appLog("Is login API: $isLoginApi");
            if (statusCode == 401 && !isLoginApi) {
              appLog("401 Unauthorized error, logging out user and navigating to login screen");
              await LocalStorage.logout();

              final context = rootNavigatorKey.currentContext;
              if (context != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Phiên đăng nhập đã hết hạn")),
                );
                context.go(AppRouterConfig.login);
              }
            } else if (statusCode == 401 && isLoginApi) {
              appLog("Unauthorized error on login API, returning error message");

              return handler.resolve(
                Response(
                  requestOptions: e.requestOptions,
                  data: e.response?.data ?? {"message": "Đăng nhập thất bại"},
                  statusCode: 401,
                ),
              );
            }

            handler.next(e);
          }
      ),
    );
  }
}
