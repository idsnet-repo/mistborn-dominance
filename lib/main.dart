import 'package:flutter/material.dart';
import 'ui/home_page.dart';

void main() {
  runApp(const MistbornApp());
}

class MistbornApp extends StatelessWidget {
  const MistbornApp({super.key});

  static ThemeData _buildMistbornTheme(bool isDark) {
    // Colores inspirados en Mistborn
    const mistRed = Color(0xFF8B0000);      // Rojo bruma
    const steelBlue = Color(0xFF2F4F4F);    // Azul acero
    const atiumGold = Color(0xFFD4AF37);    // Dorado atium
    const ashGray = Color(0xFF2C2C2C);      // Gris ceniza
    const deepBlack = Color(0xFF0D0D0D);    // Negro profundo
    const mistGray = Color(0xFF404040);     // Gris bruma
    
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
          error: Color(0xFFFF6B6B),
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

      home: const HomePage(),
    );
  }
}

