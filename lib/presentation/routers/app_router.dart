import 'package:clean_water/presentation/routers/staff_router.dart';
import 'package:clean_water/presentation/screen/notification/list_notification.dart';
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
import '../screen/more/splash_screen.dart';
import 'customer_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// final appRouter = GoRouter(
//   navigatorKey: rootNavigatorKey,
//   initialLocation: "/",
//   routes: [
//     GoRoute(
//       path: '/',
//       builder: (context, state) => const SplashScreen(),
//     ),
//     GoRoute(path: "/login", builder: (_, __) => const LoginScreen()),
//     GoRoute(
//       path: "/home",
//       builder: (_, __) => MainScreen(),
//       routes: [
//
//           ]
//         ),
//
//         GoRoute(
//           path: "change-password",
//           builder: (_, __) => const ChangePasswordScreen(),
//         ),
//         GoRoute(
//           path: "update-account",
//           builder: (_, __) => const UpdateAccountScreen(),
//         ),
//         GoRoute(
//           path: "update-account",
//           builder: (_, __) => const UpdateAccountScreen(),
//         ),
//         GoRoute(
//           path: "notification",
//           builder: (_, __) => const ListNotificationScreen(),
//         ),
//       ]
//     ),
//
//     // GoRoute(
//     //   path: "/forgot-password",
//     //   builder: (_, __) => EnterEmailScreen(),
//     //   routes: [
//     //     GoRoute(
//     //       path: "confirm-otp",
//     //         builder: (_, state) {
//     //           final data = state.extra as Map<String, dynamic>? ?? {};
//     //           final email = data['email'];
//     //           return ConfirmOTPScreen(email: email);
//     //         },
//     //
//     //         routes: [
//     //         GoRoute(
//     //           path: "reset-password",
//     //           builder: (context, state) {
//     //             final data = state.extra as Map<String, dynamic>? ?? {};
//     //
//     //             final email = data['email'];
//     //             final otp = data['otp'];
//     //
//     //             return ResetPasswordScreen(
//     //               email: email,
//     //               otp: otp,
//     //             );
//     //           },
//     //         ),
//     //
//     //       ]
//     //     ),
//     //   ]
//     // ),
//     //
//     // GoRoute(
//     //   path: "/getting-started",
//     //   builder: (_, __) => const FirstStartScreen(),
//     //   routes: [
//     //     GoRoute(
//     //       path: "second",
//     //       builder: (_, __) => const SecondStartScreen(),
//     //       routes: [
//     //         GoRoute(
//     //             path: "third",
//     //             builder: (_, __) => const ThirdStartScreen(),
//     //         )
//     //       ]
//     //     )
//     //   ]
//     // ),
//   ],
// );

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
    ...customerRoutes,
    ...staffRoutes,
  ],
);

