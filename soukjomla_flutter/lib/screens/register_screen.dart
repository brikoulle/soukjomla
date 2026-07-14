import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../models/user_models.dart';
import 'login_screen.dart';
import 'buyer_home_screen.dart';
import 'seller_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0; // 0: info, 1: credentials

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(DesignSystem.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignSystem.accentColor,
              ),
              child: Center(
                child: Text(
                  'SJ',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: DesignSystem.primaryColor,
                    fontFamily: DesignSystem.fontFamilyPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: DesignSystem.spacingXL),

            // Title & Step Indicator
            Text(
              'إنشاء حساب',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: DesignSystem.primaryColor,
                fontFamily: DesignSystem.fontFamilyPrimary,
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: DesignSystem.spacingS),
            Text(
              'الخطوة ${_currentStep + 1} من 2',
              style: TextStyle(
                fontSize: 14,
                color: DesignSystem.accentColor,
                fontFamily: DesignSystem.fontFamilySecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: DesignSystem.spacingXL),

            // Step 1: Personal Info
            if (_currentStep == 0) ...[
              _buildTextField(
                controller: _firstNameController,
                label: 'الاسم الأول',
                hint: 'محمد',
              ),
              SizedBox(height: DesignSystem.spacingL),
              _buildTextField(
                controller: _lastNameController,
                label: 'اسم العائلة',
                hint: 'أحمد',
              ),
              SizedBox(height: DesignSystem.spacingL),
              _buildTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                hint: '+212 6XX XXX XXX',
                keyboardType: TextInputType.phone,
              ),
            ],

            // Step 2: Credentials
            if (_currentStep == 1) ...[
              _buildTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                hint: 'email@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: DesignSystem.spacingL),
              _buildTextField(
                controller: _passwordController,
                label: 'كلمة المرور',
                hint: '••••••••',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: DesignSystem.textSecondary,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              SizedBox(height: DesignSystem.spacingL),
              _buildTextField(
                controller: _confirmPasswordController,
                label: 'تأكيد كلمة المرور',
                hint: '••••••••',
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: DesignSystem.textSecondary,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),
              ),
            ],

            SizedBox(height: DesignSystem.spacingL),

            // Error Message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(DesignSystem.spacingM),
                decoration: BoxDecoration(
                  color: DesignSystem.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  border: Border.all(
                    color: DesignSystem.errorColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: DesignSystem.errorColor,
                    fontFamily: DesignSystem.fontFamilySecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            SizedBox(height: DesignSystem.spacingL),

            // Navigation Buttons
            Row(
              children: [
                // Back Button
                if (_currentStep > 0)
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() => _currentStep--);
                                setState(() => _errorMessage = null);
                              },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(DesignSystem.radiusL),
                          ),
                          side: const BorderSide(
                            color: DesignSystem.primaryColor,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'رجوع',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: DesignSystem.primaryColor,
                            fontFamily: DesignSystem.fontFamilyPrimary,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: DesignSystem.spacingM),

                // Next/Register Button
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_currentStep == 0
                              ? _handleNextStep
                              : _handleRegister),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.primaryColor,
                        disabledBackgroundColor: Colors.grey.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(DesignSystem.radiusL),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.8),
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _currentStep == 0 ? 'التالي' : 'تسجيل',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: DesignSystem.fontFamilyPrimary,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignSystem.spacingL),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  'هل لديك حساب بالفعل؟',
                  style: TextStyle(
                    color: DesignSystem.textSecondary,
                    fontFamily: DesignSystem.fontFamilySecondary,
                  ),
                ),
                SizedBox(width: DesignSystem.spacingS),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'دخول',
                    style: TextStyle(
                      color: DesignSystem.accentColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: DesignSystem.fontFamilySecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DesignSystem.primaryColor,
            fontFamily: DesignSystem.fontFamilyPrimary,
          ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: DesignSystem.spacingS),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.ltr,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              borderSide: BorderSide(
                color: DesignSystem.textHint.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              borderSide: BorderSide(
                color: DesignSystem.textHint.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              borderSide: const BorderSide(
                color: DesignSystem.primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: DesignSystem.spacingM,
              vertical: DesignSystem.spacingM,
            ),
          ),
        ),
      ],
    );
  }

  void _handleNextStep() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      setState(() => _errorMessage = 'Veuillez remplir tous les champs');
      return;
    }
    setState(() {
      _currentStep = 1;
      _errorMessage = null;
    });
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'Veuillez remplir tous les champs');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Les mots de passe ne correspondent pas');
      return;
    }

    if (password.length < 8) {
      setState(() =>
          _errorMessage = 'Le mot de passe doit contenir au moins 8 caractères');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      
      await authProvider.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      if (!mounted) return;

      // Navigate based on selected role
      final user = authProvider.user;
      if (user != null) {
        final targetScreen = user.role == UserRole.buyer
            ? const BuyerHomeScreen()
            : const SellerDashboardScreen();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => targetScreen),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur d\'inscription: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
}
