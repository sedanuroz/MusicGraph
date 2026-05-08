import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _userId   = '';
  bool _isLoading  = true;

  // Neo4j'den çekilecek gerçek veriler
  Map<String, dynamic>? _profileData;
  List<Map<String, dynamic>> _topSongs = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final name = await AuthService.getUserName();
    final id   = await AuthService.getUserId();
    setState(() {
      _userName = name ?? 'Kullanıcı';
      _userId   = id   ?? '';
    });

    if (_userId.isNotEmpty) {
      await _fetchFromNeo4j();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchFromNeo4j() async {
    setState(() => _isLoading = true);
    // Neo4j'den profil ve top şarkıları çek
    final profile  = await ApiService.getUserProfile(_userId);
    final topSongs = await ApiService.getTopSongs(_userId);
    setState(() {
      _profileData = profile;
      _topSongs    = topSongs;
      _isLoading   = false;
    });
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPink))
          : RefreshIndicator(
        color: kPink,
        onRefresh: _fetchFromNeo4j,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── 1. HEADER ───────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 40.0, horizontal: 20.0),
                decoration: gradientCard(colors: [kCard, kCardLight]),
                child: Column(
                  children: [
                    // Profil avatarı
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: blueGreenGradient,
                          ),
                        ),
                        Text(
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(_userName, style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('#$_userId',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13)),

                    // Top genre badge
                    if (_profileData?['topGenre'] != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: kPink.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: kPink.withOpacity(0.4)),
                        ),
                        child: Text(
                          '🎵 ${_profileData!['topGenre']}',
                          style: const TextStyle(
                              color: kPink, fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // Çıkış butonu
                    OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout_rounded, size: 16),
                      label: const Text('Çıkış Yap',
                          style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kRed,
                        side: const BorderSide(color: kRed),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── 2. İSTATİSTİKLER ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Müzik Grafiğin 📊',
                        style: TextStyle(color: Colors.white,
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard(
                          '${_profileData?['likedCount'] ?? 0}',
                          'Beğenilen',
                          kPink,
                        ),
                        _buildStatCard(
                          '${_profileData?['followerCount'] ?? 0}',
                          'Takipçi',
                          kBlue,
                        ),
                        _buildStatCard(
                          '${_profileData?['followingCount'] ?? 0}',
                          'Takip',
                          kGreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ── 3. EN ÇOK DİNLENENLER ───────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('En Çok Dinlediğin Şarkılar 🎹',
                        style: TextStyle(color: Colors.white,
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    if (_topSongs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: gradientCard(),
                        child: const Text(
                          'Henüz dinleme geçmişin yok.\nŞarkı dinlemeye başla!',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 13),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _topSongs.length,
                        itemBuilder: (context, index) {
                          final song = _topSongs[index];
                          // Her sıraya farklı renk ver
                          final colors = [kPink, kBlue, kGreen,
                            kPinkLight, kBlueLight];
                          final color =
                          colors[index % colors.length];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: gradientCard(
                                colors: [kCard, kCardLight]),
                            child: ListTile(
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 46, height: 46,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                      color: color.withOpacity(0.3)),
                                ),
                                child: Icon(Icons.music_note,
                                    color: color, size: 20),
                              ),
                              title: Text(song['title'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                song['artist'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12),
                              ),
                              trailing: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  const Text('🔥',
                                      style: TextStyle(fontSize: 10)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${song['playCount']}x',
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color accentColor) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 3,
      padding: const EdgeInsets.all(16.0),
      decoration: gradientCard(colors: [kCard, kCardLight]),
      child: Column(
        children: [
          Text(value,
            style: TextStyle(color: accentColor, fontSize: 22,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}