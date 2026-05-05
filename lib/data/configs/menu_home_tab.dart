import 'package:clean_water/presentation/routers/configs/app_router_config.dart';
import 'package:clean_water/presentation/routers/configs/customer_router_config.dart';
import 'package:clean_water/presentation/routers/configs/staff_router_config.dart';
import 'package:flutter/material.dart';

import 'color_config.dart';

final List<Map<String, dynamic>> menuItems = [
  {
    'icon': Icons.water_drop,
    'title': 'Ghi số nước',
    'subtitle': 'Cập nhật chỉ số mới',
    'color': ColorConfig.primary,
    'route': StaffRouterConfig.waterReading,
  },
  {
    'icon': Icons.history,
    'title': 'Lịch sử ghi',
    'subtitle': 'Xem các lần ghi trước',
    'color': ColorConfig.primary,
    'route': "#",
  },
  {
    'icon': Icons.person_add,
    'title': 'Thêm khách hàng',
    'subtitle': 'Đăng ký khách hàng',
    'color': ColorConfig.primary,
    'route': StaffRouterConfig.addCustomer,
  },
  {
    'icon': Icons.pie_chart,
    'title': 'Thống kê',
    'subtitle': 'Báo cáo & biểu đồ',
    'color': ColorConfig.primary,
    'route': AppRouterConfig.home,
  },
  {
    'icon': Icons.notifications_active,
    'title': 'Thông báo',
    'subtitle': 'Lịch ghi & nhắc nhở',
    'color': ColorConfig.primary,
    'route': AppRouterConfig.home,
  },
  {
    'icon': Icons.settings,
    'title': 'Cài đặt',
    'subtitle': 'Tùy chỉnh ứng dụng',
    'color': ColorConfig.primary,
    'route': AppRouterConfig.home,
  },
];