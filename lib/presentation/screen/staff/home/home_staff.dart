import 'package:clean_water/data/configs/color_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:clean_water/data/configs/app_config.dart';
import 'package:clean_water/presentation/routers/configs/app_router_config.dart';
import 'package:clean_water/presentation/screen/more/exit_confirm_dialog.dart';
import 'package:clean_water/presentation/screen/staff/home/tabs/account_tabs.dart';
import 'package:clean_water/presentation/screen/staff/home/tabs/home_tabs.dart';

import 'package:clean_water/presentation/helper/check_login_helper.dart';

class HomeStaff extends StatefulWidget {
  const HomeStaff({super.key});

  @override
  State<HomeStaff> createState() => _HomeStaffState();
}

class _HomeStaffState extends State<HomeStaff> {
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
            items: [

              BottomNavigationBarItem(
                icon: FaIcon(
                  FontAwesomeIcons.house,
                  size: 18,
                  color: ColorConfig.black.withOpacity(0.4),
                ),
                activeIcon: FaIcon(
                  FontAwesomeIcons.house,
                  size: 20,
                  color: ColorConfig.primary,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(
                  FontAwesomeIcons.user,
                  size: 18,
                  color: ColorConfig.black.withOpacity(0.4),
                ),
                activeIcon: FaIcon(
                  FontAwesomeIcons.user,
                  size: 20,
                  color: ColorConfig.primary,
                ),
                label: 'Tài khoản',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
