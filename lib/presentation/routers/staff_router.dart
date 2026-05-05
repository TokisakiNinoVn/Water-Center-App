import 'package:clean_water/presentation/screen/staff/home/home_staff.dart';
import 'package:go_router/go_router.dart';

import '../helper/check_login_helper.dart';

final List<GoRoute> staffRoutes = [
  GoRoute(
      path: '/home-staff',
      builder: (context, state) => const HomeStaff(),
      routes: [
        // GoRoute(
        //   path: "/home",
        //   builder: (_, __) => MainScreen(),
        //   routes: [
        //     GoRoute(
        //       path: "change-password",
        //       builder: (_, __) => const ChangePasswordScreen(),
        //     ),
        //     GoRoute(
        //       path: "update-account",
        //       builder: (_, __) => const UpdateAccountScreen(),
        //     ),
        //     GoRoute(
        //       path: "notification",
        //       builder: (_, __) => const ListNotificationScreen(),
        //     ),
        //   ],
        // ),
      ]
  ),
];
