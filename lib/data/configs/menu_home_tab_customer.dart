import 'package:clean_water/presentation/routers/configs/app_router_config.dart';
import 'package:clean_water/presentation/routers/configs/customer_router_config.dart';
import 'package:clean_water/presentation/routers/configs/staff_router_config.dart';
import 'package:flutter/material.dart';

import 'color_config.dart';

final List<Map<String, dynamic>> menuHomeCustomerItems = [
  {
    'icon': Icons.water_drop,
    'title': 'Ghi số nước',
    'subtitle': 'Cập nhật chỉ số mới',
    'color': ColorConfig.primary,
    'route': CustomerRouterConfig.listWaterMeter,
  },
  {
    'icon': Icons.water_drop,
    'title': 'Tra cứu số/tiền nước',
    'subtitle': 'Cập nhật chỉ số mới',
    'color': ColorConfig.primary,
    'route': CustomerRouterConfig.listSearchWaterMeter,
  },
  // {
  //   'icon': Icons.history,
  //   'title': 'Lịch sử ghi',
  //   'subtitle': 'Xem các lần ghi trước',
  //   'color': ColorConfig.primary,
  //   'route': "#",
  // },
  {
    'icon': Icons.headphones,
    'title': 'Hỗ trợ',
    'subtitle': 'Hỗ trợ khách hàng',
    'color': ColorConfig.primary,
    'route': "/",
  },
  // {
  //   'icon': Icons.pie_chart,
  //   'title': 'Thống kê',
  //   'subtitle': 'Báo cáo & biểu đồ',
  //   'color': ColorConfig.primary,
  //   'route': AppRouterConfig.home,
  // },
  // {
  //   'icon': Icons.notifications_active,
  //   'title': 'Thông báo',
  //   'subtitle': 'Lịch ghi & nhắc nhở',
  //   'color': ColorConfig.primary,
  //   'route': AppRouterConfig.home,
  // },
  // {
  //   'icon': Icons.settings,
  //   'title': 'Cài đặt',
  //   'subtitle': 'Tùy chỉnh ứng dụng',
  //   'color': ColorConfig.primary,
  //   'route': AppRouterConfig.home,
  // },
];