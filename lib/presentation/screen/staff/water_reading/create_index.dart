import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:clean_water/presentation/providers/water_index_provider.dart';
import 'package:clean_water/presentation/utils/logger_utils.dart';

class CreateIndexScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const CreateIndexScreen({
    super.key,
    required this.data,
  });

  @override
  State<CreateIndexScreen> createState() => _CreateIndexScreenState();
}

class _CreateIndexScreenState extends State<CreateIndexScreen> {
  bool _isLoading = false;
  bool _isSubmitting = false;
  List<dynamic> _historyList = [];
  Map<String, dynamic> _device = {};
  int _lastIndex = 0;
  final TextEditingController _newIndexController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // appLog("${widget.data}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// Lấy dữ liệu từ API qua provider
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final provider = context.read<WaterIndexProvider>();

    final success = await provider.detailsWaterIndex(widget.data['id']);

    if (success && mounted) {
      final detail = provider.showData ?? {};
      appLog("detail: $detail");

      setState(() {
        _device = detail['thiet_bi'] as Map<String, dynamic>? ?? {};
        _historyList =
        List<Map<String, dynamic>>.from(
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

  /// Ghi chỉ số nước mới
  Future<void> _submitNewIndex() async {
    if (!_formKey.currentState!.validate()) return;

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
      final provider = context.read<WaterIndexProvider>();
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
      final success = await provider.saveWaterIndex(body);

      if (success && mounted) {
        // Sau khi lưu thành công, tải lại dữ liệu mới từ server
        await _loadData();
        _newIndexController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ghi chỉ số nước thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ghi chỉ số thất bại, vui lòng thử lại'),
            backgroundColor: Colors.red,
          ),
        );
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
              "Lưu số nước",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
            _buildHistoryChart(),
            const SizedBox(height: 24),
            _buildNewIndexForm(),
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

  Widget _buildHistoryChart() {
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
              Icon(Icons.show_chart, size: 48, color: Color(0xFFCBD5E1)),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFF2A6DFF), size: 20),
                SizedBox(width: 8),
                Text(
                  'Lịch sử lượng nước tiêu thụ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // SizedBox(
            //   height: 200,
            //   child: _LineChartWidget(history: sortedHistory),
            // ),

            SizedBox(
              height: 200,
              child: _LineChartWidget(
                history: sortedHistory,
                onPointTap: (index, consumption, date) {
                  final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ngày $formattedDate: ${consumption.toInt()} m³ nước sử dụng'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sortedHistory.map((item) {
                  final chiSoDau = item['chi_so_dau'] ?? 0;
                  final chiSoCuoi = item['chi_so_cuoi'] ?? 0;
                  final consumption = chiSoCuoi - chiSoDau;
                  final ngay = item['ngay_ghi'] ?? '';
                  final displayDate = ngay.toString().length >= 10
                      ? '${ngay.toString().substring(8, 10)}/${ngay.toString().substring(5, 7)}'
                      : ngay.toString();
                  // return Container(
                  //   margin: const EdgeInsets.only(right: 12),
                  //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFFF1F5F9),
                  //     borderRadius: BorderRadius.circular(20),
                  //   ),
                  //   child: Text(
                  //     '$displayDate: $consumption m³',
                  //     style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  //   ),
                  // );
                  return GestureDetector(
                    onTap: () {
                      final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(item['ngay_ghi']));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ngày $formattedDate: $consumption m³ nước sử dụng'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$displayDate: $consumption m³',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
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
                  Icon(Icons.edit_note, color: Color(0xFF2A6DFF), size: 20),
                  SizedBox(width: 8),
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
                  prefixIcon: const Icon(Icons.water_drop, color: Color(0xFF2A6DFF)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  suffixText: 'm³',
                  suffixStyle: const TextStyle(color: Color(0xFF64748B)),
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
                    return 'Chỉ số mới phải >= $_lastIndex';
                  }
                  return null;
                },
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
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'LƯU CHỈ SỐ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Line Chart Widget
class _LineChartWidget extends StatefulWidget {
  final List<dynamic> history;
  final Function(int index, double consumption, String date)? onPointTap;

  const _LineChartWidget({
    required this.history,
    this.onPointTap,
  });

  @override
  State<_LineChartWidget> createState() => _LineChartWidgetState();
}
class _LineChartWidgetState extends State<_LineChartWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) return const SizedBox.shrink();

    final List<double> values = widget.history
        .map<double>((e) {
      final dau = (e['chi_so_dau'] ?? 0) as num;
      final cuoi = (e['chi_so_cuoi'] ?? 0) as num;
      return (cuoi - dau).toDouble();
    })
        .toList();

    final double minValue = values.reduce(min);
    final double maxValue = values.reduce(max);
    final double range = maxValue - minValue;
    final double topPadding = range * 0.1;
    final double chartMin = minValue - topPadding;
    final double chartMax = maxValue + topPadding;

    return GestureDetector(
      onTapUp: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Size size = box.size;
        final Offset local = box.globalToLocal(details.globalPosition);

        const leftMargin = 40.0;
        const rightMargin = 20.0;
        final chartWidth = size.width - leftMargin - rightMargin;
        if (chartWidth <= 0 || values.isEmpty) return;

        final dxStep = chartWidth / (values.length - 1);
        double minDistance = double.infinity;
        int selectedIndex = -1;

        for (int i = 0; i < values.length; i++) {
          final pointX = leftMargin + i * dxStep;
          final distance = (local.dx - pointX).abs();
          if (distance < minDistance) {
            minDistance = distance;
            selectedIndex = i;
          }
        }

        if (selectedIndex != -1 && minDistance < 20) {
          if (widget.onPointTap != null) {
            final consumption = values[selectedIndex];
            final date = widget.history[selectedIndex]['ngay_ghi'] ?? '';
            widget.onPointTap!(selectedIndex, consumption, date);
          }
        }
      },
      child: CustomPaint(
        painter: _LineChartPainter(
          dataPoints: values,
          labels: widget.history.map((e) {
            String ngay = e['ngay_ghi'] ?? '';
            if (ngay.length >= 10) ngay = ngay.substring(5);
            return ngay;
          }).toList(),
          minY: chartMin,
          maxY: chartMax,
        ),
        size: const Size(double.infinity, 200),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final List<String> labels;
  final double minY;
  final double maxY;

  _LineChartPainter({
    required this.dataPoints,
    required this.labels,
    required this.minY,
    required this.maxY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFF2A6DFF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintPoint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final paintCircleBorder = Paint()
      ..color = const Color(0xFF2A6DFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintGrid = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final leftMargin = 40.0;
    final rightMargin = 20.0;
    final topMargin = 20.0;
    final bottomMargin = 30.0;
    final chartWidth = size.width - leftMargin - rightMargin;
    final chartHeight = size.height - topMargin - bottomMargin;

    if (dataPoints.isEmpty || chartWidth <= 0 || chartHeight <= 0) return;

    for (int i = 0; i <= 4; i++) {
      final y = topMargin + (i / 4) * chartHeight;
      canvas.drawLine(Offset(leftMargin, y), Offset(size.width - rightMargin, y), paintGrid);
    }

    final dxStep = chartWidth / (dataPoints.length - 1);
    List<Offset> points = [];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = leftMargin + i * dxStep;
      final t = (dataPoints[i] - minY) / (maxY - minY);
      final y = topMargin + chartHeight * (1 - t);
      points.add(Offset(x, y));
    }

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paintLine);
    }

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5, paintPoint);
      canvas.drawCircle(points[i], 5, paintCircleBorder);

      final textSpan = TextSpan(
        text: labels[i],
        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(points[i].dx - textPainter.width / 2, size.height - bottomMargin + 4),
      );
    }

    final minLabel = TextSpan(
      text: '${minY.toInt()}',
      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
    );
    final maxLabel = TextSpan(
      text: '${maxY.toInt()}',
      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
    );
    final minPainter = TextPainter(
      text: minLabel,
      textDirection: ui.TextDirection.ltr,
    );
    final maxPainter = TextPainter(
      text: maxLabel,
      textDirection: ui.TextDirection.ltr,
    );
    minPainter.layout();
    maxPainter.layout();
    minPainter.paint(canvas, Offset(4, size.height - bottomMargin - 6));
    maxPainter.paint(canvas, Offset(4, topMargin - 8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}