import 'package:flutter/material.dart';

class NewsItem {
  final String id;
  final String category;
  final String title;
  final String summary;
  final String date;
  final String readTime;
  final bool isHot;
  final Color categoryColor;

  const NewsItem({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.date,
    required this.readTime,
    this.isHot = false,
    required this.categoryColor,
  });
}

class NewPublicTab extends StatefulWidget {
  const NewPublicTab({super.key});

  @override
  State<NewPublicTab> createState() => _NewPublicTabState();
}

class _NewPublicTabState extends State<NewPublicTab>
    with SingleTickerProviderStateMixin {
  int _selectedCategory = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final List<String> _categories = [
    'Tất cả',
    'Thông báo',
    'Khuyến mãi',
    'Bảo trì',
    'Hướng dẫn',
  ];

  final List<NewsItem> _allNews = [
    NewsItem(
      id: '1',
      category: 'Thông báo',
      title: 'Lịch cấp nước tháng 6/2025 – Khu vực nội thành',
      summary:
      'Trung tâm nước thông báo lịch cấp nước định kỳ tháng 6 cho toàn bộ khu vực nội thành. Quý khách vui lòng chuẩn bị dự trữ nước trước 22:00.',
      date: '12/05/2025',
      readTime: '3 phút',
      isHot: true,
      categoryColor: Color(0xFF1565C0),
    ),
    NewsItem(
      id: '2',
      category: 'Khuyến mãi',
      title: 'Ưu đãi giảm 20% khi thanh toán hóa đơn qua app',
      summary:
      'Từ ngày 01/06 đến 30/06/2025, khách hàng thanh toán hóa đơn nước qua ứng dụng được giảm ngay 20% cho hóa đơn tháng đầu tiên.',
      date: '10/05/2025',
      readTime: '2 phút',
      isHot: true,
      categoryColor: Color(0xFF00897B),
    ),
    NewsItem(
      id: '3',
      category: 'Bảo trì',
      title: 'Tạm ngừng cấp nước khu vực Phường Đồng Quang ngày 15/05',
      summary:
      'Do công tác bảo trì và nâng cấp hệ thống đường ống, nước sẽ bị tạm ngừng cung cấp từ 8:00 đến 17:00 ngày 15/05/2025.',
      date: '09/05/2025',
      readTime: '2 phút',
      isHot: false,
      categoryColor: Color(0xFFE65100),
    ),
    NewsItem(
      id: '4',
      category: 'Hướng dẫn',
      title: 'Cách đọc chỉ số đồng hồ nước và kiểm tra rò rỉ tại nhà',
      summary:
      'Hướng dẫn chi tiết cách đọc đồng hồ nước, phát hiện rò rỉ sớm và tiết kiệm nước sinh hoạt hiệu quả cho gia đình bạn.',
      date: '07/05/2025',
      readTime: '5 phút',
      isHot: false,
      categoryColor: Color(0xFF6A1B9A),
    ),
    NewsItem(
      id: '5',
      category: 'Thông báo',
      title: 'Thay đổi giá nước sinh hoạt áp dụng từ 01/07/2025',
      summary:
      'Theo quyết định của UBND tỉnh, giá nước sinh hoạt sẽ được điều chỉnh theo lộ trình tăng giá mới áp dụng từ ngày 01/07/2025.',
      date: '05/05/2025',
      readTime: '4 phút',
      isHot: false,
      categoryColor: Color(0xFF1565C0),
    ),
    NewsItem(
      id: '6',
      category: 'Hướng dẫn',
      title: 'Quy trình đăng ký lắp đặt đồng hồ nước mới năm 2025',
      summary:
      'Hướng dẫn đầy đủ các bước thủ tục đăng ký lắp mới hoặc di dời đồng hồ nước, hồ sơ cần chuẩn bị và thời gian xử lý dự kiến.',
      date: '03/05/2025',
      readTime: '6 phút',
      isHot: false,
      categoryColor: Color(0xFF6A1B9A),
    ),
  ];

  List<NewsItem> get _filteredNews {
    if (_selectedCategory == 0) return _allNews;
    final cat = _categories[_selectedCategory];
    return _allNews.where((n) => n.category == cat).toList();
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _switchCategory(int idx) {
    setState(() => _selectedCategory = idx);
    _fadeController.reset();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1628) : const Color(0xFFF0F6FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            _buildCategoryFilter(isDark),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _filteredNews.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: _filteredNews.length,
                  itemBuilder: (ctx, i) {
                    final item = _filteredNews[i];
                    if (i == 0 && _selectedCategory == 0) {
                      return _buildFeaturedCard(item, isDark);
                    }
                    return _buildNewsCard(item, isDark);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1F3C) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.water_drop_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tin tức & Thông báo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0D1F3C),
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Trung tâm nước Thái Nguyên',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : const Color(0xFF78909C),
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF0D1F3C) : Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: List.generate(_categories.length, (i) {
            final isSelected = i == _selectedCategory;
            return GestureDetector(
              onTap: () => _switchCategory(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 8),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1565C0)
                      : (isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFF0F6FF)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1565C0)
                        : (isDark
                        ? Colors.white.withOpacity(0.12)
                        : const Color(0xFFBBDEFB)),
                  ),
                ),
                child: Text(
                  _categories[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                        ? Colors.white60
                        : const Color(0xFF546E7A)),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(NewsItem item, bool isDark) {
    return GestureDetector(
      onTap: () => _showDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, top: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department_rounded,
                                color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            const Text(
                              'Nổi bật',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.summary,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 13, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        item.date,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time_rounded,
                          size: 13, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        'Đọc ${item.readTime}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Xem ngay',
                          style: TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(NewsItem item, bool isDark) {
    return GestureDetector(
      onTap: () => _showDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF132040) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : const Color(0xFFE3F2FD),
          ),
          boxShadow: isDark
              ? []
              : [
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.categoryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _categoryIcon(item.category),
                color: item.categoryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            color: item.categoryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (item.isHot) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department_rounded,
                                  color: Colors.red, size: 10),
                              SizedBox(width: 2),
                              Text(
                                'HOT',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0D1F3C),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.summary,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : const Color(0xFF78909C),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 11,
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFFB0BEC5)),
                      const SizedBox(width: 4),
                      Text(
                        item.date,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFFB0BEC5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_rounded,
                          size: 11,
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFFB0BEC5)),
                      const SizedBox(width: 4),
                      Text(
                        item.readTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFFB0BEC5),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: isDark
                              ? Colors.white24
                              : const Color(0xFFCFD8DC)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined,
              size: 60, color: Colors.blue.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            'Chưa có tin tức nào',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Thông báo':
        return Icons.campaign_rounded;
      case 'Khuyến mãi':
        return Icons.local_offer_rounded;
      case 'Bảo trì':
        return Icons.build_rounded;
      case 'Hướng dẫn':
        return Icons.menu_book_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  void _showDetail(NewsItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewsDetailSheet(item: item),
    );
  }
}

class _NewsDetailSheet extends StatelessWidget {
  final NewsItem item;
  const _NewsDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1F3C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: item.categoryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            color: item.categoryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0D1F3C),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(item.date,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time_rounded,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text('Đọc ${item.readTime}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.withOpacity(0.15)),
                  const SizedBox(height: 16),
                  Text(
                    item.summary,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.7,
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF37474F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quý khách hàng vui lòng chú ý theo dõi thông báo và chủ động dự trữ nước sinh hoạt theo hướng dẫn. Mọi thắc mắc và yêu cầu hỗ trợ, xin liên hệ đường dây nóng của Trung tâm nước để được giải đáp kịp thời.\n\nTrân trọng cảm ơn quý khách hàng đã tin tưởng và sử dụng dịch vụ của chúng tôi.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.7,
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF37474F),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFF1565C0).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_rounded,
                            color: Color(0xFF1565C0), size: 20),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Đường dây hỗ trợ 24/7',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              '1800 599 927',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}