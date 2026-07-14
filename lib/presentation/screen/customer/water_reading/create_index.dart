import 'dart:io';

import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:clean_water/presentation/providers/customer/water_index_customer_provider.dart';
import 'package:clean_water/presentation/screen/widgets/full_sreen_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'package:clean_water/presentation/providers/staff/water_index_provider.dart';
import 'package:clean_water/presentation/utils/logger_utils.dart';

class CreateIndexCustomer extends StatefulWidget {
  final Map<String, dynamic> data;
  const CreateIndexCustomer({
    super.key,
    required this.data,
  });

  @override
  State<CreateIndexCustomer> createState() => _CreateIndexScreenState();
}

class _CreateIndexScreenState extends State<CreateIndexCustomer> {
  bool _isLoading = false;
  bool _isSubmitting = false;
  List<dynamic> _historyList = [];
  Map<String, dynamic> _device = {};
  int _lastIndex = 0;
  final TextEditingController _newIndexController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _localImage;
  String? _imageError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _pickImageProve(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile == null) return;
      setState(() {
        _localImage = File(pickedFile.path);
        _imageError = null;
      });
    } catch (e) {
      appLog("Error pick image: $e");
      if (mounted) SnackBarHelper.showError(context, 'Lỗi chọn ảnh');
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final provider = context.read<WaterIndexProvider>();

    final success = await provider.detailsWaterIndex(widget.data['id']);

    if (success && mounted) {
      final detail = provider.showData ?? {};
      appLog("detail: $detail");

      setState(() {
        _device = detail['thiet_bi'] as Map<String, dynamic>? ?? {};
        _historyList = List<Map<String, dynamic>>.from(
          detail['danh_sach_chi_so_nuoc_cu'] ?? [],
        );
        _lastIndex = detail['chi_so_nuoc_cuoi'] as int? ?? 0;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
      SnackBarHelper.showError(context, "${provider.errorMessage}");
    }
  }

  Future<void> _submitNewIndex() async {
    // Validate form trước
    if (!_formKey.currentState!.validate()) return;

    // Kiểm tra ảnh trước khi bật trạng thái submitting
    if (_localImage == null) {
      setState(() => _imageError = 'Vui lòng chọn ảnh chứng minh');
      return;
    }

    final int newIndex = int.parse(_newIndexController.text);
    if (newIndex < _lastIndex) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ số mới phải lớn hơn hoặc bằng chỉ số cuối cùng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<WaterIndexCustomerProvider>();
      int indexDifference = (newIndex - _lastIndex).abs();

      Map<String, dynamic> body = {
        "khach_hang_id": widget.data['khach_hang_id'],
        "ma_dong_ho": _device['id'],
        "chi_so_dau": _lastIndex,
        "chi_so_cuoi": newIndex,
        "luong_tieu_thu": indexDifference,
        "ngay_ghi": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "ky": DateFormat('yyyy-MM').format(DateTime.now()),
      };

      setState(() => _imageError = null);

      final success = await provider.saveWaterIndex(
        body,
        file: _localImage!,
      );

      if (success && mounted) {
        await _loadData();
        _newIndexController.clear();
        SnackBarHelper.showSuccess(context, 'Ghi chỉ số nước thành công!');
        context.pop();
      } else if (mounted) {
        SnackBarHelper.showError(context, 'Ghi chỉ số thất bại, vui lòng thử lại');
      }
    } catch (e) {
      appLog('Lỗi khi ghi chỉ số: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _newIndexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
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
              "Ghi số nước",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLastIndexCard(),
            const SizedBox(height: 20),
            _buildNewIndexForm(),
            const SizedBox(height: 24),
            _buildHistoryTable(),
            const SizedBox(height: 20),
            _buildDeviceInfoCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.speed, color: Color(0xFF2A6DFF), size: 22),
                SizedBox(width: 8),
                Text(
                  'Thông tin thiết bị',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Mã đồng hồ', _device['ma_dong_ho'] ?? '---'),
            _buildInfoRow('Seri', _device['seri'] ?? '---'),
            _buildInfoRow('Seri chỉ', _device['seri_chi'] ?? '---'),
            _buildInfoRow('Hãng sản xuất', _device['hang_sx'] ?? '---'),
            _buildInfoRow(
              'Ngày lắp đặt',
              _device['ngay_lap_dat'] != null
                  ? DateFormat('dd/MM/yyyy')
                  .format(DateTime.parse(_device['ngay_lap_dat']))
                  : '---',
            ),
            _buildInfoRow(
              'Trạng thái',
              _device['trang_thai'] == 'hoat_dong' ? 'Hoạt động' : 'Ngừng hoạt động',
              valueColor: _device['trang_thai'] == 'hoat_dong' ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color valueColor = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLastIndexCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A6DFF), Color(0xFF4A8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A6DFF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CHỈ SỐ NƯỚC CUỐI CÙNG',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$_lastIndex',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'm³',
                    style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Bảng hiển thị lịch sử các chỉ số nước
  Widget _buildHistoryTable() {
    if (_historyList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.table_chart, size: 48, color: Color(0xFFCBD5E1)),
              SizedBox(height: 12),
              Text(
                'Chưa có dữ liệu lịch sử',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Sắp xếp lịch sử theo ngày tăng dần (cũ nhất lên đầu)
    final sortedHistory = List.from(_historyList)
      ..sort((a, b) => (a['ngay_ghi'] ?? '').compareTo(b['ngay_ghi'] ?? ''));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Lịch sử ghi chỉ số',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const Divider(height: 1),
          // Bảng có thể cuộn ngang nếu màn hình nhỏ
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 8,
                headingRowColor: MaterialStateProperty.resolveWith(
                      (states) => const Color(0xFFF1F5F9),
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Kỳ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Chỉ số cũ (m³)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Chỉ số mới (m³)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Tiêu thụ (m³)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Ngày ghi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: sortedHistory.map((item) {
                  final chiSoDau = item['chi_so_dau'] ?? 0;
                  final chiSoCuoi = item['chi_so_cuoi'] ?? 0;
                  final tieuThu = chiSoCuoi - chiSoDau;
                  final ngayGhiRaw = item['ngay_ghi'] ?? '';
                  DateTime? ngayGhi;
                  try {
                    ngayGhi = DateTime.parse(ngayGhiRaw);
                  } catch (_) {}
                  final ngayGhiStr = ngayGhi != null
                      ? DateFormat('dd/MM/yyyy').format(ngayGhi)
                      : ngayGhiRaw;
                  // Kỳ: tháng/năm từ ngày ghi
                  String ky = '';
                  if (ngayGhi != null) {
                    ky = DateFormat('MM/yyyy').format(ngayGhi);
                  } else {
                    ky = ngayGhiRaw.length >= 7 ? ngayGhiRaw.substring(0, 7) : ngayGhiRaw;
                  }

                  return DataRow(
                    cells: [
                      DataCell(Text(ky)),
                      DataCell(Text('$chiSoDau')),
                      DataCell(Text('$chiSoCuoi')),
                      DataCell(Text('$tieuThu')),
                      DataCell(Text(ngayGhiStr)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewIndexForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'Nhập chỉ số mới',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _newIndexController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Nhập chỉ số nước (m³)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF0EA5E9),
                      width: 1.6,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.4,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.6,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  suffixText: 'm³',
                  suffixStyle: const TextStyle(
                    color: Color(0xFF64748B),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập chỉ số nước';
                  }
                  final int? val = int.tryParse(value);
                  if (val == null) {
                    return 'Chỉ số phải là số nguyên';
                  }
                  if (val < _lastIndex) {
                    return 'Chỉ số mới phải lớn hơn hoặc bằng $_lastIndex.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Text(
                    'Tải lên ảnh chứng minh',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImageProve(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, size: 18),
                      label: const Text('Thư viện'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImageProve(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text('Chụp ảnh'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // SỬ DỤNG WIDGET FULLSCREEN Ở ĐÂY
              if (_localImage != null)
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FullscreenImage(
                      imageProvider: FileImage(_localImage!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 120,
                    ),
                  ),
                ),

              if (_imageError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _imageError!,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitNewIndex,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A6DFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('GHI SỐ NƯỚC', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}