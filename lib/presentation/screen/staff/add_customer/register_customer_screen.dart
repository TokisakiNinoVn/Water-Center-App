import 'dart:io';

import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:clean_water/presentation/providers/customer_provider.dart';
import 'package:clean_water/presentation/providers/list_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterCustomerScreen extends StatefulWidget {
  const RegisterCustomerScreen({super.key});

  @override
  State<RegisterCustomerScreen> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<RegisterCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController =
  TextEditingController(text: "admin@123");
  final TextEditingController _birthController =
  TextEditingController(text: "2002-02-21");

  String _gender = "male";

  // Các biến lưu giá trị được chọn (ID)
  int? _selectedCustomerType;
  int? _selectedRegion;
  int? _selectedArea;

  bool _isLoading = true;

  // Danh sách dữ liệu từ API
  List<dynamic> clientTypes = [];
  List<dynamic> areas = [];
  List<dynamic> regions = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadListData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  Future<void> _loadListData() async {
    setState(() => _isLoading = true);

    final provider = context.read<ListProvider>();

    final results = await Future.wait([
      provider.loadClientTypes(),
      provider.loadAreas(),
      provider.loadRegions(),
    ]);

    if (!mounted) return;

    if (results.every((e) => e)) {
      setState(() {
        clientTypes = provider.clientTypes ?? [];
        areas = provider.areas ?? [];
        regions = provider.regions ?? [];

        // Gán giá trị mặc định (nếu có dữ liệu)
        if (clientTypes.isNotEmpty) {
          _selectedCustomerType = _getIdFromItem(clientTypes.first);
        }
        if (regions.isNotEmpty) {
          _selectedRegion = _getIdFromItem(regions.first);
        }
        if (areas.isNotEmpty) {
          _selectedArea = _getIdFromItem(areas.first);
        }
      });
    }

    setState(() => _isLoading = false);
  }

  // Hàm lấy id từ item (tuỳ theo cấu trúc dữ liệu thực tế)
  int _getIdFromItem(dynamic item) {
    // Giả sử item có trường 'id' hoặc 'ma_loai_khach_hang', 'vung_id',...
    // Bạn có thể điều chỉnh theo API thực tế
    if (item is Map) {
      return item['id'] ?? item['ma_loai_khach_hang'] ?? 0;
    }
    return item.id ?? 0;
  }

  // Hàm lấy tên hiển thị từ item
  String _getDisplayName(dynamic item) {
    if (item is Map) {
      return item['ten_loai'] ??
          item['ten_vung'] ??
          item['ten_tuyen'] ??
          item['name'] ??
          'Không tên';
    }
    return item.name ?? 'Không tên';
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2002, 2, 21),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthController.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CustomerProvider>();

    Map<String, dynamic> body = {
      "ten_khach_hang": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "dia_chi": _addressController.text.trim(),
      "so_dien_thoai": _phoneController.text.trim(),
      "gioi_tinh": _gender,
      "ngay_sinh": _birthController.text.trim(),
      "ma_loai_khach_hang": _selectedCustomerType,
      "vung_id": _selectedRegion,
      "khu_vuc_id": _selectedArea,
      "mat_khau": _passwordController.text.trim(),
    };

    final success = await provider.registerCustomer(body);

    if (!mounted) return;

    if (success) {
      SnackBarHelper.showSuccess(context, "Thêm khách hàng thành công!");
      context.pop(true);
    } else {
      SnackBarHelper.showSuccess(context, provider.errorMessage ?? "Có lỗi xảy ra");
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              hintText: "Nhập $label",
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
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
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dropdown động từ danh sách dữ liệu
  Widget _buildDynamicDropdown<T>({
    required String label,
    required List<dynamic> items,
    required T? value,
    required void Function(T?) onChanged,
    String Function(dynamic)? displayNameBuilder,
    int? Function(dynamic)? idBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: items.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("Không có dữ liệu"),
              )
                  : DropdownButton<T>(
                value: value,
                isExpanded: true,
                hint: const Text("Chọn..."),
                items: items.map((item) {
                  final id = idBuilder != null
                      ? idBuilder(item)
                      : _getIdFromItem(item);
                  final name = displayNameBuilder != null
                      ? displayNameBuilder(item)
                      : _getDisplayName(item);
                  return DropdownMenuItem<T>(
                    value: id as T?,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();
    final listProvider = context.watch<ListProvider>();

    // Hiển thị loading nếu đang tải dữ liệu
    if (_isLoading || listProvider.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 16,
          title: Row(
            children: [
              InkWell(
                onTap: () => context.pop(),
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
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
              const Expanded(
                child: Text(
                  "Thêm khách hàng mới",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(40),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
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
            const Expanded(
              child: Text(
                "Thêm khách hàng mới",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      label: "Tên khách hàng",
                      controller: _nameController,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Vui lòng nhập tên khách hàng";
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      label: "Email",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      label: "Số điện thoại",
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Vui lòng nhập số điện thoại";
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      label: "Địa chỉ",
                      controller: _addressController,
                      maxLines: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Giới tính",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F8FA),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: RadioListTile<String>(
                                    value: "male",
                                    groupValue: _gender,
                                    title: const Text("Nam"),
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    activeColor: const Color(0xFF3B82F6),
                                    onChanged: (value) {
                                      setState(() {
                                        _gender = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F8FA),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: RadioListTile<String>(
                                    value: "female",
                                    groupValue: _gender,
                                    title: const Text("Nữ"),
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    activeColor: const Color(0xFF3B82F6),
                                    onChanged: (value) {
                                      setState(() {
                                        _gender = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildTextField(
                      label: "Ngày sinh",
                      controller: _birthController,
                      readOnly: true,
                      onTap: _selectBirthDate,
                    ),
                    // Loại khách hàng
                    _buildDynamicDropdown<int>(
                      label: "Loại khách hàng",
                      items: clientTypes,
                      value: _selectedCustomerType,
                      onChanged: (value) {
                        setState(() {
                          _selectedCustomerType = value;
                        });
                      },
                      displayNameBuilder: (item) => _getDisplayName(item),
                      idBuilder: (item) => _getIdFromItem(item),
                    ),
                    // Vùng
                    _buildDynamicDropdown<int>(
                      label: "Vùng",
                      items: regions,
                      value: _selectedRegion,
                      onChanged: (value) {
                        setState(() {
                          _selectedRegion = value;
                        });
                      },
                      displayNameBuilder: (item) => _getDisplayName(item),
                      idBuilder: (item) => _getIdFromItem(item),
                    ),
                    // Khu vực
                    _buildDynamicDropdown<int>(
                      label: "Khu vực",
                      items: areas,
                      value: _selectedArea,
                      onChanged: (value) {
                        setState(() {
                          _selectedArea = value;
                        });
                      },
                      displayNameBuilder: (item) => _getDisplayName(item),
                      idBuilder: (item) => _getIdFromItem(item),
                    ),
                    _buildTextField(
                      label: "Mật khẩu",
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        )
                            : const Text(
                          "Tạo khách hàng",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}