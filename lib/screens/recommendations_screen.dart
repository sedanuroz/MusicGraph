import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'user_profile_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  String? currentUserId;

  List<Map<String, dynamic>> friends      = [];
  List<Map<String, dynamic>> tasteTwins   = [];
  List<Map<String, dynamic>> socialRadar  = [];
  List<Map<String, dynamic>> discoverUsers = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final uid = await AuthService.getUserId();
    if (uid == null) {
      if (mounted) setState(() => loading = false);
      return;
    }
    if (mounted) setState(() => currentUserId = uid);
    await _fetchAll(uid);
  }

  // Yenilenme Mantığı İyileştirildi: Silent Refresh
  Future<void> _fetchAll(String uid) async {
    // Eğer halihazırda veri varsa tam ekran loading gösterme (ekran zıplamasını önler)
    bool isInitial = friends.isEmpty && tasteTwins.isEmpty && socialRadar.isEmpty && discoverUsers.isEmpty;
    if (isInitial) {
      if (mounted) setState(() => loading = true);
    }

    try {
      final f  = await ApiService.getFriends(uid);
      final tw = await ApiService.getTasteTwins(uid);
      final sr = await ApiService.getSocialRadar(uid);
      final du = await ApiService.getDiscoverUsers(uid);

      if (mounted) {
        setState(() {
          friends       = f;
          tasteTwins    = tw;
          socialRadar   = sr;
          discoverUsers = du;
          loading       = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _addFriend(String targetId) async {
    if (currentUserId == null) return;
    await ApiService.addFriend(currentUserId!, targetId);
    // Arkadaş ekleyince sessizce listeyi tazele
    await _fetchAll(currentUserId!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Arkadaş eklendi! 🎉'),
        backgroundColor: kGreen.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  void _goToProfile(String userId, String userName) {
    if (currentUserId == null) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => UserProfileScreen(
        userId: userId,
        userName: userName,
        currentUserId: currentUserId!,
      ),
    )).then((_) {
      // Profil sayfasından geri gelince verileri tazele
      if (currentUserId != null) _fetchAll(currentUserId!);
    });
  }

  void _showFriendsWhoLiked(Map<String, dynamic> song) {
    if (currentUserId == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FriendsWhoLikedSheet(
        song: song,
        currentUserId: currentUserId!,
        onGoToProfile: _goToProfile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
              child: ShaderMask(
                shaderCallback: (b) => blueGreenGradient.createShader(b),
                child: const Text('Öneri ✨', style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text('Sana özel müzik ve insan keşfi',
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
            ),

            Expanded(
              child: currentUserId == null
                  ? const Center(child: Text('Giriş yapman gerekiyor',
                  style: TextStyle(color: Colors.white54)))
                  : loading && friends.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: kGreen))
                  : RefreshIndicator(
                color: kGreen,
                backgroundColor: kCard,
                onRefresh: () => _fetchAll(currentUserId!),
                child: ListView(
                  // Liste kısa olsa bile her zaman çekilebilir olması için (Düzgün yenilenme)
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [

                    _sectionHeader('👥 Arkadaşlarım', kBlue,
                        '${friends.length} arkadaş'),
                    if (friends.isEmpty)
                      _emptyCard('Henüz arkadaşın yok.\nAşağıdan birini ekle!')
                    else
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: friends.length,
                          itemBuilder: (ctx, i) =>
                              _friendChip(friends[i]),
                        ),
                      ),

                    const SizedBox(height: 24),

                    _sectionHeader('🎵 Zevk İkizlerin', kPink,
                        'Seninle aynı şarkıları beğenenler'),
                    if (tasteTwins.isEmpty)
                      _emptyCard('Henüz ortak beğeni bulunamadı.\nDaha fazla şarkı beğen!')
                    else
                      ...tasteTwins.map((u) => _userCard(
                        userId: u['id'] ?? '',
                        name: u['name'] ?? '',
                        subtitle: '${u['commonLikes']} ortak şarkı'
                            '${u['topGenre'] != null ? ' • ${u['topGenre']}' : ''}',
                        accentColor: kPink,
                        onTap: () => _goToProfile(u['id'], u['name']),
                        onAction: () => _addFriend(u['id']),
                        actionLabel: 'Arkadaş Ekle',
                      )),

                    const SizedBox(height: 24),

                    _sectionHeader('📡 Arkadaşlarının Radarı', kBlue,
                        'Arkadaşlarının dinledikleri — şarkıya tıkla!'),
                    if (socialRadar.isEmpty)
                      _emptyCard('Arkadaş ekle, öneriler burada görünecek! 👆')
                    else
                      ...socialRadar.map((song) => _radarSongCard(song)),

                    const SizedBox(height: 24),

                    _sectionHeader('🔍 Keşfedilecek Profiller',kPinkLight,
                        'Henüz arkadaş olmadıklarından'),
                    if (discoverUsers.isEmpty)
                      _emptyCard('Keşfedilecek kullanıcı kalmadı 🎉')
                    else
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: discoverUsers.length,
                          itemBuilder: (ctx, i) =>
                              _discoverCard(discoverUsers[i]),
                        ),
                      ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Yardımcı widget metotları (Aynı bırakıldı)
  Widget _sectionHeader(String title, Color color, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(
          color: color, fontSize: 17, fontWeight: FontWeight.bold)),
      Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
    ]),
  );

  Widget _emptyCard(String msg) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: gradientCard(),
    child: Text(msg, style: const TextStyle(color: Colors.white38, fontSize: 13)),
  );

  Widget _friendChip(Map<String, dynamic> friend) => GestureDetector(
    onTap: () => _goToProfile(friend['id'], friend['name']),
    child: Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      child: Column(children: [
        Container(
          width: 52, height: 52,
          decoration: const BoxDecoration(
              gradient: blueGreenGradient, shape: BoxShape.circle),
          child: Center(child: Text(
            (friend['name'] as String? ?? '?').isNotEmpty
                ? friend['name'][0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.bold, fontSize: 20),
          )),
        ),
        const SizedBox(height: 4),
        Text(friend['name'] ?? '', style: const TextStyle(
            color: Colors.white70, fontSize: 11),
            maxLines: 1, overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center),
      ]),
    ),
  );

  Widget _userCard({
    required String userId,
    required String name,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
    required VoidCallback onAction,
    required String actionLabel,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: gradientCard(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: accentColor.withOpacity(0.5)),
          ),
          child: Center(child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(color: accentColor,
                fontWeight: FontWeight.bold, fontSize: 18),
          )),
        ),
        title: Text(name, style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: GestureDetector(
          onTap: onAction,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.5)),
            ),
            child: Text(actionLabel, style: TextStyle(
                color: accentColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    ),
  );

  Widget _radarSongCard(Map<String, dynamic> song) => GestureDetector(
    onTap: () => _showFriendsWhoLiked(song),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: gradientCard(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              gradient: blueGreenGradient,
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.music_note, color: Colors.white, size: 20),
        ),
        title: Text(song['title'] ?? '', style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
            '${song['artist'] ?? ''}${song['genre'] != null ? ' • ${song['genre']}' : ''}',
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBlue.withOpacity(0.4)),
            ),
            child: Text('${song['friendCount']} arkadaş',
                style: const TextStyle(color: kBlue, fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
        ]),
      ),
    ),
  );

  Widget _discoverCard(Map<String, dynamic> user) => GestureDetector(
    onTap: () => _goToProfile(user['id'], user['name']),
    child: Container(
      width: 125,
      margin: const EdgeInsets.only(right: 12),
      decoration: gradientCard(),
      padding: const EdgeInsets.all(12),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 52, height: 52,
          decoration: const BoxDecoration(
              gradient: pinkGreenGradient, shape: BoxShape.circle),
          child: Center(child: Text(
            (user['name'] as String? ?? '?').isNotEmpty
                ? user['name'][0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.bold, fontSize: 22),
          )),
        ),
        const SizedBox(height: 6),
        Text(user['name'] ?? '', style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 1, overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center),
        if (user['topGenre'] != null)
          Text(user['topGenre'], style: const TextStyle(
              color: Colors.white38, fontSize: 10),
              maxLines: 1, overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _addFriend(user['id']),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                gradient: pinkGreenGradient,
                borderRadius: BorderRadius.circular(12)),
            child: const Text('+ Arkadaş', style: TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    ),
  );
}

