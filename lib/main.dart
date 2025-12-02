import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/home_page.dart';
import 'ui/onboarding_page.dart';

void main() {
  runApp(const MistbornApp());
}

class MistbornApp extends StatelessWidget {
  const MistbornApp({super.key});

  static ThemeData _buildMistbornTheme(bool isDark) {
    // Paleta mejorada inspirada en Mistborn - más elegante y vibrante
    const mistRed = Color(0xFFB71C1C);      // Rojo sangre más vivo
    const steelBlue = Color(0xFF37474F);    // Azul acero más suave
    const atiumGold = Color(0xFFFFB300);    // Dorado más brillante y cálido
    const ashGray = Color(0xFF424242);      // Gris ceniza más elegante
    const deepBlack = Color(0xFF121212);    // Negro material design
    const mistGray = Color(0xFF616161);     // Gris bruma más claro
    const copperBronze = Color(0xFFBF6000); // Bronce cobrizo para acentos
    const ironSilver = Color(0xFF78909C);   // Plata hierro para detalles
    
    if (isDark) {
      return ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: mistRed,
          onPrimary: Colors.white,
          secondary: atiumGold,
          onSecondary: deepBlack,
          surface: ashGray,
          onSurface: Colors.white70,
          background: deepBlack,
          onBackground: Colors.white70,
          tertiary: copperBronze,
          onTertiary: Colors.white,
          outline: ironSilver,
          error: Color(0xFFFF5722),
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: deepBlack,
        appBarTheme: AppBarTheme(
          backgroundColor: ashGray,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: mistRed.withOpacity(0.3),
        ),
        cardTheme: CardThemeData(
          color: mistGray,
          elevation: 8,
          shadowColor: mistRed.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: steelBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: mistRed,
            foregroundColor: Colors.white,
            elevation: 6,
            shadowColor: mistRed.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: atiumGold,
            side: BorderSide(color: atiumGold, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: mistGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: steelBlue),
            ),
          ),
        ),
      );
    } else {
      // Tema claro (mantenemos por compatibilidad)
      return ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: steelBlue,
          secondary: mistRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mistborn Dominance',

      // Tema Mistborn - atmósfera sombría y metálica
      theme: _buildMistbornTheme(false),
      darkTheme: _buildMistbornTheme(true),
      themeMode: ThemeMode.dark, // Modo oscuro por defecto para la atmósfera Mistborn

      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomePage(),
        '/onboarding': (context) => const OnboardingPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _animationController.forward();
    _checkFirstLaunch();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkFirstLaunch() async {
    await Future.delayed(const Duration(seconds: 2)); // Mostrar splash por 2 segundos
    
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = !(prefs.getBool('onboarding_completed') ?? false);
    
    if (mounted) {
      if (isFirstLaunch) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono principal
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFB71C1C).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFB300),
                    width: 4,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 80,
                  color: Color(0xFFFFB300),
                ),
              ),
              const SizedBox(height: 32),
              
              // Título
              const Text(
                'Mistborn Dominance',
                style: TextStyle(
                  color: Color(0xFFFFB300),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Subtítulo
              const Text(
                'Companion App',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Indicador de carga
              const CircularProgressIndicator(
                color: Color(0xFFFFB300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

