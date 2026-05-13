import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:clean_water/presentation/providers/customer/water_index_customer_provider.dart';
import 'package:clean_water/presentation/routers/configs/customer_router_config.dart';
import 'package:clean_water/presentation/routers/configs/staff_router_config.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ListWaterMeterCustomer extends StatefulWidget {
  const ListWaterMeterCustomer({super.key});

  @override
  State<ListWaterMeterCustomer> createState() => _WaterReadingState();
}

class _WaterReadingState extends State<ListWaterMeterCustomer> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<dynamic> _allItems = [];
  List<dynamic> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(_allItems);
      } else {
        _filteredItems = _allItems.where((item) {
          final maDongHo = (item['ma_dong_ho'] ?? '').toString().toLowerCase();
          final tenKhachHang = (item['khach_hang']?['ten_khach_hang'] ?? '')
              .toString()
              .toLowerCase();
          final seri = (item['seri'] ?? '').toString().toLowerCase();
          return maDongHo.contains(query) ||
              tenKhachHang.contains(query) ||
              seri.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final provider = context.read<WaterIndexCustomerProvider>();
    final success = await provider.loadListCustomer();

    if (success && mounted) {
      final items = provider.waterIndex;
      setState(() {
        _allItems = items ?? [];
        _filteredItems = List.from(_allItems);
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _trangThaiLabel(String? trangThai) {
    switch (trangThai) {
      case 'hoat_dong':
        return 'Hoạt động';
      case 'tam_dung':
        return 'Tạm dừng';
      case 'ngung_hoat_dong':
        return 'Ngừng hoạt động';
      default:
        return trangThai ?? '';
    }
  }

  Color _trangThaiColor(String? trangThai) {
    switch (trangThai) {
      case 'hoat_dong':
        return const Color(0xFF22C55E);
      case 'tam_dung':
        return const Color(0xFFF59E0B);
      case 'ngung_hoat_dong':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
              'Danh sách các đồng hồ nước',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo mã đồng hồ hoặc số công tơ',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon:
                Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear,
                      size: 18, color: Colors.grey.shade400),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
          if (!_isLoading)
            Container(
              color: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Tổng: ${_filteredItems.length} đồng hồ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(
                    'Không có dữ liệu phù hợp',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: _filteredItems.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final khachHang = item['khach_hang'];
                  final trangThai =
                  item['trang_thai']?.toString();

                  return InkWell(
                    onTap: () {
                      context.push(StaffRouterConfig.createIndex, extra: item);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row
                          Row(
                            children: [
                              // Container(
                              //   padding: const EdgeInsets.all(8),
                              //   decoration: BoxDecoration(
                              //     color: const Color(0xFF3B82F6)
                              //         .withOpacity(0.1),
                              //     borderRadius:
                              //     BorderRadius.circular(10),
                              //   ),
                              //   child: const Icon(
                              //     Icons.water_drop_outlined,
                              //     size: 20,
                              //     color: Color(0xFF3B82F6),
                              //   ),
                              // ),
                              // const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text("Số công tơ: "),
                                        const SizedBox(height: 2),
                                        Text(
                                          item['seri'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Text(
                                    //   item['seri'] ?? '',
                                    //   style: const TextStyle(
                                    //     fontWeight: FontWeight.bold,
                                    //     fontSize: 15,
                                    //     color: Color(0xFF1A1A1A),
                                    //   ),
                                    // ),
                                    // const SizedBox(height: 2),
                                    // Text(
                                    //   khachHang?['ten_khach_hang'] ??
                                    //       '',
                                    //   style: TextStyle(
                                    //     fontSize: 13,
                                    //     color: Colors.grey.shade600,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              // Trạng thái badge
                              // Container(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 10, vertical: 4),
                              //   decoration: BoxDecoration(
                              //     color: _trangThaiColor(trangThai)
                              //         .withOpacity(0.1),
                              //     borderRadius:
                              //     BorderRadius.circular(20),
                              //   ),
                              //   child: Text(
                              //     _trangThaiLabel(trangThai),
                              //     style: TextStyle(
                              //       fontSize: 12,
                              //       fontWeight: FontWeight.w600,
                              //       color:
                              //       _trangThaiColor(trangThai),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          _infoRow(
                            icon: Icons.qr_code_outlined,
                            label: 'Mã đồng hồ',
                            value: item['ma_dong_ho'] ?? '',
                          ),
                          const SizedBox(height: 6),
                          // Info rows
                          // _infoRow(
                          //   icon: Icons.person_outline,
                          //   label: 'KH',
                          //   value: "${khachHang?['ma_khach_hang']} - ${khachHang?['ten_khach_hang']}" ?? '',
                          // ),
                          const SizedBox(height: 6),
                          _infoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Chỉ số cuối',
                            value: (item?['chi_so_cuoi'] ?? '').toString(),
                          ),
                          const SizedBox(height: 6),

                          // const SizedBox(height: 6),
                          // _infoRow(
                          //   icon: Icons.calendar_today_outlined,
                          //   label: 'Ngày lắp',
                          //   value: FormatHelper.formatDateTime(item['ngay_lap_dat'] ?? ''),
                          // ),
                          // const SizedBox(height: 10),
                          // Footer
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Điều hướng lịch sử tiền nước
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'LS tiền nước',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.push(
                                      CustomerRouterConfig.saveIndex,
                                      extra: item,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B82F6),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.water_drop_outlined,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'LS số nước',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black.withOpacity(.6),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '—',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}