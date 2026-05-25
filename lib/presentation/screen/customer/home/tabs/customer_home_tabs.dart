import 'package:clean_water/data/configs/color_config.dart';
import 'package:clean_water/data/configs/menu_home_tab_customer.dart';
import 'package:clean_water/data/configs/menu_home_tab_staff.dart';
import 'package:clean_water/presentation/providers/staff/account_provider.dart';
import 'package:clean_water/presentation/routers/configs/app_router_config.dart';
import 'package:clean_water/presentation/utils/logger_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/storage/index_storage.dart';

class HomeTabCustomer extends StatefulWidget {
  const HomeTabCustomer({super.key});

  @override
  State<HomeTabCustomer> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTabCustomer> with TickerProviderStateMixin {
  Map<String, dynamic>? _user;
  late AnimationController _animController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _pulseAnim;
  bool _isLoading = true;
  bool isLogin = false;

  // Design tokens
  static const _gradientStart = Color(0xFF0D47A1);
  static const _gradientMid = Color(0xFF1565C0);
  static const _gradientEnd = Color(0xFF1E88E5);
  static const _bgColor = Color(0xFFF0F4FF);
  static const _cardColor = Colors.white;
  static const _accentTeal = Color(0xFF00ACC1);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initData();
  }

  Future<void> _initData() async {
    await _loadLogin();

    if (isLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadUserData();
      });
    }
  }

  Future<void> _loadLogin() async {
    isLogin = await SharedPrefsService.getValue(
      PrefType.bool,
      "isLogin",
    );
  }

  /// Tải thông tin người dùng từ Provider (không qua local storage)
  Future<void> _loadUserData() async {
    final provider = context.read<AccountProvider>();
    final success = await provider.loadInformationAccount();

    // if (success && mounted) {
    //   setState(() {
    //     _user = provider.accountResponse?.data["user"];
    //     appLog("$_user");
    //     _isLoading = false;
    //   });
    // }
    if (success && mounted) {
      setState(() {
        _user = provider.accountResponse?.data?["user"];
        // appLog("$_user");

        _isLoading = false;
      });
    }

    else if (mounted) {
      setState(() => _isLoading = false);
    }

    if (mounted) {
      _animController.forward();
    }
  }

  /// Hàm làm mới khi kéo xuống
  Future<void> _onRefresh() async {
    await _loadUserData();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 18) return '🌤️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConfig.backgroundPrimary,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: ColorConfig.primary,
        // color: _gradientEnd,
        // backgroundColor: Colors.white,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                // SliverToBoxAdapter(child: _buildQuickStats()),
                // const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(child: _buildSectionTitle('Chức năng')),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildMenuItem(context, index),
                      childCount: menuHomeCustomerItems.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 30),
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_gradientStart, _gradientMid, _gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: _gradientMid.withOpacity(0.38),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 80,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: _isLoading
                ? const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
                : _buildHeaderContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent() {
    final name = _user?['name'] ?? 'Khách hàng';
    final avatarUrl = _user?['avatar'];
    final position = _user?['position'] ?? 'Khách hàng';
    final roleUser = _user?['role'] ?? 'khach_hang';
    final roleDisplay = roleUser == 'khach_hang' ? 'Khách hàng' : 'Khách hàng';
    final greeting = _getGreeting();
    final emoji = _getGreetingEmoji();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar với viền glow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withOpacity(0.15),
                backgroundImage: NetworkImage(
                  (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? avatarUrl
                      : "https://i.pinimg.com/736x/0d/be/82/0dbe825dcbbbb1a041a688c4e282b324.jpg",
                ),
                onBackgroundImageError: (_, __) {},
                child: null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting $emoji',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Role badge hiển thị position
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                roleDisplay,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Divider
        Container(
          height: 1,
          color: Colors.white.withOpacity(0.15),
        ),
        const SizedBox(height: 16),
        // Date info row
        Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(
              _formatDate(DateTime.now()),
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            // Online indicator
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF69F0AE),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Đang hoạt động',
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
    final dayName = days[date.weekday - 1];
    return '$dayName, ${date.day}/${date.month}/${date.year}';
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: _gradientEnd,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A237E),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      _StatData('Đã ghi', '12', 'hộ hôm nay', const Color(0xFF1565C0), Icons.check_circle_outline_rounded),
      _StatData('Còn lại', '8', 'hộ chưa ghi', const Color(0xFFE53935), Icons.pending_outlined),
      _StatData('Tổng', '20', 'hộ phụ trách', const Color(0xFF2E7D32), Icons.home_outlined),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: Color(0xFF1565C0), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Thống kê hôm nay',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1A237E),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '60% hoàn thành',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: 7,
              backgroundColor: const Color(0xFFE3F2FD),
              valueColor: const AlwaysStoppedAnimation<Color>(_gradientEnd),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: stats.map((s) => _buildStatItem(s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(_StatData data) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            data.count,
            style: TextStyle(
              color: data.color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            data.sub,
            style: const TextStyle(
              color: Color(0xFFBDBDBD),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, int index) {
    final item = menuHomeCustomerItems[index];
    final color = item['color'] as Color;

    return Material(
      color: _cardColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () {
          if (item['route'] != null) {
            context.push(item['route']);
          }
        },
        borderRadius: BorderRadius.circular(22),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon with colored bg
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item['icon'], color: color, size: 26),
                ),
                // Text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A237E),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                // Arrow indicator
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: color,
                      size: 14,
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
}

class _StatData {
  final String label;
  final String count;
  final String sub;
  final Color color;
  final IconData icon;

  const _StatData(this.label, this.count, this.sub, this.color, this.icon);
}