import 'package:flutter/material.dart';

const kPink = Color(0xFFFF6B9D);
const kPinkLight = Color(0xFFFFB3D1);
const kBlue = Color(0xFF6C63FF);
const kBlueLight = Color(0xFFB3AFFF);
const kGreen = Color(0xFF43E97B);
const kGreenLight = Color(0xFFA8F5C8);
const kBackground = Color(0xFF0F0F1A);
const kCard = Color(0xFF1A1A2E);
const kCardLight = Color(0xFF16213E);
const kOrange = Color(0xFFFF6B35);
const kOrangeLight = Color(0xFFFFB347);
const kPurple = Color(0xFF9B59B6);
const kPurpleLight = Color(0xFFD7BDE2);
const kRed = Color(0xFFE74C3C);
const kRedLight = Color(0xFFF1948A);
const kDarkGrey = Color(0xFF34495E);
const kLightGrey = Color(0xFF7F8C8D);

ThemeData buildTheme() {
  return ThemeData(
    scaffoldBackgroundColor: kBackground,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: kPink,
      secondary: kBlue,
      tertiary: kGreen,
      surface: kCard,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kCard,
      selectedItemColor: kPink,
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}

// Gradient dekorasyon — kartlar için
BoxDecoration gradientCard({List<Color>? colors}) {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: colors ?? [kCard, kCardLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
  );
}

// Pembe-mavi gradient
const LinearGradient pinkBlueGradient = LinearGradient(
  colors: [kPink, kBlue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Mavi-yeşil gradient
const LinearGradient blueGreenGradient = LinearGradient(
  colors: [kBlue, kGreen],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Pembe-yeşil gradient
const LinearGradient pinkGreenGradient = LinearGradient(
  colors: [kPink,kOrangeLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
// theme.dart içine ekle
const profileGradient = LinearGradient(
  colors: [kPink, kBlue, kGreen], // Profil ekranındaki renklerin aynısı
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
// Tüm türlerin renklerini merkezi olarak burada tutalım
final Map<String, List<Color>> allGenreColors = {
  'Pop': [kPink, kPinkLight],
  'Rock': [kOrange, kOrangeLight],
  'Electronic': [kBlue, kBlueLight],
  'Classical': [kPurple, kPurpleLight],
  'R&B': [kGreen, kGreenLight],
  'Hip-Hop': [kRed, kRedLight],
  'Arabesk': [Colors.deepPurple, Colors.purpleAccent],
  'Türk Pop': [kPink, kOrangeLight],
  'Türk Rap': [kDarkGrey, kLightGrey],
  'Anadolu Rock': [Colors.brown, Colors.orangeAccent],
};