import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../models/user_models.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                DesignSystem.primaryColor,
                DesignSystem.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Header
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignSystem.accentColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'SJ',
                    style: TextStyle(
                      fontSize: 48,
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
                'اختر دورك',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: DesignSystem.fontFamilyPrimary,
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: DesignSystem.spacingS),
              Text(
                'Choisissez votre rôle',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  fontFamily: DesignSystem.fontFamilySecondary,
                ),
              ),
              SizedBox(height: DesignSystem.spacingXL * 1.5),

              // Role Selection Cards
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSystem.spacingL,
                ),
                child: Column(
                  children: [
                    // Buyer Card
                    _RoleCard(
                      icon: Icons.shopping_cart_outlined,
                      title: 'مشتري',
                      subtitle: 'Acheteur',
                      description: 'Parcourez et achetez en gros',
                      isSelected: _selectedRole == UserRole.buyer,
                      onTap: () {
                        setState(() => _selectedRole = UserRole.buyer);
                      },
                    ),
                    SizedBox(height: DesignSystem.spacingL),

                    // Seller Card
                    _RoleCard(
                      icon: Icons.store_outlined,
                      title: 'بائع',
                      subtitle: 'Vendeur',
                      description: 'Vendez vos produits en gros',
                      isSelected: _selectedRole == UserRole.seller,
                      onTap: () {
                        setState(() => _selectedRole = UserRole.seller);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: DesignSystem.spacingXL * 2),

              // Continue Button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSystem.spacingL,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _selectedRole == null ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.accentColor,
                      disabledBackgroundColor: Colors.grey.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                      ),
                      elevation: DesignSystem.elevationM,
                    ),
                    child: Text(
                      'متابعة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selectedRole == null
                            ? Colors.grey
                            : DesignSystem.primaryColor,
                        fontFamily: DesignSystem.fontFamilyPrimary,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ),
              SizedBox(height: DesignSystem.spacingL),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_selectedRole == null) return;

    // Store role selection in auth provider
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    authProvider.setSelectedRole(_selectedRole!);

    // Navigate to login
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title; // Arabic
  final String subtitle; // French
  final String description; // French description
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(DesignSystem.spacingL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          border: Border.all(
            color: isSelected
                ? DesignSystem.accentColor
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? DesignSystem.accentColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? DesignSystem.accentColor.withOpacity(0.15)
                    : DesignSystem.primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected
                    ? DesignSystem.accentColor
                    : DesignSystem.primaryColor,
              ),
            ),
            SizedBox(width: DesignSystem.spacingL),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.primaryColor,
                      fontFamily: DesignSystem.fontFamilyPrimary,
                    ),
                  ),
                  SizedBox(height: DesignSystem.spacingXS),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: DesignSystem.accentColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: DesignSystem.fontFamilySecondary,
                    ),
                  ),
                  SizedBox(height: DesignSystem.spacingS),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignSystem.textSecondary,
                      fontFamily: DesignSystem.fontFamilySecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark (if selected)
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignSystem.accentColor,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
