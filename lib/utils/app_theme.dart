import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 브랜드 컬러 - 계획서 기반
  static const Color primaryGreen = Color(0xFF4CAF50);    // 건강, 신선함
  static const Color primaryGreenLight = Color(0xFF81C784);
  static const Color primaryGreenDark = Color(0xFF388E3C);
  
  static const Color secondaryOrange = Color(0xFFFF9800); // 식욕, 에너지
  static const Color secondaryOrangeLight = Color(0xFFFFB74D);
  
  static const Color coupangRed = Color(0xFFFA4E3E);      // 쿠팡 브랜드 컬러
  
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: backgroundLight,
    
    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      primaryContainer: primaryGreenLight,
      secondary: secondaryOrange,
      secondaryContainer: secondaryOrangeLight,
      surface: surfaceLight,
      background: backgroundLight,
      error: Colors.red.shade400,
    ),
    
    // AppBar 테마
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceLight,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.notoSansKr(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),
    
    // 텍스트 테마
    textTheme: TextTheme(
      displayLarge: GoogleFonts.notoSansKr(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.notoSansKr(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      headlineLarge: GoogleFonts.notoSansKr(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.notoSansKr(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.notoSansKr(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.notoSansKr(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.notoSansKr(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.notoSansKr(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodySmall: GoogleFonts.notoSansKr(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.notoSansKr(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
    ),
    
    // 버튼 테마
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.notoSansKr(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        side: const BorderSide(color: primaryGreen),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,
      ),
    ),
    
    // 입력 필드 테마
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      hintStyle: GoogleFonts.notoSansKr(
        color: textSecondary,
        fontSize: 14,
      ),
    ),
    
    // 카드 테마
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // 하단 네비게이션 바 테마
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primaryGreen,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.notoSansKr(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.notoSansKr(
        fontSize: 12,
      ),
    ),
    
    // Chip 테마
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade100,
      selectedColor: primaryGreen.withOpacity(0.2),
      labelStyle: GoogleFonts.notoSansKr(fontSize: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Divider 테마
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
    ),
  );

  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkBg = Color(0xFF121212);
  static const Color _darkSurface2 = Color(0xFF2C2C2C);

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: _darkBg,

    colorScheme: ColorScheme.dark(
      primary: primaryGreenLight,
      primaryContainer: primaryGreenDark,
      secondary: secondaryOrangeLight,
      surface: _darkSurface,
      error: Colors.red.shade300,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.notoSansKr(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.notoSansKr(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: GoogleFonts.notoSansKr(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      headlineLarge: GoogleFonts.notoSansKr(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
      headlineMedium: GoogleFonts.notoSansKr(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      titleLarge: GoogleFonts.notoSansKr(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: GoogleFonts.notoSansKr(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      bodyLarge: GoogleFonts.notoSansKr(fontSize: 16, color: Colors.white),
      bodyMedium: GoogleFonts.notoSansKr(fontSize: 14, color: Colors.white70),
      bodySmall: GoogleFonts.notoSansKr(fontSize: 12, color: Colors.white54),
      labelLarge: GoogleFonts.notoSansKr(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
    ),

    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreenLight, width: 2)),
      hintStyle: GoogleFonts.notoSansKr(color: Colors.white38, fontSize: 14),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: primaryGreenLight,
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: _darkSurface2,
      selectedColor: primaryGreen.withOpacity(0.3),
      labelStyle: GoogleFonts.notoSansKr(fontSize: 14, color: Colors.white70),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    dividerTheme: const DividerThemeData(color: Color(0xFF3A3A3A), thickness: 1),
  );
}
