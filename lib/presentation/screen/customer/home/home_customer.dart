
import 'package:clean_water/data/configs/app_config.dart';
import 'package:clean_water/presentation/routers/configs/app_router_config.dart';
import 'package:clean_water/presentation/screen/more/exit_confirm_dialog.dart';
import 'package:clean_water/presentation/screen/staff/home/tabs/account_tabs.dart';
import 'package:clean_water/presentation/screen/staff/home/tabs/home_tabs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:clean_water/presentation/helper/check_login_helper.dart';

class HomeCustomer extends StatefulWidget {
  const HomeCustomer({super.key});

  @override
  State<HomeCustomer> createState() => _HomeCustomerState();
}

class _HomeCustomerState extends State<HomeCustomer> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeTab(),
    AccountTab(),
  ];

  Future<void> _onItemTapped(int index) async {
    if (_selectedIndex == index) return;

    // Tab 0 = Home → luôn cho vào
    if (index == 0 || index == 1) {
      setState(() {
        _selectedIndex = index;
      });
      return;
    }

    // Check login cho các tab còn lại
    final isLoggedIn = await CheckLoginHelper.isLoggedIn();

    if (!isLoggedIn) {
      if (!mounted) return;
      context.go(AppRouterConfig.login);
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExitAppWrapper(
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Color(0x14000000),
                width: 0.8,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => _onItemTapped(index),
            selectedItemColor: const Color(0xFF4A90E2),
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book),
                label: 'Học',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star_border),
                activeIcon: Icon(Icons.star),
                label: 'Đánh giá',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Tài khoản',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
