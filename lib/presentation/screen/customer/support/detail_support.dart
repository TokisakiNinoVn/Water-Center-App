import 'package:clean_water/data/configs/color_config.dart';
import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:clean_water/presentation/providers/customer/support_customer_provider.dart';
import 'package:clean_water/presentation/utils/logger_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailSupport extends StatefulWidget {
  final int id;
  const DetailSupport({super.key, required this.id});

  @override
  State<DetailSupport> createState() => _DetailSupportState();
}

class _DetailSupportState extends State<DetailSupport> {
  final SupportCustomerProvider _supportCustomerProvider =
  SupportCustomerProvider();

  bool isLoading = true;
  List<dynamic> messages = [];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => isLoading = true);

    final success = await _supportCustomerProvider.detailSupport(widget.id);

    if (!mounted) return;

    setState(() {
      isLoading = false;
      if (success) {
        messages = _supportCustomerProvider.detailSupportData ?? [];
      }
    });

    if (!success) {
      SnackBarHelper.showError(
        context,
        _supportCustomerProvider.errorMessage ?? "Có lỗi xảy ra",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(40),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Chi tiết phiếu hỗ trợ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : messages.isEmpty
          ? const Center(child: Text("Không có dữ liệu"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final isCustomer = msg['nguoi_gui_type'] == 'khach_hang';

          return Align(
            alignment: isCustomer
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isCustomer
                    ? const Color(0xFF2196F3)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên người gửi
                  Text(
                    msg['nguoi_gui']['ten'] ?? 'Người dùng',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isCustomer ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Nội dung
                  Text(
                    msg['noi_dung'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: isCustomer ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Thời gian
                  Text(
                    msg['created_at_format'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCustomer ? Colors.white60 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}