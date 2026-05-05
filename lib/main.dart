import 'package:clean_water/data/configs/app_config.dart';
import 'package:flutter/material.dart';

import 'package:clean_water/core/network/dio_client.dart';
import 'package:clean_water/presentation/routers/app_router.dart';
import 'package:clean_water/presentation/providers/index_provider.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light, // iOS
      statusBarIconBrightness: Brightness.light, // Android
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: Builder(
        builder: (context) {
          DioClient.init(context);

          return MaterialApp.router(
            routerConfig: appRouter,
            title: AppConfig.appName,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'BeVietnamPro',
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
