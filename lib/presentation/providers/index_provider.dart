import 'package:clean_water/presentation/providers/customer/account_customer_provider.dart';
import 'package:clean_water/presentation/providers/staff/account_provider.dart';
import 'package:clean_water/presentation/providers/customer/bill_customer_provider.dart';
import 'package:clean_water/presentation/providers/customer/notification_customer_provider.dart';
import 'package:clean_water/presentation/providers/customer/water_index_customer_provider.dart';
import 'package:clean_water/presentation/providers/customer/customer_provider.dart';
import 'package:clean_water/presentation/providers/auth/forgot_password_provider.dart';
import 'package:clean_water/presentation/providers/shared/list_provider.dart';
import 'package:clean_water/presentation/providers/staff/water_index_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'package:clean_water/data/datasources/index_remote.dart';
import 'package:clean_water/data/repositories/repo_impl.dart';
import 'package:clean_water/domain/usecases/login_usecase.dart';

import 'auth/auth_provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        // ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationCustomerProvider()),
        ChangeNotifierProvider(create: (_) => WaterIndexProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ListProvider()),
        ChangeNotifierProvider(create: (_) => WaterIndexCustomerProvider()),
        ChangeNotifierProvider(create: (_) => BillCustomerProvider()),
        ChangeNotifierProvider(create: (_) => AccountCustomerProvider()),
      ],
      child: child,
    );
  }
}
