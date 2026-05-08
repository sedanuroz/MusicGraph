import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userIdKey = 'userId';
  static const String _userNameKey = 'userName'; // Bunu zaten tanımlamıştık

  // Oturum bilgilerini kaydet
  static Future<void> saveUserSession(String id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userIdKey, id);
    await prefs.setString(_userNameKey, name);
  }

  // Oturumu kapat
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Kullanıcı giriş yapmış mı kontrol et
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Kayıtlı User ID'yi getir
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // === EKSİK OLAN VE HATAYA SEBEP OLAN KISIM BURASIYDI, BUNU EKLE ===
  // Kayıtlı Kullanıcı Adını getir
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }
}