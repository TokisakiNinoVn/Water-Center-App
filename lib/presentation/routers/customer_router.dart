import 'package:clean_water/presentation/screen/customer/account/update_account.dart';
import 'package:clean_water/presentation/screen/customer/bill/detail_bill_customer.dart';
import 'package:clean_water/presentation/screen/customer/home/home_customer.dart';
import 'package:clean_water/presentation/screen/customer/search/history_water_index.dart';
import 'package:clean_water/presentation/screen/customer/search/list_invoices.dart';
import 'package:clean_water/presentation/screen/customer/search/list_water_meter.dart';
import 'package:clean_water/presentation/screen/customer/support/create_support.dart';
import 'package:clean_water/presentation/screen/customer/support/detail_support.dart';
import 'package:clean_water/presentation/screen/customer/support/list_support.dart';
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
        routes: [
          GoRoute(
            path: '/history-index',
            builder: (_, state) {
              final data = state.extra as Map<String, dynamic>;
              return HistoryWaterIndex(data: data);
            },
          ),
          GoRoute(
            path: '/list-invoices/:id',
            builder: (_, state) {
              final id = int.parse(state.pathParameters['id']!);

              return ListInvoices(id: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: 'details-bills/:id',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);

          return DetailsBillCustomer(id: id);
        },
      ),

      GoRoute(
        path: "/list-support-request",
        builder: (_, __) => ListSupport(),
        routes: [
          GoRoute(
            path: "/create-support-request",
            builder: (_, __) => CreateSupport(),
            routes: [
              
            ]
        ),
          GoRoute(
            path: "/details-support-request/:id",
            builder: (_, state) {
              final id = int.parse(state.pathParameters['id']!);

              return DetailSupport(id: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: "/update-account",
        builder: (_, __) => UpdateProfileCustomer(),
        routes: [],
      ),
      GoRoute(
        path: "/water-meter",
        builder: (_, __) => WaterReadingCustomer(),
        routes: [
          GoRoute(
            path: '/save-index',
            builder: (_, state) {
              final data = state.extra as Map<String, dynamic>;
              return CreateIndexCustomer(data: data);
            },
          ),
          // GoRoute(
          //   path: '/history-index',
          //   builder: (_, state) {
          //     final data = state.extra as Map<String, dynamic>;
          //     return HistoryWaterIndex(
          //       data: data,
          //     );
          //   },
          // ),
        ],
      ),
    ],
  ),
];
