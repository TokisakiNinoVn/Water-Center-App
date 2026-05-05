import 'package:clean_water/presentation/screen/customer/home/home_customer.dart';
import 'package:clean_water/presentation/screen/staff/home/home_staff.dart';
import 'package:go_router/go_router.dart';

import '../helper/check_login_helper.dart';

final List<GoRoute> customerRoutes = [
  GoRoute(
      path: '/home-customer',
      builder: (context, state) => const HomeCustomer(),
      routes: [

      ]
  ),
];
