import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/design_system.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/role_select_screen.dart';
import 'screens/login_screen.dart';

future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        title: 'SoukJomla',
        theme: DesignSystem.getTheme(),
        home: const SplashGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({Key? key}) : super(key: key);

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _tryAutoLogin();
  }

  void _initializeAnimation() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  Future<void> _tryAutoLogin() async {
    try {
      final authService = context.read<AuthService>();
      final isLoggedIn = await authService.tryAutoLogin();

      if (!mounted) return;

      // Brief delay for smooth splash transition
      await Future.delayed(const Duration(seconds: 1));
      
      await _fadeController.forward();

      if (!mounted) return;

      setState(() => _isInitialized = true);

      // Navigate after animation completes
      if (isLoggedIn) {
        _navigateToHome();
      } else {
        _navigateToRoleSelect();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'خطأ في تحميل التطبيق';
      });
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/main');
  }

  void _navigateToRoleSelect() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RoleSelectScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: DesignSystem.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'حدث خطأ',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isInitialized = false;
                  });
                  _fadeController.reset();
                  _tryAutoLogin();
                },
                child: const Text('إعادة محاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: DesignSystem.primaryColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logos/sj_logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'جاري تحضير التطبيق...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
