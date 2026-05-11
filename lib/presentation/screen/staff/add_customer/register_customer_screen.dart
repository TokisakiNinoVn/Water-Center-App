import 'dart:io';

import 'package:clean_water/presentation/providers/customer_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddCustomer extends StatefulWidget {
  const AddCustomer({super.key});

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
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

  int? _selectedCustomerType = 1;
  int? _selectedRegion = 1;
  int? _selectedArea = 1;

  File? _avatar;

  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        _avatar = File(picked.path);
      });
    }
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

    // Nếu API hỗ trợ upload ảnh multipart
    if (_avatar != null) {
      body["anh_dai_dien"] = _avatar;
    }

    final success = await provider.registerCustomer(body);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thêm khách hàng thành công"),
          backgroundColor: Colors.green,
        ),
      );

      context.pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "Có lỗi xảy ra"),
          backgroundColor: Colors.red,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();

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
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE5E7EB),
                              image: _avatar != null
                                  ? DecorationImage(
                                image: FileImage(_avatar!),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: _avatar == null
                                ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _gender,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: "male",
                                    child: Text("Nam"),
                                  ),
                                  DropdownMenuItem(
                                    value: "female",
                                    child: Text("Nữ"),
                                  ),
                                ],
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
                    ),

                    _buildTextField(
                      label: "Ngày sinh",
                      controller: _birthController,
                      readOnly: true,
                      onTap: _selectBirthDate,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownBox<int>(
                            label: "Loại KH",
                            value: _selectedCustomerType,
                            items: const [
                              DropdownMenuItem(
                                value: 1,
                                child: Text("Loại 1"),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text("Loại 2"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCustomerType = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildDropdownBox<int>(
                            label: "Vùng",
                            value: _selectedRegion,
                            items: const [
                              DropdownMenuItem(
                                value: 1,
                                child: Text("Vùng 1"),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text("Vùng 2"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedRegion = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    _buildDropdownBox<int>(
                      label: "Khu vực",
                      value: _selectedArea,
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text("Khu vực 1"),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text("Khu vực 2"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedArea = value;
                        });
                      },
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

  Widget _buildDropdownBox<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
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
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}