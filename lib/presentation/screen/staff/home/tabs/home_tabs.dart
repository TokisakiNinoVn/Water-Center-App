import 'dart:convert';
import 'package:clean_water/core/storage/index_storage.dart';
import 'package:clean_water/presentation/routers/configs/app_router_config.dart';
import 'package:clean_water/presentation/utils/logger_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _user;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final value = await SharedPrefsService.getValue(PrefType.string, 'user');
      if (value != null) {
        setState(() {
          _user = jsonDecode(value);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
      _animController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header với thông tin người dùng
              SliverToBoxAdapter(
                child: _buildUserHeader(),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
              // Các số liệu thống kê nhanh (tuỳ chọn)
              SliverToBoxAdapter(
                child: _buildQuickStats(),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
              // Danh sách menu chức năng
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildMenuItem(context, index),
                    childCount: _menuItems.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    if (_isLoading) {
      return Container(
        height: 180,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final name = _user?['name'] ?? 'Nhân viên';
    final avatarUrl = _user?['avatar'];
    final position = _user?['position'] ?? 'Nhân viên ghi số nước';
    final department = _user?['department'] ?? '';
    final greeting = _getGreeting();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl == null || avatarUrl.isEmpty
                ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            )
                : null,
          ),
          const SizedBox(width: 16),
          // Thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$position${department.isNotEmpty ? ' - $department' : ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    // Hiển thị nhanh số hộ đã ghi hôm nay, số còn lại...
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _statCard('Hôm nay', '12', 'hộ đã ghi', Colors.green),
          const SizedBox(width: 12),
          _statCard('Còn lại', '8', 'hộ chưa ghi', Colors.orange),
          const SizedBox(width: 12),
          _statCard('Tổng', '20', 'hộ phụ trách', Colors.blue),
        ],
      ),
    );
  }

  Widget _statCard(String title, String count, String subtitle, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, int index) {
    final item = _menuItems[index];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (item['route'] != null) {
            context.push(item['route']);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'],
                color: item['color'],
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item['title'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              item['subtitle'],
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Danh sách menu chức năng
  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.water_drop,
      'title': 'Ghi số nước',
      'subtitle': 'Cập nhật chỉ số mới',
      'color': Colors.blue,
      'route': AppRouterConfig.home,
    },
    {
      'icon': Icons.history,
      'title': 'Lịch sử ghi',
      'subtitle': 'Xem các lần ghi trước',
      'color': Colors.blue,
      'route': AppRouterConfig.home,
    },
    {
      'icon': Icons.people_alt,
      'title': 'Khách hàng',
      'subtitle': 'Danh sách hộ dân',
      'color': Colors.blue,
      'route': AppRouterConfig.home,
    },
    {
      'icon': Icons.pie_chart,
      'title': 'Thống kê',
      'subtitle': 'Báo cáo & biểu đồ',
      'color': Colors.blue,
      'route': AppRouterConfig.home,
    },
    {
      'icon': Icons.notifications_active,
      'title': 'Thông báo',
      'subtitle': 'Lịch ghi & nhắc nhở',
      'color': Colors.blue,
      'route': AppRouterConfig.home,
    },
    {
      'icon': Icons.settings,
      'title': 'Cài đặt',
      'subtitle': 'Tùy chỉnh ứng dụng',
      'color': Colors.blue,
      'route': AppRouterConfig.home,
    },
  ];
}