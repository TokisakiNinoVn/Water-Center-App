import 'dart:convert';
import 'dart:io';
import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:clean_water/presentation/providers/staff/account_provider.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/index_storage.dart';

class UpdateProfileCustomer extends StatefulWidget {
  const UpdateProfileCustomer({super.key});

  @override
  State<UpdateProfileCustomer> createState() => _UpdateProfileCustomerState();
}

class _UpdateProfileCustomerState extends State<UpdateProfileCustomer>
    with SingleTickerProviderStateMixin {
  // Form key
  final _infoFormKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedGender = "female";
  String? _avatarUrl;
  File? _localAvatar;

  // Loading state
  bool _isUpdatingInfo = false;
  bool _dataLoaded = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // User data
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  Future<void> _loadUserData() async {
    final provider = context.read<AccountProvider>();
    final success = await provider.loadInformationAccount(isCustomer: true);

    if (success && mounted) {
      final userMap = provider.accountResponse?.data?['user'] as Map<String, dynamic>?;
      if (userMap != null) {
        setState(() {
          _userData = userMap;
          _nameController.text = userMap['ten_khach_hang'] ?? '';
          _phoneController.text = userMap['so_dien_thoai'] ?? '';
          _emailController.text = userMap['email'] ?? '';
          _addressController.text = userMap['dia_chi'] ?? ''; // sửa key
          _selectedGender = userMap['gioi_tinh'] ?? "female";
          _avatarUrl = userMap['avatar'];
          _dataLoaded = true;
        });
      } else {
        SnackBarHelper.showError(context, 'Không thể tải thông tin người dùng');
        setState(() => _dataLoaded = true);
      }
    } else if (mounted) {
      SnackBarHelper.showError(context, 'Không thể tải thông tin');
      setState(() => _dataLoaded = true);
    }

    _animController.forward();
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        appLog("Không thể chọn ảnh avatar: ");
        return;
      } else {
        appLog("Chọn ảnh avatar: $pickedFile");
        _localAvatar = File(pickedFile.path);
        setState(() {});
      }
    } catch (e) {
      appLog("Error pick avatar: $e");
      if (mounted) {
        SnackBarHelper.showError(context, 'Lỗi pick ảnh avatar');
      }
    }
  }

  // Cập nhật thông tin cá nhân
  Future<void> _updateInfo() async {
    if (!_infoFormKey.currentState!.validate()) return;

    setState(() => _isUpdatingInfo = true);
    final provider = context.read<AccountProvider>();

    try {
      // Sử dụng đúng key theo backend
      final updatedInfo = {
        'ten_khach_hang': _nameController.text.trim(),
        'so_dien_thoai': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'gioi_tinh': _selectedGender,
        'dia_chi': _addressController.text.trim(),
      };

      bool success;
      if (_localAvatar != null) {
        appLog("Có cập nhật avatar: $_localAvatar");
        success = await provider.update(updatedInfo, avatar: _localAvatar, isCustomer: true);
      } else {
        appLog("Không cập nhật avatar");
        success = await provider.update(updatedInfo, isCustomer: true);
      }

      if (success) {
        // Cập nhật local storage
        final userForStorage = Map<String, dynamic>.from(_userData ?? {});
        userForStorage.addAll(updatedInfo);
        final String jsonString = json.encode(userForStorage);
        await SharedPrefsService.saveValue(PrefType.string, 'user', jsonString);

        setState(() {
          _userData = userForStorage;
          _avatarUrl = null; // sẽ load lại sau
        });

        if (mounted) {
          SnackBarHelper.showSuccess(context, 'Cập nhật thông tin thành công!');
          // Reload lại để lấy avatar URL mới từ server
          await provider.loadInformationAccount(isCustomer: true);
          final newUserMap = provider.accountResponse?.data?['user'] as Map<String, dynamic>?;
          if (newUserMap != null && mounted) {
            setState(() {
              _avatarUrl = newUserMap['avatar'];
              _localAvatar = null;
            });
          }
        }
      } else {
        if (mounted) {
          SnackBarHelper.showError(context, "Cập nhật thông tin thất bại");
        }
      }
    } catch (e) {
      appLog("Error updating info: $e");
      if (mounted) {
        SnackBarHelper.showError(context, 'Cập nhật thất bại: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isUpdatingInfo = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ─── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _dataLoaded
                ? FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildBody(),
              ),
            )
                : const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1565C0),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                ),
              ),
            ),
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: -30,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  _buildAvatarPicker(),
                  const SizedBox(height: 20),
                  const Text(
                    'Cập nhật thông tin khách hàng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: _isUpdatingInfo ? null : _pickAvatar,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildAvatarContent(),
            ),
          ),
          if (!_isUpdatingInfo)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  size: 14, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (_localAvatar != null) {
      return Image.file(_localAvatar!, fit: BoxFit.cover);
    }
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return Image.network(
        _avatarUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
        errorBuilder: (_, __, ___) => _avatarPlaceholder(),
      );
    }
    return _avatarPlaceholder();
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: const Color(0xFF90CAF9),
      child: const Icon(Icons.person_rounded, size: 44, color: Colors.white),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin cá nhân
          _sectionLabel('Thông tin cá nhân'),
          const SizedBox(height: 12),
          Form(
            key: _infoFormKey,
            child: _buildCard([
              _buildField(
                controller: _nameController,
                label: 'Họ và tên',
                icon: Icons.badge_outlined,
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
              ),
              _divider(),
              _buildField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Vui lòng nhập email' : null,
              ),
              _divider(),
              _buildField(
                controller: _phoneController,
                label: 'Số điện thoại',
                icon: Icons.phone_outlined,
              ),
              _divider(),
              _buildField(
                controller: _addressController,
                label: 'Địa chỉ',
                icon: Icons.location_on_outlined,
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Vui lòng nhập địa chỉ' : null,
              ),
            ]),
          ),
          const SizedBox(height: 20),
          _sectionLabel('Giới tính'),
          const SizedBox(height: 12),
          _buildGenderSelector(),
          const SizedBox(height: 20),
          // Nút lưu thông tin
          _buildSaveInfoButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF5C6BC0),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 52, endIndent: 16);

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF212121)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1565C0)),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        errorStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(child: _genderOption(label: 'Nam', value: "male", icon: Icons.male)),
        const SizedBox(width: 12),
        Expanded(child: _genderOption(label: 'Nữ', value: "female", icon: Icons.female)),
      ],
    );
  }

  Widget _genderOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: _isUpdatingInfo ? null : () => setState(() => _selectedGender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1565C0)
                : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : const Color(0xFF424242)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF424242),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveInfoButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isUpdatingInfo ? null : _updateInfo,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF90CAF9),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isUpdatingInfo
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Lưu thông tin',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}