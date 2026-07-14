import 'package:clean_water/data/configs/color_config.dart';
import 'package:flutter/material.dart';

class PolicyPublicTab extends StatelessWidget {
  const PolicyPublicTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Center(
      //     child: Text(
      //         "CHÍNH SÁCH BẢO MẬT \nTHÔNG TIN KHÁCH HÀNG",
      //       style: TextStyle(fontSize: 14, ),
      //     ),
      //   ),
      //   backgroundColor: ColorConfig.backgroundPrimary,
      // ),
      backgroundColor: ColorConfig.backgroundPrimary,
      body: Container(
        padding: EdgeInsets.only(top: 40, left: 10, right: 10),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Center(
                child: Text("CHÍNH SÁCH BẢO MẬT THÔNG TIN KHÁCH HÀNG",  style: TextStyle(fontSize: 18, ),),
              ),
              SizedBox(height: 24),

              _Title("1. Mục đích thu thập thông tin"),
              _Content(
                "Trung tâm Nước sạch TP. Thái Nguyên thu thập thông tin cá nhân của khách hàng (Hộ dân, Doanh nghiệp) nhằm mục đích:",
              ),
              _Bullet(
                "Cung cấp dịch vụ cấp nước sạch, quản lý chỉ số đồng hồ và tính toán hóa đơn hàng tháng.",
              ),
              _Bullet(
                "Thông báo tình trạng tạm dừng cấp nước, sửa chữa đường ống hoặc biến động giá nước.",
              ),
              _Bullet(
                "Hỗ trợ xử lý các khiếu nại, phản hồi về chất lượng nước và dịch vụ kỹ thuật.",
              ),

              SizedBox(height: 24),

              _Title("2. Phạm vi thu thập thông tin"),
              _Content(
                "Các thông tin cơ bản được lưu trữ trên hệ thống bao gồm:",
              ),
              _Bullet(
                "Thông tin định danh: Họ và tên chủ hộ, Số CMND/CCCD/Mã số thuế.",
              ),
              _Bullet(
                "Thông tin liên lạc: Số điện thoại, Địa chỉ lắp đặt đồng hồ, Email.",
              ),
              _Bullet(
                "Thông tin dịch vụ: Chỉ số tiêu thụ nước hàng kỳ, lịch sử thanh toán, loại đối tượng áp giá.",
              ),

              SizedBox(height: 24),

              _Title("3. Thời gian lưu trữ thông tin"),
              _Content(
                "Thông tin khách hàng sẽ được lưu trữ trong suốt quá trình sử dụng dịch vụ. "
                    "Dữ liệu lịch sử hóa đơn và chỉ số nước sẽ được lưu tối thiểu 05 năm để phục vụ tra soát.",
              ),

              SizedBox(height: 24),

              _Title("4. Cam kết bảo mật thông tin"),
              _Bullet(
                "Không bán, chia sẻ hay trao đổi thông tin cá nhân cho bên thứ ba vì mục đích thương mại.",
              ),
              _Bullet(
                "Sử dụng các biện pháp kỹ thuật để bảo vệ dữ liệu khỏi truy cập trái phép.",
              ),
              _Bullet(
                "Chỉ nhân viên được phân quyền mới được truy cập dữ liệu trong phạm vi công việc.",
              ),

              SizedBox(height: 24),

              _Title("5. Quyền lợi của khách hàng"),
              _Bullet(
                "Kiểm tra thông tin cá nhân và lịch sử sử dụng nước trên hệ thống.",
              ),
              _Bullet(
                "Yêu cầu cập nhật hoặc điều chỉnh thông tin nếu có sai sót.",
              ),

              SizedBox(height: 24),

              _Title("6. Thông tin liên hệ"),
              _Content("Trung tâm Nước sạch TP. Thái Nguyên"),
              _Content("Địa chỉ: TP. Thái Nguyên"),
              _Content("Hotline: 1900 xxxx"),
              _Content("Website: https://ttnuoc.beeio.top"),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;

  const _Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final String text;

  const _Content(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "•  ",
            style: TextStyle(fontSize: 15),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}