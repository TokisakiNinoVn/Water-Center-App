import 'package:clean_water/data/configs/color_config.dart';
import 'package:clean_water/presentation/screen/customer/home/tabs/account_tabs.dart';
import 'package:clean_water/presentation/screen/customer/home/tabs/chat_tabs.dart';
import 'package:clean_water/presentation/screen/customer/home/tabs/notification_tabs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:clean_water/data/configs/app_config.dart';
import 'package:clean_water/presentation/helper/check_login_helper.dart';
import 'package:clean_water/presentation/routers/configs/app_router_config.dart';
import 'package:clean_water/presentation/screen/customer/home/tabs/customer_home_tabs.dart';
import 'package:clean_water/presentation/screen/more/exit_confirm_dialog.dart';

class HomeCustomer extends StatefulWidget {
  const HomeCustomer({super.key});

  @override
  State<HomeCustomer> createState() => _HomeCustomerState();
}

class _HomeCustomerState extends State<HomeCustomer> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeTabCustomer(),
    NotificationCustomerTab(),
    ChatCustomerTab(),
    AccountCustomerTab(),
  ];

  Future<void> _onItemTapped(int index) async {
    if (_selectedIndex == index) return;

    if (index == 0 || index == 1 || index == 2) {
      setState(() {
        _selectedIndex = index;
      });
      return;
    }

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
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            /// PAGE CONTENT
            Positioned.fill(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
            /// FLOATING NAVBAR
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: _buildFloatingNavbar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavbar() {
    return SizedBox(
      height: 82,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          /// FLOATING BAR (background)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  /// LEFT SIDE
                  // _buildNavItem(
                  //   icon: Icons.menu_book_outlined,
                  //   label: "Giới thiệu",
                  //   index: 1,
                  // ),
                  // _buildNavItem(
                  //   icon: Icons.support_agent_outlined,
                  //   label: "Hỗ trợ",
                  //   index: 2,
                  // ),
                  // const SizedBox(width: 56),

                  const SizedBox(width: 76),
                  _buildNavItem(
                    icon: Icons.notifications,
                    label: "Thông báo",
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.message,
                    label: "Tin nhắn",
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    label: "Tài khoản",
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
          /// HOME BUTTON
          Positioned(
            top: 0,
            left: 20,
            child: GestureDetector(
              onTap: () => _onItemTapped(0),
              child: Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorConfig.primary,
                  boxShadow: [
                    BoxShadow(
                      color: ColorConfig.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  _selectedIndex == 0
                      ? Icons.home_rounded
                      : Icons.home_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(
              //   icon,
              //   size: 22,
              //   color: isSelected ? ColorConfig.primary : Colors.grey,
              // ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: isSelected ? ColorConfig.primary : Colors.grey,
                  ),

                  /// RED DOT NOTIFICATION
                  if (index == 1) // chỉ hiện ở tab thông báo
                    Positioned(
                      right: -1,
                      top: -1,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? ColorConfig.primary : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}