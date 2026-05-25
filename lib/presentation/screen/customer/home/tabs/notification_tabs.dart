import 'package:clean_water/data/configs/color_config.dart';
import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:clean_water/presentation/providers/customer/notification_customer_provider.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationCustomerTab extends StatefulWidget {
  const NotificationCustomerTab({super.key});

  @override
  State<NotificationCustomerTab> createState() =>
      _NotificationCustomerTabState();
}

class _NotificationCustomerTabState
    extends State<NotificationCustomerTab> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final provider = context.read<NotificationCustomerProvider>();

    final success = await provider.loadListNotificationCustomer();

    if (!success && mounted) {
      SnackBarHelper.showError(
        context,
        provider.errorMessage ?? 'Không thể tải thông báo',
      );
    }
  }

  Future<void> _handleOpenNotification(
      Map notification,
      NotificationCustomerProvider provider,
      ) async {
    final int id = notification['id'];
    final bool isRead = notification['da_xem'] == 1;

    // Nếu chưa đọc thì gọi API đọc thông báo
    if (!isRead) {
      final success = await provider.isReadNotification(id);

      if (success) {
        setState(() {
          notification['da_xem'] = 1;
          notification['thoi_gian_xem'] =
              DateTime.now().toIso8601String();
        });
      }
    }

    if (!mounted) return;

    final thongBao = notification['thong_bao'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Handle
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  thongBao['tieu_de'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  thongBao['noi_dung'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.grey.shade800,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        thongBao['ngay_gui'] ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
      Map notification,
      NotificationCustomerProvider provider,
      ) {
    final thongBao = notification['thong_bao'];
    final bool isRead = notification['da_xem'] == 1 ? true : false;

    return InkWell(
      onTap: () => _handleOpenNotification(
        notification,
        provider,
      ),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.grey.shade50
              : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead
                ? Colors.grey.shade200
                : Colors.blue.withOpacity(.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isRead
                    ? Colors.grey.shade200
                    : Colors.blue.withOpacity(.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: isRead
                    ? Colors.grey.shade700
                    : Colors.blue,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thongBao['tieu_de'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isRead ? Colors.grey.shade900 : Colors.black.withOpacity(.7),
                          ),
                        ),
                      ),

                      if (!isRead)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    thongBao['noi_dung'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      // color: Colors.grey.shade700,
                      color: isRead ? Colors.grey.shade900 : Colors.black.withOpacity(.7),

                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          thongBao['ngay_gui'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationCustomerProvider>(
      builder: (context, provider, child) {

        final notifications = provider.notifications;

        return Scaffold(
          appBar: AppBar(
            title: Center(child: const Text("Thông báo")),
            backgroundColor: ColorConfig.backgroundPrimary,
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: ColorConfig.backgroundPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 0,
            ),
            child: provider.isLoadingList &&
                notifications.isEmpty
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : notifications.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Icon(
                    Icons.notifications_off_rounded,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Chưa có thông báo nào",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.builder(
                physics:
                const AlwaysScrollableScrollPhysics(),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationItem(
                    notifications[index],
                    provider,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}