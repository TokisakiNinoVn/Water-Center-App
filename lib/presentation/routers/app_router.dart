import 'package:clean_water/presentation/routers/staff_router.dart';
import 'package:clean_water/presentation/screen/notification/list_notification.dart';
import 'package:clean_water/presentation/screen/public/home_public.dart';
import 'package:clean_water/presentation/screen/staff/home/home_staff.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import 'package:clean_water/presentation/screen/auth/login_screen.dart';

import '../screen/forgot_password/confirm_otp_screen.dart';
import '../screen/forgot_password/enter_email_screen.dart';
import '../screen/forgot_password/reset_password.dart';
import '../screen/getting_started/first_start_screen.dart';
import '../screen/getting_started/second_start_screen.dart';
import '../screen/getting_started/third_start_screen.dart';
import '../screen/public/splash_screen.dart';
import 'customer_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: "/",
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: "/login",
      builder: (_, __) => const LoginScreen(),
    ),

    GoRoute(
      path: "/home-public",
      builder: (_, __) => const HomePublic(),
    ),
    ...customerRoutes,
    ...staffRoutes,
  ],
);

