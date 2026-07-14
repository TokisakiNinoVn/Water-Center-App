import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:clean_water/data/configs/color_config.dart';
import 'package:clean_water/presentation/routers/configs/app_router_config.dart';

import 'package:clean_water/presentation/screen/public/tabs/introduce_tabs.dart';
import 'package:clean_water/presentation/screen/public/tabs/new_tab.dart';
import 'package:clean_water/presentation/screen/public/tabs/policy_tab.dart';
import 'package:clean_water/presentation/screen/public/tabs/support_tabs.dart';

import 'package:clean_water/presentation/screen/more/exit_confirm_dialog.dart';

class HomePublic extends StatefulWidget {
  const HomePublic({super.key});

  @override
  State<HomePublic> createState() => _HomePublicState();
}

class _HomePublicState extends State<HomePublic> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    NewPublicTab(),
    SupportPublicTab(),
    PolicyPublicTab(),
    IntroducePublicTab(),
  ];

  final List<_NavItemModel> _navItems = const [
    _NavItemModel(
      icon: Icons.home_rounded,
      label: 'Trang chủ',
    ),
    _NavItemModel(
      icon: Icons.support_agent_rounded,
      label: 'Hỗ trợ',
    ),
    _NavItemModel(
      icon: Icons.verified_user_rounded,
      label: 'Chính sách',
    ),
    _NavItemModel(
      icon: Icons.water_drop_rounded,
      label: 'Giới thiệu',
    ),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  void _goToLogin() {
    context.push(AppRouterConfig.login);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return ExitAppWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        extendBody: true,

        /// APPBAR (chỉ logo và tiêu đề)
        // appBar: PreferredSize(
        //   preferredSize: Size.fromHeight(topPadding + 30),
        //   child: Container(
        //     padding: EdgeInsets.only(
        //       top: topPadding,
        //       left: 18,
        //       right: 18,
        //     ),
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black.withOpacity(0.03),
        //           blurRadius: 10,
        //           offset: const Offset(0, 4),
        //         ),
        //       ],
        //     ),
        //     child: Row(
        //       children: [
        //         Expanded(
        //           child: Row(
        //             children: [
        //               Container(
        //                 width: 42,
        //                 height: 42,
        //                 decoration: BoxDecoration(
        //                   color: ColorConfig.primary.withOpacity(0.12),
        //                   borderRadius: BorderRadius.circular(14),
        //                 ),
        //                 child: Icon(
        //                   Icons.water_drop_rounded,
        //                   color: ColorConfig.primary,
        //                   size: 24,
        //                 ),
        //               ),
        //               const SizedBox(width: 12),
        //               const Column(
        //                 mainAxisAlignment: MainAxisAlignment.center,
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   Text(
        //                     'Clean Water',
        //                     style: TextStyle(
        //                       fontSize: 17,
        //                       fontWeight: FontWeight.w700,
        //                     ),
        //                   ),
        //                   SizedBox(height: 2),
        //                   Text(
        //                     'Nước sạch cho mọi nhà',
        //                     style: TextStyle(
        //                       fontSize: 11,
        //                       color: Colors.grey,
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),

        /// BODY – Stack chứa nút đăng nhập sát mép phải
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
            Positioned(
              bottom: 90,      // cách bottom navbar một khoảng thoải mái
              right: 0,        // dính sát mép phải màn hình
              child: _CollapsibleLoginButton(onLogin: _goToLogin),
            ),
          ],
        ),

        /// BOTTOM NAVIGATION BAR (giữ nguyên)
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: List.generate(
                _navItems.length,
                    (index) => _buildNavItem(
                  item: _navItems[index],
                  index: index,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required _NavItemModel item,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorConfig.primary.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 23,
                color: isSelected
                    ? ColorConfig.primary
                    : Colors.grey.shade500,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? ColorConfig.primary
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nút đăng nhập có thể thu gọn, được dán sát mép phải,
/// chỉ bo góc bên trái (trên và dưới).
class _CollapsibleLoginButton extends StatefulWidget {
  final VoidCallback onLogin;

  const _CollapsibleLoginButton({required this.onLogin});

  @override
  State<_CollapsibleLoginButton> createState() =>
      _CollapsibleLoginButtonState();
}

class _CollapsibleLoginButtonState extends State<_CollapsibleLoginButton>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: ColorConfig.primary,
        // Bo góc chỉ bên trái: trên-trái và dưới-trái
        borderRadius: _isExpanded
            ? const BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        )
            : const BorderRadius.only(
          topLeft: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isExpanded ? _buildExpandedMode() : _buildCollapsedMode(),
    );
  }

  Widget _buildExpandedMode() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Phần nút Đăng nhập (có thể bấm)
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onLogin,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(32), // bo góc trái khi bấm
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Icon(Icons.login_rounded, color: Colors.white, size: 20),
                  // SizedBox(width: 8),
                  Text(
                    'Đăng nhập',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Nút thu gọn
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleExpand,
            // Không bo góc bên phải vì sát mép màn hình
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Icon(Icons.arrow_right, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedMode() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon đăng nhập (vẫn bấm được)
        // Material(
        //   color: Colors.transparent,
        //   child: InkWell(
        //     onTap: widget.onLogin,
        //     borderRadius: const BorderRadius.horizontal(
        //       left: Radius.circular(40),
        //     ),
        //     child: const Padding(
        //       padding: EdgeInsets.all(12),
        //       child: Icon(Icons.login_rounded, color: Colors.white, size: 24),
        //     ),
        //   ),
        // ),
        // Nút mở rộng
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleExpand,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.arrow_left_outlined, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItemModel {
  final IconData icon;
  final String label;

  const _NavItemModel({
    required this.icon,
    required this.label,
  });
}