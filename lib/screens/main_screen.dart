import 'package:flutter/material.dart';
import '../theme.dart'; // theme.dart import'u (klasör yapısına dikkat)
// Boş sayfa placeholderlarını import et (Bunlar sende olmalı veya oluşturmalısın)
import 'home_screen.dart';
import 'discover_screen.dart';
import 'recommendations_screen.dart';
import 'profile_screen.dart'; // YENİ: Profil Sayfası import'u

// Bu dosya, senin verdiğin MainNav'ın tam ve güncellenmiş halidir.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  // YENİ: Profil Sayfası 4. tab olarak listeye eklendi.
  final List<Widget> _screens = const [
    HomeScreen(),
    DiscoverScreen(),
    RecommendationsScreen(),
    ProfileScreen(), // YENİ: Kendi profilimizi göreceğimiz sayfa
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold buildTheme'deki scaffoldBackgroundColor'ı kullanıyor.
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        // Senin kodundaki şık beyaz çizgi dekorasyonu
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            // Senin kodundaki 'Ara' (HomeScreen) yerine 'Ana Sayfa' daha uygun.
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), // İkonu da düzelttik
              activeIcon: Icon(Icons.home, color: kPink), // Temaya uygun kPink vurgusu
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore, color: kPink),
              label: 'Keşfet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.recommend_outlined),
              activeIcon: Icon(Icons.recommend, color: kPink),
              label: 'Öneri',
            ),
            // YENİ: Profil Menü İtem'ı
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: kPink),
              label: 'Profil', // Bu sayede kendi profilimize ulaşabileceğiz.
            ),
          ],
        ),
      ),
    );
  }
}