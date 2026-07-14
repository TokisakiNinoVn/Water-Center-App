import 'dart:async';
import 'dart:convert';
import 'package:clean_water/data/configs/app_config.dart';
import 'package:clean_water/data/configs/color_config.dart';
import 'package:clean_water/data/services/account_service.dart';
import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:clean_water/presentation/providers/customer/account_customer_provider.dart';
import 'package:clean_water/presentation/routers/configs/app_router_config.dart';
import 'package:clean_water/presentation/routers/configs/customer_router_config.dart';
import 'package:clean_water/presentation/routers/configs/staff_router_config.dart';
import 'package:clean_water/presentation/screen/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/storage/index_storage.dart';

class AccountCustomerTab extends StatefulWidget {
  const AccountCustomerTab({super.key});

  @override
  State<AccountCustomerTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountCustomerTab>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _user;
  final AccountService _accountService = AccountService();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await SharedPrefsService.getValue(PrefType.string, 'user').then((value) {
      if (value != null) {
        setState(() {
          _user = jsonDecode(value);
        });
      }
      _animController.forward();
    });
  }

  Future<void> _showConfirmDeleteAccount() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => CustomDialog(
            iconColor: ColorConfig.primary,
            title: 'Xác nhận xóa tài khoản',
            body:
                'Các thông tin tài khoản của bạn sẽ được xóa. Bạn có chắc chắn xóa tài khoản này?',
            cancelLabel: 'Đóng',
            confirmLabel: 'Xác nhận',
            confirmColor: ColorConfig.error,
            onConfirm: () {
              Navigator.of(dialogContext).pop(true);
            },
          ),
    );

    if (result == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => Center(
              child: CircularProgressIndicator(color: ColorConfig.primary),
            ),
      );

      try {
        final provider = context.read<AccountCustomerProvider>();
        final success = await provider.deleteAccountProvider();

        // Đóng loading
        if (mounted) Navigator.of(context).pop();

        if (success) {
          SnackBarHelper.showSuccess(context, "Xóa tài khoản thành công!");
          SharedPreferencesUtils.logOut();
          context.go(AppRouterConfig.login);
        } else {
          SnackBarHelper.showError(
            context,
            provider.errorMessage ?? "Xóa tài khoản thất bại!",
          );
        }
      } catch (e) {
        // Đóng loading nếu lỗi
        if (mounted) Navigator.of(context).pop();

        SnackBarHelper.showError(context, "Lỗi xóa tài khoản: $e");
      }
    }
  }

  Future<void> _showConfirmLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => CustomDialog(
            iconColor: ColorConfig.primary,
            title: 'Xác nhận đăng xuất',
            body: 'Đăng xuất tài khoản khỏi thiết bị?',
            cancelLabel: 'Đóng',
            confirmLabel: 'Xác nhận',
            confirmColor: ColorConfig.error,
            onConfirm: () {
              Navigator.of(dialogContext).pop(true);
            },
          ),
    );

    if (result == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => Center(
              child: CircularProgressIndicator(color: ColorConfig.error),
            ),
      );

      try {
        // Đóng loading
        if (mounted) Navigator.of(context).pop();
        if (result == true) {
          //     final prefs = await SharedPreferences.getInstance();
          //     await prefs.clear();
          //     await prefs.setBool('isLogin', false);
          //     if (context.mounted) context.go(AppRouterConfig.login);
          //   }
          SnackBarHelper.showSuccess(
            context,
            "Đăng xuất tài khoản thành công!",
          );
          SharedPreferencesUtils.logOut();
          context.go(AppRouterConfig.login);
        } else {
          SnackBarHelper.showError(context, "Đăng xuất thất bại!");
        }
      } catch (e) {
        // Đóng loading nếu lỗi
        if (mounted) Navigator.of(context).pop();
        SnackBarHelper.showError(context, "Lỗi đăng xuất: $e");
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // Mở bằng trình duyệt mặc định
    )) {
      throw Exception('Không thể mở $url');
    }
  }

  String get _displayName => _user?['name'] as String? ?? 'Học viên';
  String get _email => _user?['email'] as String? ?? '';
  String get _role => _user?['role'] as String? ?? 'student';
  String get _roleLabel =>
      _role == 'student'
          ? 'Học sinh'
          : _role == 'teacher'
          ? 'Giáo viên'
          : 'Người dùng';
  String get roleUser => _user?['role'] ?? 'nv';
  String get roleDisplay => roleUser == 'nv' ? "Nhân viên" : "Không xác định";
  String get _avatarLetter =>
      _displayName.isNotEmpty
          ? _displayName.split(' ').last[0].toUpperCase()
          : 'U';

  // Future<void> _handleLogout() async {
  //   final shouldLogout = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => Dialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  //       backgroundColor: Colors.white,
  //       child: Padding(
  //         padding: const EdgeInsets.all(24),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Container(
  //               width: 56,
  //               height: 56,
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFFFFEEEA),
  //                 borderRadius: BorderRadius.circular(16),
  //               ),
  //               child: const Icon(Icons.logout_rounded,
  //                   color: Color(0xFFFF4B4B), size: 28),
  //             ),
  //             const SizedBox(height: 16),
  //             const Text(
  //               'Đăng xuất?',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w800,
  //                 color: Color(0xFF1A1A2E),
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             const Text(
  //               'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 fontSize: 13,
  //                 color: Color(0xFF999999),
  //                 height: 1.5,
  //               ),
  //             ),
  //             const SizedBox(height: 24),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: GestureDetector(
  //                     onTap: () => Navigator.of(context).pop(false),
  //                     child: Container(
  //                       height: 46,
  //                       decoration: BoxDecoration(
  //                         color: const Color(0xFFF0F4FF),
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       child: const Center(
  //                         child: Text(
  //                           'Hủy',
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.w600,
  //                             color: Color(0xFF4F8EF7),
  //                             fontSize: 14,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 12),
  //                 Expanded(
  //                   child: GestureDetector(
  //                     onTap: () => Navigator.of(context).pop(true),
  //                     child: Container(
  //                       height: 46,
  //                       decoration: BoxDecoration(
  //                         color: const Color(0xFFFF4B4B),
  //                         borderRadius: BorderRadius.circular(12),
  //                         boxShadow: [
  //                           BoxShadow(
  //                             color: const Color(0xFFFF4B4B).withOpacity(0.3),
  //                             blurRadius: 10,
  //                             offset: const Offset(0, 4),
  //                           ),
  //                         ],
  //                       ),
  //                       child: const Center(
  //                         child: Text(
  //                           'Đăng xuất',
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.w700,
  //                             color: Colors.white,
  //                             fontSize: 14,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  //
  //   if (shouldLogout == true) {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.clear();
  //     await prefs.setBool('isLogin', false);
  //     if (context.mounted) context.go(AppRouterConfig.login);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Container(
        padding: EdgeInsets.only(top: 70),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header profile ─────────────────────────────────────
                // SliverToBoxAdapter(child: _buildProfileHeader()),

                // ── Stats ──────────────────────────────────────────────
                // SliverToBoxAdapter(
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                //     child: Row(
                //       children: [
                //         _StatChip(value: '12', label: 'Khóa học', color: const Color(0xFF4F8EF7)),
                //         const SizedBox(width: 12),
                //         _StatChip(value: '7', label: 'Ngày streak', color: const Color(0xFFFF6B35)),
                //         const SizedBox(width: 12),
                //         _StatChip(value: '1.2k', label: 'Điểm XP', color: const Color(0xFF00C48C)),
                //       ],
                //     ),
                //   ),
                // ),

                // ── Section: Tài khoản ─────────────────────────────────
                SliverToBoxAdapter(child: _SectionHeader(title: 'Tài khoản')),
                // const SizedBox(height: 10),b
                SliverToBoxAdapter(
                  child: _MenuGroup(
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        color: const Color(0xFF4F8EF7),
                        label: 'Chỉnh sửa thông tin cá nhân',
                        onTap: () {
                          context.push(CustomerRouterConfig.updateAccount);
                        },
                      ),
                      // _MenuItem(
                      //   icon: Icons.lock_outline_rounded,
                      //   color: const Color(0xFF7C5CFC),
                      //   label: 'Đổi mật khẩu',
                      //   onTap: () {
                      //     // context.push(AppRouterConfig.changePassword);
                      //   },
                      // ),
                      // _MenuItem(
                      //   icon: Icons.notifications_none_rounded,
                      //   color: const Color(0xFFFFBB00),
                      //   label: 'Thông báo',
                      //   // trailing: _Badge(label: '3'),
                      //   onTap: () {
                      //     // context.push(AppRouterConfig.notification);
                      //   },
                      // ),
                    ],
                  ),
                ),

                // ── Section: Học tập ───────────────────────────────────
                // SliverToBoxAdapter(
                //   child: _SectionHeader(title: 'Học tập'),
                // ),
                // SliverToBoxAdapter(
                //   child: _MenuGroup(items: [
                //     _MenuItem(
                //       icon: Icons.history_edu_rounded,
                //       color: const Color(0xFFFF6B35),
                //       label: 'Lịch sử học tập',
                //       onTap: () {},
                //     ),
                //     _MenuItem(
                //       icon: Icons.emoji_events_rounded,
                //       color: const Color(0xFFFFBB00),
                //       label: 'Thành tích & Huy hiệu',
                //       onTap: () {},
                //     ),
                //     _MenuItem(
                //       icon: Icons.bookmark_border_rounded,
                //       color: const Color(0xFF00C48C),
                //       label: 'Bài học đã lưu',
                //       onTap: () {},
                //     ),
                //   ]),
                // ),

                // ── Section: Hỗ trợ ───────────────────────────────────
                SliverToBoxAdapter(child: _SectionHeader(title: 'Hỗ trợ')),
                SliverToBoxAdapter(
                  child: _MenuGroup(
                    items: [
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        color: const Color(0xFF4F8EF7),
                        label: 'Trung tâm hỗ trợ',
                        onTap: () => _launchUrl(AppConfig.apiUrlSupport),
                      ),

                      _MenuItem(
                        icon: Icons.privacy_tip_outlined,
                        color: const Color(0xFF4F8EF7),
                        label: 'Chính sách và bảo mật',
                        onTap: () => _launchUrl(AppConfig.apiUrlPrivacyPolicy),
                      ),

                      _MenuItem(
                        icon: Icons.description_outlined,
                        color: const Color(0xFF4F8EF7),
                        label: 'Điều khoản sử dụng',
                        onTap: () => _launchUrl(AppConfig.apiUrlTerm),
                      ),
                      _MenuItem(
                        icon: Icons.info_outline_rounded,
                        color: const Color(0xFF7C5CFC),
                        label: 'Về ứng dụng',
                        trailing: const Text(
                          'v1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                // ── Nút đăng xuất ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    child: GestureDetector(
                      // onTap: _handleLogout,
                      onTap: _showConfirmLogout,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFF4B4B).withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFFF4B4B),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Đăng xuất',
                              style: TextStyle(
                                color: Color(0xFFFF4B4B),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    child: GestureDetector(
                      onTap: _showConfirmDeleteAccount,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFF4B4B).withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_circle,
                              color: Color(0xFFFF4B4B),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Xóa tài khoản',
                              style: TextStyle(
                                color: Color(0xFFFF4B4B),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F8EF7), Color(0xFF7C5CFC)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 24,
        right: 24,
        bottom: 32,
      ),
      child: Column(
        children: [
          // Avatar + name + email
          Row(
            children: [
              // Avatar
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38, width: 2.5),
                ),
                child: Center(
                  child: Text(
                    _avatarLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        roleDisplay,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Edit button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Reusable Widgets ───────────────────────────────────────────────────────────
//
// class _StatChip extends StatelessWidget {
//   final String value;
//   final String label;
//   final Color color;
//   const _StatChip({required this.value, required this.label, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 3),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 11,
//                 color: Color(0xFF999999),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFFAAAAAA),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              item,
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 56,
                  endIndent: 16,
                  color: Colors.grey.withOpacity(0.12),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.color,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.withOpacity(0.5),
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}
