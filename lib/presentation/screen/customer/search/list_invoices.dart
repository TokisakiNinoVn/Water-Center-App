import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:clean_water/presentation/providers/customer/water_index_customer_provider.dart';
import 'package:clean_water/presentation/routers/configs/customer_router_config.dart';
import 'package:clean_water/presentation/routers/configs/staff_router_config.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ListInvoices extends StatefulWidget {
  final int id;

  const ListInvoices({
    super.key,
    required this.id,
  });

  @override
  State<ListInvoices> createState() => _ListInvoicesState();
}

class _ListInvoicesState extends State<ListInvoices> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;

  List<dynamic> _allItems = [];
  List<dynamic> _filteredItems = [];

  final NumberFormat _currencyFormat =
  NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

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
          final maHoaDon =
          (item['ma_hoa_don'] ?? '').toString().toLowerCase();

          final maDongHo =
          (item['ma_dong_ho'] ?? '').toString().toLowerCase();

          final ky = (item['ky'] ?? '').toString().toLowerCase();

          return maHoaDon.contains(query) ||
              maDongHo.contains(query) ||
              ky.contains(query);
        }).toList();
      }
    });
  }

  // void _onSearchChanged() {
  //   final query = _searchController.text.toLowerCase().trim();
  //
  //   setState(() {
  //     if (query.isEmpty) {
  //       _filteredItems = List.from(_allItems);
  //     } else {
  //       _filteredItems = _allItems.where((itemRaw) {
  //         final invoices = itemRaw['hoa_dons'] as List<dynamic>;
  //
  //         if (invoices.isEmpty) return false;
  //
  //         final item = invoices.first as Map<String, dynamic>;
  //
  //         final maHoaDon =
  //         (item['ma_hoa_don'] ?? '')
  //             .toString()
  //             .toLowerCase();
  //
  //         final maDongHo =
  //         (item['ma_dong_ho'] ?? '')
  //             .toString()
  //             .toLowerCase();
  //
  //         final ky =
  //         (item['ky'] ?? '')
  //             .toString()
  //             .toLowerCase();
  //
  //         return maHoaDon.contains(query) ||
  //             maDongHo.contains(query) ||
  //             ky.contains(query);
  //       }).toList();
  //     }
  //   });
  // }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final provider = context.read<WaterIndexCustomerProvider>();

    final success = await provider.loadInvoice(widget.id);

    if (success && mounted) {
      final items = provider.invoices;

      setState(() {
        _allItems = items ?? [];
        _filteredItems = List.from(_allItems);

        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);

      SnackBarHelper.showError(
        context,
        'Không thể tải danh sách hóa đơn',
      );
    }
  }

  String _formatMoney(dynamic value) {
    final amount = double.tryParse(value.toString()) ?? 0;
    return _currencyFormat.format(amount);
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '--';

    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return '--';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'da_thanh_toan':
        return Colors.green;

      case 'chua_thanh_toan':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'da_thanh_toan':
        return 'Đã thanh toán';

      case 'chua_thanh_toan':
        return 'Chưa thanh toán';

      default:
        return 'Không xác định';
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
            Expanded(
              child: Text(
                'Danh sách hóa đơn',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1A1A1A),
                ),
              ),
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
                hintText: 'Tìm theo mã hóa đơn, kỳ hoặc mã đồng hồ',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
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
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
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
                    'Tổng: ${_filteredItems.length} hóa đơn',
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
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : _filteredItems.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Không có dữ liệu phù hợp',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.separated(
                padding:
                const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: _filteredItems.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final status = item['trang_thai'] ?? '';

                  return InkWell(
                    onTap: () {
                      context.push("${CustomerRouterConfig.detailsBill}/${item["id"]}");
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding:
                                const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue
                                      .withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(
                                      12),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_rounded,
                                  color: Colors.blue,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      item['ma_hoa_don'] ?? '--',
                                      style:
                                      const TextStyle(
                                        fontWeight:
                                        FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Kỳ ${item['ky'] ?? '--'}',
                                      style: TextStyle(
                                        color: Colors
                                            .grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  _getStatusColor(status)
                                      .withOpacity(0.12),
                                  borderRadius:
                                  BorderRadius.circular(
                                      30),
                                ),
                                child: Text(
                                  _getStatusText(status),
                                  style: TextStyle(
                                    color:
                                    _getStatusColor(status),
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding:
                            const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                              const Color(0xFFF7F9FC),
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                // _buildInfoRow(
                                //   'Mã đồng hồ',
                                //   item['ma_dong_ho']
                                //       ?.toString() ??
                                //       '--',
                                // ),
                                // const SizedBox(height: 10),
                                _buildInfoRow(
                                  'Chỉ số',
                                  '${item['chi_so_dau']} → ${item['chi_so_cuoi']}',
                                ),
                                const SizedBox(height: 10),
                                _buildInfoRow(
                                  'Tiêu thụ',
                                  '${item['luong_tieu_thu']} m³',
                                ),
                                const SizedBox(height: 10),
                                _buildInfoRow(
                                  'Ngày lập',
                                  _formatDate(
                                      item['ngay_lap']),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      'Tổng thanh toán',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors
                                            .grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatMoney(
                                          item['tong_tien']),
                                      style:
                                      const TextStyle(
                                        fontSize: 20,
                                        fontWeight:
                                        FontWeight.bold,
                                        color:
                                        Color(0xFF1976D2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}