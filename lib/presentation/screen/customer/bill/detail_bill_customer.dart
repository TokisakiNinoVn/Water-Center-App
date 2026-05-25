import 'dart:convert';
import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:clean_water/presentation/providers/customer/bill_customer_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clean_water/data/services/bill_service.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';

class DetailsBillCustomer extends StatefulWidget {
  final int id;
  const DetailsBillCustomer({
    super.key,
    required this.id
  });

  @override
  State<DetailsBillCustomer> createState() => _DetailsBillCustomerState();
}

class _DetailsBillCustomerState extends State<DetailsBillCustomer> {

  @override
  void initState() {
    super.initState();
    appLog("id bill: ${widget.id}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadBillDetails();
    });
  }

  Future<void> _loadBillDetails() async {
    final provider = context.read<BillCustomerProvider>();
    final success = await provider.loadDetailsBillCustomer(widget.id);
    if (!success && mounted) {
      SnackBarHelper.showError(context, provider.errorMessage ?? 'Lỗi tải chi tiết hóa đơn');
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'chua_thanh_toan':
        return 'Chưa thanh toán';
      case 'da_thanh_toan':
        return 'Đã thanh toán';
      case 'qua_han':
        return 'Quá hạn';
      default:
        return status ?? 'Không xác định';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'chua_thanh_toan':
        return Colors.orange;
      case 'da_thanh_toan':
        return Colors.green;
      case 'qua_han':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
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
              "Chi tiết hóa đơn",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
      body: Consumer<BillCustomerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDetails) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(provider.errorMessage!),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadBillDetails,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final data = provider.detailsBills;
          if (data.isEmpty) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          // Lấy các object con
          final bill = data;
          final customer = bill['khach_hang'] as Map<String, dynamic>? ?? {};
          final meter = bill['dong_ho'] as Map<String, dynamic>? ?? {};
          final history = bill['lich_su'] as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin hóa đơn
                _buildSection('Thông tin hóa đơn', [
                  _infoRow('Mã hóa đơn', bill['ma_hoa_don']),
                  _infoRow('Kỳ', bill['ky']),
                  _infoRow('Ngày lập', FormatHelper.formatDateTime(bill['ngay_lap'])),
                  _infoRow('Trạng thái',
                      _getStatusText(bill['trang_thai']),
                      color: _getStatusColor(bill['trang_thai'])),
                  _infoRow('Ngày thanh toán',
                      bill['ngay_thanh_toan'] != null
                          ? FormatHelper.formatDateTime(bill['ngay_thanh_toan'])
                          : 'Chưa thanh toán'),
                ]),

                const SizedBox(height: 20),

                // Chỉ số nước
                _buildSection('Chỉ số nước', [
                  _infoRow('Chỉ số đầu', '${bill['chi_so_dau']} m³'),
                  _infoRow('Chỉ số cuối', '${bill['chi_so_cuoi']} m³'),
                  _infoRow('Lượng tiêu thụ', '${bill['luong_tieu_thu']} m³'),
                  _infoRow('Ngày ghi chỉ số', FormatHelper.formatDateTime(history['ngay_ghi'])),
                ]),

                const SizedBox(height: 20),

                // Thông tin khách hàng
                _buildSection('Thông tin khách hàng', [
                  _infoRow('Mã KH', customer['ma_khach_hang']),
                  _infoRow('Tên khách hàng', customer['ten_khach_hang']),
                  _infoRow('Số điện thoại', customer['so_dien_thoai']),
                  _infoRow('Email', customer['email']),
                  _infoRow('Địa chỉ', customer['dia_chi']),
                ]),

                const SizedBox(height: 20),

                // Thông tin đồng hồ
                _buildSection('Thông tin đồng hồ', [
                  _infoRow('Mã đồng hồ', meter['ma_dong_ho']),
                  _infoRow('Seri', meter['seri']),
                  _infoRow('Hãng sản xuất', meter['hang_sx']),
                  _infoRow('Ngày lắp đặt', FormatHelper.formatDateTime(meter['ngay_lap_dat'])),
                  _infoRow('Trạng thái', meter['trang_thai'] == 'hoat_dong'
                      ? 'Hoạt động'
                      : 'Không hoạt động'),
                ]),

                const SizedBox(height: 20),

                // Chi phí
                _buildSection('Chi tiết chi phí', [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tiền nước',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        // FormatHelper.formatPrice(bill['tong_tien']),

                        FormatHelper.formatPrice(
                          (double.tryParse(bill['tong_tien'].toString()) ?? 0).toInt(),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Phí bảo vệ môi trường'),
                      Text('${bill['bvmt'] ?? 0} ₫'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Thuế VAT'),
                      Text(FormatHelper.formatPrice(bill['vat'])),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        // FormatHelper.formatPrice(bill['tong_tien']),
                        FormatHelper.formatPrice(
                          (double.tryParse(bill['tong_tien'].toString()) ?? 0).toInt(),
                        ),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue),
                      ),
                    ],
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '--',
              style: TextStyle(color: color ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}