import 'dart:io';
import 'package:clean_water/presentation/common/snackbar.dart';
import 'package:clean_water/presentation/providers/auth/auth_provider.dart';
import 'package:clean_water/presentation/providers/staff/account_provider.dart';
import 'package:clean_water/presentation/routers/configs/customer_router_config.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterAccount extends StatefulWidget {
  const RegisterAccount({super.key});

  @override
  State<RegisterAccount> createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount>
    with SingleTickerProviderStateMixin {
  // Form keys
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedGender = "male";
  DateTime? _selectedDateOfBirth;

  // Focus nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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

    _animController.forward();
  }

  // Register new customer account
  Future<void> _registerAccount() async {
    // Validate basic info
    if (!_basicInfoFormKey.currentState!.validate()) return;
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = context.read<AuthProvider>();

    try {
      final registrationData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'password_confirmation': _confirmPasswordController.text.trim(),
        'gender': _selectedGender,
        'address': _addressController.text.trim(),
        // 'date_of_birth': _selectedDateOfBirth?.toIso8601String().split('T').first ?? '',
      };

      final success = await provider.registerAccountProvider(registrationData);

      if (success && mounted) {
        SnackBarHelper.showSuccess(context, 'Đăng ký tài khoản thành công!');


        if (mounted) {
          context.go(CustomerRouterConfig.homeCustomer);
        }
      } else if (mounted) {
        SnackBarHelper.showError(context, provider.errorMessage ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      appLog("Error registering account: $e");
      if (mounted) {
        SnackBarHelper.showError(context, 'Đăng ký thất bại: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Pick date of birth
  Future<void> _pickDateOfBirth() async {
    final DateTime now = DateTime.now();
    final DateTime maxDate = DateTime(now.year - 10, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? maxDate,
      firstDate: DateTime(1900),
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1565C0),
              onPrimary: Colors.white,
              onSurface: Color(0xFF212121),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _addressFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    _animController.dispose();
    super.dispose();
  }

  // Validators
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    if (value.trim().length < 2) {
      return 'Họ tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(value)) {
      return 'Mật khẩu phải bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  // ─── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đăng ký tài khoản"),
        backgroundColor: const Color(0xFFF5F6FA),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildBody(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1565C0),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        title: const Text(
          'Đăng ký tài khoản',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(Icons.person_add_rounded, size: 64, color: Colors.white70),
                // SizedBox(height: 12),
                // Text(
                //   'Tạo tài khoản mới',
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontSize: 16,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Thông tin cá nhân'),
          const SizedBox(height: 12),
          Form(
            key: _basicInfoFormKey,
            child: _buildCard([
              _buildField(
                controller: _nameController,
                label: 'Họ và tên',
                icon: Icons.badge_outlined,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                validator: _validateName,
              ),
              _divider(),
              _buildField(
                controller: _phoneController,
                label: 'Số điện thoại',
                icon: Icons.phone_outlined,
                focusNode: _phoneFocus,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                validator: _validatePhone,
              ),
              _divider(),
              _buildField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                focusNode: _emailFocus,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: (_) => _addressFocus.requestFocus(),
                // validator: _validateEmail,
              ),
              // _divider(),
              // _buildField(
              //   controller: _addressController,
              //   label: 'Địa chỉ',
              //   icon: Icons.location_on_outlined,
              //   focusNode: _addressFocus,
              //   textInputAction: TextInputAction.next,
              //   onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              //   // validator: _validateAddress,
              // ),
            ]),
          ),
          const SizedBox(height: 20),
          // _sectionLabel('Ngày sinh'),
          // const SizedBox(height: 12),
          // _buildDateOfBirthPicker(),
          // const SizedBox(height: 20),
          // _sectionLabel('Giới tính'),
          // const SizedBox(height: 12),
          // _buildGenderSelector(),
          // const SizedBox(height: 20),
          _sectionLabel('Bảo mật'),
          const SizedBox(height: 12),
          Form(
            key: _passwordFormKey,
            child: _buildCard([
              _buildPasswordField(
                controller: _passwordController,
                label: 'Mật khẩu',
                focusNode: _passwordFocus,
                obscureText: _obscurePassword,
                onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                validator: _validatePassword,
              ),
              _divider(),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Xác nhận mật khẩu',
                focusNode: _confirmPasswordFocus,
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: _validateConfirmPassword,
              ),
            ]),
          ),
          const SizedBox(height: 24),
          _buildRegisterButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthPicker() {
    return GestureDetector(
      onTap: _isLoading ? null : _pickDateOfBirth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cake_outlined, color: Color(0xFF1565C0), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDateOfBirth != null
                    ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                    : 'Chọn ngày sinh',
                style: TextStyle(
                  fontSize: 15,
                  color: _selectedDateOfBirth != null
                      ? const Color(0xFF212121)
                      : const Color(0xFF9E9E9E),
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF9E9E9E)),
          ],
        ),
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
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
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
    required FocusNode focusNode,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF212121)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
        prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF1565C0)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF9E9E9E),
          ),
          onPressed: onToggleVisibility,
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
      onTap: _isLoading ? null : () => setState(() => _selectedGender = value),
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

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _registerAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF90CAF9),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
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
            Icon(Icons.person_add_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Đăng ký',
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