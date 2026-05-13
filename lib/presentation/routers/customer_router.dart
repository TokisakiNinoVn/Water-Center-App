import 'package:clean_water/presentation/screen/customer/home/home_customer.dart';
import 'package:clean_water/presentation/screen/customer/search/lits_water_meter.dart';
import 'package:clean_water/presentation/screen/customer/water_reading/create_index.dart';
import 'package:clean_water/presentation/screen/customer/water_reading/water_reading.dart';
import 'package:go_router/go_router.dart';

final List<GoRoute> customerRoutes = [
  GoRoute(
      path: '/home-customer',
      builder: (context, state) => const HomeCustomer(),
      routes: [
        GoRoute(
          path: "/list-water-meter",
          builder: (_, __) => ListWaterMeterCustomer(),
        ),
        GoRoute(
          path: "/water-meter",
          builder: (_, __) => WaterReadingCustomer(),
          routes: [
            GoRoute(
              path: '/save-index',
              builder: (_, state) {
                final data = state.extra as Map<String, dynamic>;
                return CreateIndexCustomer(
                  data: data,
                );
              },
            ),
          ],
        ),
      ]
  ),
];
