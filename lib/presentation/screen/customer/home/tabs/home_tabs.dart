import 'dart:convert';
import 'package:clean_water/core/storage/index_storage.dart';
import 'package:clean_water/presentation/routers/configs/app_router_config.dart';
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

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await SharedPrefsService.getValue(PrefType.string, 'user').then((value) {
      if (value != null) {
        setState(() => _user = jsonDecode(value));
      }
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String get _firstName {
    final name = _user?['name'] as String? ?? 'Học viên';
    return name.split(' ').last;
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
              SliverToBoxAdapter(child: _buildHero()),
              SliverToBoxAdapter(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  // ── HERO HEADER ─────────────────────────────────────────────────────────────

  Widget _buildHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A73E8), Color(0xFF0D47A1), Color(0xFF311B92)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar: greeting + notif + avatar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting 👋',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _firstName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Notification button
              _NotifButton(
                hasUnread: true,
                onTap: () {

                },
              ),
              const SizedBox(width: 10),
              // Avatar circle
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white38, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    _firstName.isNotEmpty ? _firstName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Hero intro banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Text('🇬🇧', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Học Tiếng Anh mỗi ngày',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Streak 7 ngày liên tiếp 🔥',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {/* TODO: navigate to today's lesson */},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Bắt đầu',
                      style: TextStyle(
                        color: Color(0xFF1A73E8),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Stats chips row
          Row(
            children: const [
              _StatChip(emoji: '🔥', value: '7', label: 'STREAK'),
              SizedBox(width: 8),
              _StatChip(emoji: '⭐', value: '1.240', label: 'XP'),
              SizedBox(width: 8),
              _StatChip(emoji: '📖', value: '84', label: 'TỪ VỰNG'),
              SizedBox(width: 8),
              _StatChip(emoji: '🏆', value: '3', label: 'HUY HIỆU'),
            ],
          ),
        ],
      ),
    );
  }

  // ── BODY ────────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skill categories
          _SectionHeader(title: 'Kỹ năng của bạn', onSeeAll: () {}),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: const [
                _SkillCard(
                  emoji: '🎧',
                  label: 'Nghe\nHiểu',
                  count: '24 bài',
                  startColor: Color(0xFF1A73E8),
                  endColor: Color(0xFF1557B0),
                ),
                _SkillCard(
                  emoji: '🗣️',
                  label: 'Nói &\nPhát Âm',
                  count: '18 bài',
                  startColor: Color(0xFF00897B),
                  endColor: Color(0xFF00574B),
                ),
                _SkillCard(
                  emoji: '✍️',
                  label: 'Viết\nLuận',
                  count: '12 bài',
                  startColor: Color(0xFFE53935),
                  endColor: Color(0xFFB71C1C),
                ),
                _SkillCard(
                  emoji: '📚',
                  label: 'Từ\nVựng',
                  count: '200+ từ',
                  startColor: Color(0xFFF57C00),
                  endColor: Color(0xFFBF360C),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Weekly progress
          _WeeklyProgressCard(progress: 0.62, completed: 5, total: 8),

          const SizedBox(height: 22),

          // Today's suggestions
          _SectionHeader(title: 'Gợi ý hôm nay', onSeeAll: () {}),
          const SizedBox(height: 12),
          const _LessonTile(
            emoji: '🎯',
            bgColor: Color(0xFFE3F2FD),
            title: 'IELTS Listening Practice',
            subtitle: '10 câu hỏi • ~20 phút',
            badgeText: '+50 XP',
            badgeBg: Color(0xFFE8F0FE),
            badgeColor: Color(0xFF1A73E8),
          ),
          const SizedBox(height: 10),
          const _LessonTile(
            emoji: '💬',
            bgColor: Color(0xFFE8F5E9),
            title: 'Daily Conversation',
            subtitle: 'AI Speaking • ~15 phút',
            badgeText: 'MỚI',
            badgeBg: Color(0xFFE8F5E9),
            badgeColor: Color(0xFF2E7D32),
          ),
          const SizedBox(height: 10),
          const _LessonTile(
            emoji: '🔤',
            bgColor: Color(0xFFFFF3E0),
            title: 'Phrasal Verbs - Set 5',
            subtitle: '15 từ • ~10 phút',
            badgeText: '🔥 HOT',
            badgeBg: Color(0xFFFFF3E0),
            badgeColor: Color(0xFFE65100),
          ),

          const SizedBox(height: 22),

          // AI ask bar
          GestureDetector(
            onTap: () {/* TODO: open AI chat */},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEDE7F6), Color(0xFFE8EAF6)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF7C4DFF).withOpacity(0.18),
                ),
              ),
              child: Row(
                children: const [
                  Text('✨', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 10),
                  Text(
                    'Hỏi AI về bất kỳ từ hoặc ngữ pháp nào...',
                    style: TextStyle(
                      color: Color(0xFF7C4DFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF7C4DFF), size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── NOTIFICATION BUTTON ───────────────────────────────────────────────────────

class _NotifButton extends StatelessWidget {
  final bool hasUnread;
  final VoidCallback onTap;
  const _NotifButton({required this.hasUnread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
              child: Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            if (hasUnread)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1A73E8), width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── STAT CHIP (in hero) ───────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _StatChip({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SECTION HEADER ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'Xem tất cả',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A73E8),
              ),
            ),
          ),
      ],
    );
  }
}

// ── SKILL CARD ────────────────────────────────────────────────────────────────

class _SkillCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String count;
  final Color startColor;
  final Color endColor;
  const _SkillCard({
    required this.emoji,
    required this.label,
    required this.count,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── WEEKLY PROGRESS CARD ──────────────────────────────────────────────────────

class _WeeklyProgressCard extends StatelessWidget {
  final double progress;
  final int completed;
  final int total;
  const _WeeklyProgressCard({
    required this.progress,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tiến độ tuần này',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A73E8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFEEF2FF),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hoàn thành $completed/$total bài hôm nay • Cố lên! 💪',
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── LESSON TILE ───────────────────────────────────────────────────────────────

class _LessonTile extends StatelessWidget {
  final String emoji;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeBg;
  final Color badgeColor;
  const _LessonTile({
    required this.emoji,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}