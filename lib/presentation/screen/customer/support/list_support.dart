import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:clean_water/presentation/providers/customer/support_customer_provider.dart';
import 'package:clean_water/presentation/routers/configs/customer_router_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ListSupport extends StatefulWidget {
  const ListSupport({super.key});

  @override
  State<ListSupport> createState() => _ListSupportState();
}

class _ListSupportState extends State<ListSupport> {
  final SupportCustomerProvider _supportCustomerProvider =
      SupportCustomerProvider();
  bool isLoading = false;
  List<dynamic> listRequestsSupport = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    final success = await _supportCustomerProvider.listSupport();

    if (!mounted) return;

    setState(() {
      isLoading = false;
      if (success) {
        listRequestsSupport = _supportCustomerProvider.listRequestsSupport;
      }
    });

    if (!success) {
      SnackBarHelper.showError(context, _supportCustomerProvider.errorMessage!);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'cho_xu_ly':
        return 'Chờ xử lý';
      case 'dang_xu_ly':
        return 'Đang xử lý';
      case 'da_hoan_thanh':
        return 'Hoàn thành';
      case 'da_huy':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'cho_xu_ly':
        return Colors.orange;
      case 'dang_xu_ly':
        return Colors.blue;
      case 'da_hoan_thanh':
        return Colors.green;
      case 'da_huy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
              "Các yêu cầu hỗ trợ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : listRequestsSupport.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.support_agent_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Chưa có yêu cầu hỗ trợ nào",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: loadData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listRequestsSupport.length,
                  itemBuilder: (context, index) {
                    final item = listRequestsSupport[index];
                    final createdAt = DateTime.parse(item['created_at']);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          // // Chuyển sang màn hình chi tiết
                          context.push(
                            '${CustomerRouterConfig.supportDetail}/${item['id']}',
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item['ma_ho_tro'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        item['trang_thai'],
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getStatusText(item['trang_thai']),
                                      style: TextStyle(
                                        color: _getStatusColor(
                                          item['trang_thai'],
                                        ),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['tieu_de'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['noi_dung'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(createdAt),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(CustomerRouterConfig.createSupport);
        },
        icon: const Icon(Icons.support_agent_outlined),
        label: const Text("Tạo hỗ trợ"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
