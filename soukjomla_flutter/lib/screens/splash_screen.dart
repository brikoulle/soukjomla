import 'package:flutter/material.dart';
import '../config/design_system.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SJ Logo
            Image.asset(
              'assets/logos/sj_logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 32),
            // App Name
            Text(
              'SoukJomla',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              'البيع بالجملة بسهولة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: DesignSystem.accentColor,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
