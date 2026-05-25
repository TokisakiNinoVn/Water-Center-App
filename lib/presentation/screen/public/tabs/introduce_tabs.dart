import 'package:clean_water/data/configs/app_config.dart';
import 'package:flutter/material.dart';
import 'package:clean_water/data/configs/color_config.dart';

class IntroducePublicTab extends StatelessWidget {
  const IntroducePublicTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Giới thiệu', style: TextStyle(color: Colors.white),),
      //   backgroundColor: ColorConfig.primary,
      // ),
      backgroundColor: ColorConfig.backgroundPrimary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),

            Center(
              child: Text("Giới thiệu", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
            ),
            SizedBox(height: 20),
            _Title('Tổng quan về Trung tâm Nước sạch'),
            _Content('Trung tâm Nước sạch TP. Thái Nguyên cung cấp dịch vụ cấp nước sạch, quản lý chỉ số đồng hồ và tính toán hóa đơn hàng tháng cho hộ dân và doanh nghiệp.'),
            SizedBox(height: 24),
            _Title('Tầm nhìn & Sứ mệnh'),
            _Content('Tầm nhìn: Trở thành mô hình cung cấp nước sạch hiện đại, bền vững và an toàn nhất khu vực.'),
            _Content('Sứ mệnh: Đảm bảo nguồn nước sạch, ổn định cho mọi khách hàng, đồng thời nâng cao nhận thức về tiêu dùng nước hợp lý.'),
            SizedBox(height: 24),
            _Title('Giá trị cốt lõi'),
            _Bullet('Chất lượng - Cam kết cung cấp nước sạch đạt tiêu chuẩn.'),
            _Bullet('Tin cậy - Độ tin cậy cao trong cung cấp dịch vụ.'),
            _Bullet('Đổi mới - Áp dụng công nghệ mới để tối ưu hoá hệ thống.'),
            SizedBox(height: 24),
            _Title('Lĩnh vực hoạt động'),
            _Bullet('Cấp nước sinh hoạt cho hộ dân và doanh nghiệp.'),
            _Bullet('Quản lý hệ thống đo lường, thu phí và thanh toán.'),
            _Bullet('Tư vấn, thiết kế và lắp đặt hệ thống cấp nước.'),
            const SizedBox(height: 130),

          ],
        ),
      ),
    );
  }
}

// Helper widgets – reusable styling
class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: ColorConfig.textBlack,
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final String text;
  const _Content(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: ColorConfig.textBlack,
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 15)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: ColorConfig.textBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}