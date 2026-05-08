import 'package:flutter/material.dart';
// Proje klasör yapına göre import yollarını kontrol etmeyi unutma:
import '../theme.dart'; // Renkler ve gradientler için
import '../services/auth_service.dart'; // Oturum saklama servisi
import 'main_screen.dart'; // Girişten sonra gideceğimiz ana ekran

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  // VERİTABANI MOCK VERİSİ (Neo4j'de oluşturduğumuz 30 kullanıcıdan bazıları)
  // Test etmek için buradaki e-postaları kullanabilirsin.
  final Map<String, Map<String, String>> _validUsers = {
    'seda@atu.edu.tr': {'id': 'user_0', 'name': 'Seda Nur Öz'}, // Pop/Rap Persona
    'emre@mail.com':   {'id': 'user_1', 'name': 'Emre Yılmaz'}, // Arabesk/TSM Persona
    'betul@mail.com':  {'id': 'user_2', 'name': 'Betül Sare'},  // Pop/Rap Persona
    'halil@mail.com':  {'id': 'user_3', 'name': 'Halil Öztürk'},// Arabesk/TSM Persona
    'sena@mail.com':   {'id': 'user_4', 'name': 'Sena Çiftçi'}, // Rock Persona
  };

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // GİRİŞ MANTIĞI
  Future<void> _login() async {
    final email = _emailController.text.trim();

    // 1. Validasyon
    if (email.isEmpty) {
      _showSnackBar('Lütfen e-postanı gir ✍️', kRed);
      return;
    }

    setState(() => _isLoading = true);

    // 2. Network Simülasyonu (Veritabanına soruyormuş gibi 2 sn bekleyelim)
    await Future.delayed(const Duration(seconds: 2));

    // 3. Mock Veritabanında Kontrol
    final userData = _validUsers[email];

    if (userData != null) {
      // ✅ BAŞARILI GİRİŞ

      // A. AuthService'i kullanarak oturumu telefon hafızasına (SharedPrefs) kaydet
      await AuthService.saveUserSession(userData['id']!, userData['name']!);

      _showSnackBar('Hoş geldin, ${userData['name']}! ❤️', kGreen);

      // B. MainScreen'e yönlendir ve login sayfasını geri yığınından kaldır (pushReplacement)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } else {
      // ❌ BAŞARISIZ GİRİŞ
      _showSnackBar('Bu e-posta kayıtlı görünmüyor. Tekrar dener misin? 🧐', kRed);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // Bilgi mesajı gösteren SnackBar
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // kBackground: Temandaki koyu lacivert arka plan
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView( // Klavye açılınca taşma olmaması için
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // --- BAŞLIK VE LOGO BÖLÜMÜ ---
                Column(
                  children: [
                    // Müzik İkonu — pembe-mavi gradient
                    ShaderMask(
                      shaderCallback: (b) => pinkBlueGradient.createShader(b),
                      child: const Icon(
                        Icons.headset_mic_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // "Graph Music" başlığı — Roboto fontu temadan geliyor
                    ShaderMask(
                      shaderCallback: (b) => pinkBlueGradient.createShader(b),
                      child: const Text(
                        'Graph Music ✨',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Müzik grafiğini keşfetmek için giriş yap.',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 70),

                // --- GİRİŞ ALANI (Input Field) ---
                // kCard renginde (koyu mavi), yuvarlak hatlı
                Container(
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(), // Enter'a basınca giriş yap
                    decoration: InputDecoration(
                      hintText: 'Örn: seda@atu.edu.tr',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                      prefixIcon: const Icon(Icons.email_outlined, color: kBlue),
                      contentPadding: const EdgeInsets.all(20),
                      border: InputBorder.none, // Varsayılan border'ı kaldır
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- GİRİŞ YAP BUTONU ---
                // pinkBlueGradient ile dolu, gölgeli büyük buton
                GestureDetector(
                  onTap: _isLoading ? null : _login, // Yükleniyorsa tıklamayı engelle
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: _isLoading ? null : pinkBlueGradient,
                      color: _isLoading ? kCard : null, // Yüklenirken grileşsin
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isLoading ? [] : [
                        BoxShadow(
                          color: kBlue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Giriş Yap',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Alt bilgi (Opsiyonel)
                const Text(
                  'ATU Müzik Grafiği Projesi © 2024',
                  style: TextStyle(color: Colors.white24, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}