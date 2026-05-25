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

class UpdateProfileStaff extends StatefulWidget {
  const UpdateProfileStaff({super.key});

  @override
  State<UpdateProfileStaff> createState() => _UpdateProfileStaffState();
}

class _UpdateProfileStaffState extends State<UpdateProfileStaff>
    with SingleTickerProviderStateMixin {
  // Form keys
  final _infoFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Info controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // Password controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Password visibility
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String _selectedGender = "female"; // 0 = Nam, 1 = Nữ
  String? _avatarUrl;
  File? _localAvatar;

  // Loading states
  bool _isUpdatingInfo = false;
  bool _isUpdatingPassword = false;
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
    final success = await provider.loadInformationAccount();

    if (success && mounted) {
      final userMap = provider.accountResponse?.data?['user'] as Map<String, dynamic>?;
      if (userMap != null) {
        setState(() {
          _userData = userMap;
          _nameController.text = userMap['name'] ?? '';
          _phoneController.text = userMap['phone'] ?? '';
          _emailController.text = userMap['email'] ?? '';
          _addressController.text = userMap['address'] ?? '';
          _selectedGender = userMap['gender'] ?? "female";
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
        // imageQuality: 85,
        // maxWidth: 800,
      );

      if (pickedFile == null){
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

  // Validators for password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu mới';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 chữ in hoa';
    }
    if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 chữ số';
    }
    if (!RegExp(r'(?=.*[!@#\$&*~])').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt (!@#\$&*~)';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _newPasswordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  // Update personal info only
  Future<void> _updateInfo() async {
    if (!_infoFormKey.currentState!.validate()) return;

    setState(() => _isUpdatingInfo = true);
    final provider = context.read<AccountProvider>();

    try {
      final updatedInfo = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'gender': _selectedGender,
        'address': _addressController.text.trim(),
      };

      bool success;
      if (_localAvatar != null) {
        appLog("Có cập nhật avatar: $_localAvatar");
        success = await provider.update(updatedInfo, avatar: _localAvatar, isCustomer: false);
      } else {
        appLog("Không cập nhật avatar: $_localAvatar");
        success = await provider.update(updatedInfo);
      }

      if (success) {
        // Update local storage and state
        final userForStorage = Map<String, dynamic>.from(_userData ?? {});
        userForStorage.addAll(updatedInfo);
        // Remove any password fields if present
        userForStorage.remove('current_password');
        userForStorage.remove('password');
        userForStorage.remove('password_confirmation');
        final String jsonString = json.encode(userForStorage);
        await SharedPrefsService.saveValue(PrefType.string, 'user', jsonString);

        setState(() {
          _userData = userForStorage;
          _avatarUrl = null; // will be reloaded later, but keep local preview
        });

        if (mounted) {
          SnackBarHelper.showSuccess(context, 'Cập nhật thông tin thành công!');
          // Reload user data to get fresh avatar URL
          await provider.loadInformationAccount();
          final newUserMap = provider.accountResponse?.data?['user'] as Map<String, dynamic>?;
          if (newUserMap != null && mounted) {
            setState(() {
              _avatarUrl = newUserMap['avatar'];
              _localAvatar = null; // clear local preview after server save
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

  // Update password only
  Future<void> _updatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    // Check if current password is provided
    if (_currentPasswordController.text.trim().isEmpty) {
      SnackBarHelper.showError(context, 'Vui lòng nhập mật khẩu hiện tại');
      return;
    }

    setState(() => _isUpdatingPassword = true);
    final provider = context.read<AccountProvider>();

    try {
      final passwordData = {
        'current_password': _currentPasswordController.text.trim(),
        'password': _newPasswordController.text.trim(),
        'password_confirmation': _confirmPasswordController.text.trim(),
      };

      final success = await provider.update(passwordData);

      if (success) {
        if (mounted) {
          SnackBarHelper.showSuccess(context, 'Đổi mật khẩu thành công!');
          // Clear password fields
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
      } else {
        if (mounted) {
          SnackBarHelper.showError(context, "Đổi mật khẩu thất bại");
        }
      }
    } catch (e) {
      appLog("Error updating password: $e");
      if (mounted) {
        SnackBarHelper.showError(context, 'Đổi mật khẩu thất bại: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isUpdatingPassword = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                    'Chỉnh sửa hồ sơ nhân viên',
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
      onTap: (_isUpdatingInfo || _isUpdatingPassword) ? null : _pickAvatar,
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
          if (!_isUpdatingInfo && !_isUpdatingPassword)
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
          // Personal information section
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
                // keyboardType: TextInputType.phone,
                // validator: (v) {
                //   if (v == null || v.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
                //   if (!RegExp(r'^0\d{9}$').hasMatch(v.trim())) {
                //     return 'Số điện thoại không hợp lệ (10 số, bắt đầu bằng 0)';
                //   }
                //   return null;
                // },
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
          // Save info button - GREEN/BLUE
          _buildSaveInfoButton(),
          const SizedBox(height: 24),

          // Password change section
          _sectionLabel('Đổi mật khẩu'),
          const SizedBox(height: 12),
          Form(
            key: _passwordFormKey,
            child: _buildCard([
              _buildPasswordField(
                controller: _currentPasswordController,
                label: 'Mật khẩu hiện tại',
                icon: Icons.lock_outline,
                obscureText: _obscureCurrentPassword,
                onToggle: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
              ),
              _divider(),
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'Mật khẩu mới',
                icon: Icons.lock_outline,
                obscureText: _obscureNewPassword,
                onToggle: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                validator: _validatePassword,
              ),
              _divider(),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Xác nhận mật khẩu mới',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: _validateConfirmPassword,
              ),
            ]),
          ),
          const SizedBox(height: 20),
          // Update password button - ORANGE/RED
          _buildUpdatePasswordButton(),
          const SizedBox(height: 16),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF212121)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1565C0)),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility,
              size: 20, color: const Color(0xFF9E9E9E)),
          onPressed: onToggle,
        ),
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
      onTap: (_isUpdatingInfo || _isUpdatingPassword) ? null : () => setState(() => _selectedGender = value),
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

  Widget _buildUpdatePasswordButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _isUpdatingPassword ? null : _updatePassword,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFD32F2F),
          side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isUpdatingPassword
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFFD32F2F),
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_reset_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Cập nhật mật khẩu',
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