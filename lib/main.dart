import 'package:flutter/material.dart';
// import 'package:music_graph_app/services/auth_service.dart'; // AuthService'i oluşturduğumuzu varsayıyorum
import 'theme.dart';
import 'screens/LoginScreen.dart'; // Login sayfasını import et
import 'screens/main_screen.dart'; // Yukarıda oluşturduğumuz MainScreen'i import et

void main() async {
  // SharedPreferences ve diğer async işlemler için gerekli (widgets binding)
  WidgetsFlutterBinding.ensureInitialized();

  // 1. HAFIZA KONTROLÜ (Oturum Yönetimi)
  // Daha önce AuthService'de yazdığımız "Giriş yapılmış mı?" fonksiyonunu çağıralım.
  // Not: Şimdilik hata vermesin diye elle 'false' veriyorum,
  // ama AuthService'i bağlayınca oradan çekmelisin.
  bool loggedIn = false; // loggedIn = await AuthService.isLoggedIn();

  runApp(MusicGraphApp(isLoggedIn: loggedIn));
}

class MusicGraphApp extends StatelessWidget {
  final bool isLoggedIn;
  const MusicGraphApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicGraph',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(), // theme.dart'taki Roboto fontu ve renk paleti kullanılıyor.

      // 2. AKILLI BAŞLANGIÇ
      // Eğer giriş yapılmışsa direkt Ana Menü (MainScreen), yoksa LoginScreen açılır.
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}