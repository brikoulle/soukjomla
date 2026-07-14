import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../models/user_models.dart';
import 'register_screen.dart';
import 'buyer_home_screen.dart';
import 'seller_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

            // Title
            Text(
              'تسجيل الدخول',
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
              'Connectez-vous à votre compte',
              style: TextStyle(
                fontSize: 14,
                color: DesignSystem.textSecondary,
                fontFamily: DesignSystem.fontFamilySecondary,
              ),
            ),
            SizedBox(height: DesignSystem.spacingXL * 1.5),

            // Email Field
            _buildTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              hint: 'email@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: DesignSystem.spacingL),

            // Password Field
            _buildTextField(
              controller: _passwordController,
              label: 'كلمة المرور',
              hint: '••••••••',
              icon: Icons.lock_outlined,
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

            // Login Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.primaryColor,
                  disabledBackgroundColor: Colors.grey.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusL),
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
                        'دخول',
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
            SizedBox(height: DesignSystem.spacingL),

            // Signup Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  'ليس لديك حساب؟',
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
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'قم بالتسجيل',
                    style: TextStyle(
                      color: DesignSystem.accentColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: DesignSystem.fontFamilySecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignSystem.spacingL),

            // Debug info (dev only)
            if (AppConfig.isDevelopment)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(DesignSystem.spacingM),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                ),
                child: Text(
                  AppConfig.environmentInfo,
                  style: TextStyle(
                    fontSize: 10,
                    color: DesignSystem.textSecondary,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
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
    required IconData icon,
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
            prefixIcon: Icon(icon, color: DesignSystem.primaryColor),
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

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Veuillez remplir tous les champs');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      await authProvider.login(email, password);

      if (!mounted) return;

      // Navigate based on user role
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
        _errorMessage = 'Erreur de connexion: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
}
