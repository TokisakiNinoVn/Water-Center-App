import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPublicTab extends StatefulWidget {
  const SupportPublicTab({super.key});

  @override
  State<SupportPublicTab> createState() => _SupportPublicTabState();
}

class _SupportPublicTabState extends State<SupportPublicTab> {
  int? _expandedFaq;

  final List<_FaqItem> _faqs = [
    _FaqItem(
      q: 'Làm thế nào để đăng ký lắp đặt đồng hồ nước mới?',
      a: 'Quý khách mang CMND/CCCD và giấy tờ nhà đất đến văn phòng Trung tâm nước gần nhất, hoặc gọi hotline 1800 599 927 để được hướng dẫn đăng ký trực tuyến. Thời gian xử lý từ 3–5 ngày làm việc.',
    ),
    _FaqItem(
      q: 'Tôi bị mất nước đột ngột, phải làm gì?',
      a: 'Kiểm tra van tổng trong nhà trước. Nếu van đang mở bình thường, vui lòng gọi ngay đường dây sự cố 24/7: 1800 599 927 để được hỗ trợ khẩn cấp. Kỹ thuật viên sẽ đến trong vòng 2 giờ.',
    ),
    _FaqItem(
      q: 'Hóa đơn nước của tôi tăng đột biến, nguyên nhân là gì?',
      a: 'Có thể do rò rỉ nước ngầm trong hệ thống ống nội bộ, vòi nước hoặc bồn cầu bị xì. Quý khách kiểm tra đồng hồ lúc 0–2 giờ đêm khi không dùng nước – nếu kim vẫn quay thì có rò rỉ. Liên hệ kỹ thuật để được kiểm tra miễn phí.',
    ),
    _FaqItem(
      q: 'Thanh toán hóa đơn nước bằng những cách nào?',
      a: 'Quý khách có thể thanh toán qua: ứng dụng Trung tâm nước, Internet Banking, MoMo, VNPay, ZaloPay, tại văn phòng giao dịch hoặc các điểm thu hộ ủy quyền trên toàn tỉnh.',
    ),
    _FaqItem(
      q: 'Khi nào tôi nhận được hóa đơn nước hàng tháng?',
      a: 'Nhân viên ghi chỉ số đồng hồ vào ngày cố định hàng tháng (từ ngày 1–10). Hóa đơn điện tử gửi qua email/SMS ngay sau đó. Thời hạn thanh toán là 15 ngày kể từ ngày xuất hóa đơn.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0A1628) : const Color(0xFFF0F6FF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(isDark)),
            SliverToBoxAdapter(child: _buildHotline(isDark)),
            SliverToBoxAdapter(child: _buildQuickActions(isDark)),
            SliverToBoxAdapter(child: _buildFaqSection(isDark)),
            SliverToBoxAdapter(child: _buildOfficeSection(isDark)),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF0D1F3C) : Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
            child: const Icon(Icons.support_agent_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hỗ trợ khách hàng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0D1F3C),
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Luôn sẵn sàng hỗ trợ bạn 24/7',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : const Color(0xFF78909C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotline(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () => _launchPhone('1800599927'),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF0277BD)],
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
                right: -10,
                top: -10,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_in_talk_rounded,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đường dây hỗ trợ miễn phí',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            '1800 599 927',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hoạt động 24/7 · Miễn phí cuộc gọi',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Gọi ngay',
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    final actions = [
      _QuickAction(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Chat trực\ntuyến',
        color: const Color(0xFF00897B),
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.email_outlined,
        label: 'Gửi\nemail',
        color: const Color(0xFF1565C0),
        onTap: () => _launchEmail(),
      ),
      _QuickAction(
        icon: Icons.report_problem_outlined,
        label: 'Báo sự\ncố',
        color: const Color(0xFFE65100),
        onTap: () => _showReportDialog(),
      ),
      _QuickAction(
        icon: Icons.feedback_outlined,
        label: 'Góp ý\nkhiếu nại',
        color: const Color(0xFF6A1B9A),
        onTap: () {},
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Liên hệ nhanh', isDark),
          const SizedBox(height: 12),
          Row(
            children: actions
                .map(
                  (a) => Expanded(
                child: GestureDetector(
                  onTap: a.onTap,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF132040)
                          : Colors.white,
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
                          color: const Color(0xFF1565C0)
                              .withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: a.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(a.icon, color: a.color, size: 20),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF37474F),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Câu hỏi thường gặp', isDark),
          const SizedBox(height: 12),
          ...List.generate(_faqs.length, (i) {
            final isOpen = _expandedFaq == i;
            return GestureDetector(
              onTap: () =>
                  setState(() => _expandedFaq = isOpen ? null : i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isOpen
                      ? (isDark
                      ? const Color(0xFF1A3060)
                      : const Color(0xFFE3F2FD))
                      : (isDark
                      ? const Color(0xFF132040)
                      : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isOpen
                        ? const Color(0xFF1565C0).withOpacity(0.4)
                        : (isDark
                        ? Colors.white.withOpacity(0.06)
                        : const Color(0xFFE3F2FD)),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isOpen
                                  ? const Color(0xFF1565C0)
                                  : const Color(0xFF1565C0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isOpen
                                      ? Colors.white
                                      : const Color(0xFF1565C0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _faqs[i].q,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0D1F3C),
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: isOpen ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: isOpen
                                  ? const Color(0xFF1565C0)
                                  : (isDark
                                  ? Colors.white38
                                  : const Color(0xFFB0BEC5)),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      if (isOpen) ...[
                        const SizedBox(height: 10),
                        Divider(
                          color: const Color(0xFF1565C0).withOpacity(0.2),
                          height: 1,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _faqs[i].a,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF37474F),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOfficeSection(bool isDark) {
    final offices = [
      _Office(
        name: 'Văn phòng chính – TP. Thái Nguyên',
        address: '18 Đường Lương Ngọc Quyến, P. Quang Trung, TP. Thái Nguyên',
        hours: 'T2–T6: 7:30–11:30 · 13:30–17:00',
        icon: Icons.location_city_rounded,
        color: const Color(0xFF1565C0),
      ),
      _Office(
        name: 'Chi nhánh Sông Công',
        address: 'Số 5 Đường Phố Mới, TP. Sông Công, Thái Nguyên',
        hours: 'T2–T6: 7:30–11:30 · 13:30–17:00',
        icon: Icons.store_rounded,
        color: const Color(0xFF00897B),
      ),
      _Office(
        name: 'Chi nhánh Phổ Yên',
        address: 'Tổ 7 Phường Bãi Bông, TX. Phổ Yên, Thái Nguyên',
        hours: 'T2–T6: 7:30–11:30 · 13:30–17:00',
        icon: Icons.store_rounded,
        color: const Color(0xFF00897B),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Văn phòng giao dịch', isDark),
          const SizedBox(height: 12),
          ...offices.map((o) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF132040) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : const Color(0xFFE3F2FD),
              ),
              boxShadow: isDark
                  ? []
                  : [
                BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: o.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(o.icon, color: o.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0D1F3C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.place_outlined,
                              size: 12,
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFFB0BEC5)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              o.address,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF78909C),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 12,
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFFB0BEC5)),
                          const SizedBox(width: 3),
                          Text(
                            o.hours,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF78909C),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {},
                  icon: Icon(Icons.directions_rounded,
                      color: o.color, size: 20),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0D1F3C),
          ),
        ),
      ],
    );
  }

  void _launchPhone(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  void _launchEmail() async {
    final uri =
    Uri.parse('mailto:hotro@trungtamnuoc.vn?subject=Hỗ trợ khách hàng');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  void _showReportDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ReportSheet(),
    );
  }
}

// ── Report bottom sheet ──────────────────────────────────────────────────────

class _ReportSheet extends StatefulWidget {
  const _ReportSheet();

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _ctrl = TextEditingController();
  int _selectedType = 0;
  bool _submitted = false;

  final _types = ['Mất nước', 'Nước đục/bẩn', 'Rò rỉ ống', 'Đồng hồ hỏng', 'Khác'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1F3C) : Colors.white,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: _submitted ? _buildSuccess(isDark) : _buildForm(isDark),
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE65100).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.report_problem_outlined,
                  color: Color(0xFFE65100), size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Báo sự cố',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0D1F3C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text('Loại sự cố',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF37474F))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_types.length, (i) {
            final sel = i == _selectedType;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel
                      ? const Color(0xFFE65100)
                      : (isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFF5F5F5)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel
                        ? const Color(0xFFE65100)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  _types[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: sel
                        ? Colors.white
                        : (isDark ? Colors.white60 : const Color(0xFF546E7A)),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text('Mô tả chi tiết',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF37474F))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : const Color(0xFFE0E0E0),
            ),
          ),
          child: TextField(
            controller: _ctrl,
            maxLines: 3,
            style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF0D1F3C)),
            decoration: InputDecoration(
              hintText: 'Mô tả sự cố bạn đang gặp phải...',
              hintStyle: TextStyle(
                  color: isDark ? Colors.white30 : const Color(0xFFB0BEC5),
                  fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _submitted = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text('Gửi báo cáo',
                style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF00897B).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline_rounded,
              color: Color(0xFF00897B), size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          'Đã gửi báo cáo thành công!',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0D1F3C),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kỹ thuật viên sẽ liên hệ với bạn\ntrong vòng 2 giờ làm việc.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: isDark ? Colors.white54 : const Color(0xFF78909C),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng',
              style: TextStyle(
                  color: Color(0xFF1565C0), fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _FaqItem {
  final String q, a;
  const _FaqItem({required this.q, required this.a});
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
        required this.label,
        required this.color,
        required this.onTap});
}

class _Office {
  final String name, address, hours;
  final IconData icon;
  final Color color;
  const _Office(
      {required this.name,
        required this.address,
        required this.hours,
        required this.icon,
        required this.color});
}