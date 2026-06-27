import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFE85D04);
  static const Color lightOrange = Color(0xFFF47920);
  static const Color background = Color(0xFFF5F0EB);
  static const Color infoCardBg = Color(0xFFFFF0E6);
  static const Color statusAguardando = Color(0xFFF59E0B);
  static const Color statusChamado = Color(0xFFE53E3E);
  static const Color statusAtendido = Color(0xFF22C55E);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B6B6B);

  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryOrange,
          primary: primaryOrange,
        ),
        scaffoldBackgroundColor: background,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: textDark),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: primaryOrange,
          unselectedItemColor: Color(0xFF9CA3AF),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: TextStyle(fontSize: 11),
        ),
      );
}
