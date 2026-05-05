import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routers/configs/app_router_config.dart';

class SecondStartScreen extends StatelessWidget {
  const SecondStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Dùng nền trắng thuần để làm nổi bật các thành phần đồ họa
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black54, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push(AppRouterConfig.gettingStartedThird),
            child: const Text(
              "Tiếp theo",
              style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Phần minh họa: Sử dụng một Container trang trí khác màn hình 1
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Các vòng tròn trang trí phía sau
                    Positioned(
                      top: 40,
                      left: 20,
                      child: _buildDecorativeCircle(40, Colors.orange.withOpacity(0.2)),
                    ),
                    Positioned(
                      bottom: 60,
                      right: 30,
                      child: _buildDecorativeCircle(60, Colors.purple.withOpacity(0.1)),
                    ),

                    // Icon chính: Đại diện cho sự tương tác/chat
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_motion_rounded, // Hoặc Icons.chat_bubble_outline
                        size: 140,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Nội dung văn bản
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              child: Column(
                children: [
                  const Text(
                    "Trợ lý học tập 24/7",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Giải đáp mọi thắc mắc, tóm tắt bài giảng và luyện tập cùng bạn bất cứ khi nào bạn cần.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey[400],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Chỉ báo tiến trình (Dots indicator - Giả lập)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(false),
                _buildDot(true), // Active ở màn hình 2
                _buildDot(false),
              ],
            ),

            const SizedBox(height: 40),

            // Nút điều hướng chính
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Quay lại", style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => context.push(AppRouterConfig.gettingStartedThird),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D3142), // Đổi tone màu đậm hơn cho chuyên nghiệp
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        "Tiếp theo",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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

  // Widget phụ trợ để vẽ các chấm indicator
  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.blueAccent : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Widget phụ trợ vẽ vòng tròn trang trí
  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}