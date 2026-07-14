import 'package:clean_water/presentation/screen/staff/account/update_account.dart';
import 'package:clean_water/presentation/screen/staff/water_reading/create_index.dart';
import 'package:go_router/go_router.dart';

import 'package:clean_water/presentation/screen/staff/add_customer/register_customer_screen.dart';
import 'package:clean_water/presentation/screen/staff/home/home_staff.dart';
import 'package:clean_water/presentation/screen/staff/water_reading/water_reading.dart';

final List<GoRoute> staffRoutes = [
  GoRoute(
      path: '/home-staff',
      builder: (context, state) => const HomeStaff(),
      routes: [
        GoRoute(
          path: "/register-customer",
          builder: (_, __) => RegisterCustomerScreen(),
          routes: [
            // GoRoute(
            //   path: "notification",
            //   builder: (_, __) => const ListNotificationScreen(),
            // ),
          ],
        ),
        // GoRoute(
        //   path: "/add-customer",
        //   builder: (_, __) => AddCustomer(),
        //   routes: [
        //     // GoRoute(
        //     //   path: "notification",
        //     //   builder: (_, __) => const ListNotificationScreen(),
        //     // ),
        //   ],
        // ),
        GoRoute(
          path: "/water-reading",
          builder: (_, __) => WaterReading(),
          routes: [
            GoRoute(
              path: '/create',
              builder: (_, state) {
                final data = state.extra as Map<String, dynamic>;
                return CreateIndexScreen(
                  data: data,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: "/update-profile",
          builder: (_, __) => UpdateProfileStaff(),
          routes: [],
        ),
      ]
  ),
];
