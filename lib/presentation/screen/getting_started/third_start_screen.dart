import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routers/configs/app_router_config.dart';

class ThirdStartScreen extends StatelessWidget {
  const ThirdStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background trang trí (phần bo tròn phía trên)
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Icon lớn làm điểm nhấn cuối cùng
                const Center(
                  child: Icon(
                    Icons.rocket_launch_rounded, // Biểu tượng cho sự bứt phá
                    size: 120,
                    color: Colors.blueAccent,
                  ),
                ),

                const SizedBox(height: 40),

                // Nội dung kêu gọi hành động
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        "Sẵn sàng bứt phá?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Gia nhập cộng đồng eduAI ngay hôm nay để trải nghiệm phương pháp học tập thông minh nhất.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Phần Buttons - Nơi người dùng đưa ra quyết định
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Column(
                    children: [
                      // Nút Đăng nhập (Chính)
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () => context.go(AppRouterConfig.login),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                            shadowColor: Colors.blueAccent.withOpacity(0.4),
                          ),
                          child: const Text(
                            "Đăng nhập / Đăng ký",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Nút Vào thẳng Home (Phụ)
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: TextButton(
                          onPressed: () => context.go(AppRouterConfig.home),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.blueAccent, width: 1.5),
                            ),
                          ),
                          child: const Text(
                            "Trải nghiệm ngay",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Chỉ báo Dots (Màn cuối)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDot(false),
                          _buildDot(false),
                          _buildDot(true),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nút Back nhỏ ở góc trên trái
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black54),
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.blueAccent : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}