class _FriendsWhoLikedSheet extends StatefulWidget {
  final Map<String, dynamic> song;
  final String currentUserId;
  final Function(String, String) onGoToProfile;

  const _FriendsWhoLikedSheet({
    required this.song,
    required this.currentUserId,
    required this.onGoToProfile,
  });

  @override
  State<_FriendsWhoLikedSheet> createState() => _FriendsWhoLikedSheetState();
}

class _FriendsWhoLikedSheetState extends State<_FriendsWhoLikedSheet> {
  List<Map<String, dynamic>> friends = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final result = await ApiService.getFriendsWhoLiked(
        widget.song['id'], widget.currentUserId);
    if (mounted) {
      setState(() {
        friends = result;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                  gradient: blueGreenGradient,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.music_note, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.song['title'] ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(widget.song['artist'] ?? '',
                      style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 20),
          Text('Arkadaşlarının Etkileşimi',
              style: TextStyle(
                  color: kBlue, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: kBlue),
            ))
          else if (friends.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Bu şarkı henüz kimsenin radarına girmemiş.',
                  style: TextStyle(color: Colors.white38)),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final f = friends[index];
                  final int playCount = f['playCount'] ?? 0;
                  final bool isLiked = f['isLiked'] ?? false;

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onGoToProfile(f['id'], f['name']);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: gradientCard(),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 40, height: 40,
                          decoration: const BoxDecoration(
                              gradient: blueGreenGradient, shape: BoxShape.circle),
                          child: Center(child: Text(
                            (f['name'] as String? ?? '?').isNotEmpty
                                ? f['name'][0].toUpperCase() : '?',
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          )),
                        ),
                        title: Text(f['name'] ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.headphones, color: Colors.white38, size: 14),
                            const SizedBox(width: 4),
                            Text('$playCount kez dinledi',
                                style: const TextStyle(color: Colors.white38, fontSize: 11)),
                          ],
                        ),
                        trailing: isLiked
                            ? const Icon(Icons.favorite, color: kPink, size: 20)
                            : const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}