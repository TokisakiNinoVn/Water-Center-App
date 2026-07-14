import 'package:clean_water/data/configs/color_config.dart';
import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:clean_water/presentation/providers/customer/support_customer_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateSupport extends StatefulWidget {
  const CreateSupport({super.key});

  @override
  State<CreateSupport> createState() => _CreateSupportState();
}

class _CreateSupportState extends State<CreateSupport> {
  final SupportCustomerProvider _supportCustomerProvider =
      SupportCustomerProvider();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> create() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final payload = {
      'tieu_de': titleController.text.trim(),
      'noi_dung': contentController.text.trim(),
    };

    final success = await _supportCustomerProvider.createSupport(payload);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      SnackBarHelper.showSuccess(context, "Gửi phiếu hỗ trợ thành công");
      context.pop(true);
    } else {
      SnackBarHelper.showError(
        context,
        _supportCustomerProvider.errorMessage ?? "Có lỗi xảy ra",
      );
    }
  }

  InputDecoration inputDecoration({
    required String label,
    required String hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: const Color(0xffF7F7F7),
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
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
    );
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
              "Tạo phiếu hỗ trợ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : create,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConfig.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      "Gửi phiếu hỗ trợ",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Thông tin hỗ trợ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Vui lòng mô tả rõ vấn đề bạn đang gặp phải để chúng tôi có thể hỗ trợ nhanh nhất.",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  TextFormField(
                    controller: titleController,
                    textInputAction: TextInputAction.next,
                    decoration: inputDecoration(
                      label: "Tiêu đề",
                      hint: "Ví dụ: Không thanh toán được",
                      icon: Icons.title,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Vui lòng nhập tiêu đề";
                      }

                      if (value.trim().length < 5) {
                        return "Tiêu đề quá ngắn";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: contentController,
                    minLines: 6,
                    maxLines: 10,
                    decoration: inputDecoration(
                      label: "Nội dung",
                      hint: "Mô tả chi tiết vấn đề bạn gặp phải...",
                      // icon: Icons.description_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Vui lòng nhập nội dung";
                      }

                      if (value.trim().length < 10) {
                        return "Nội dung quá ngắn";
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
