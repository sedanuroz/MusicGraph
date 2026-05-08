import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
// 1. Detay sayfası import edildi
import 'song_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String currentUserId;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.currentUserId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> likedSongs = [];
  bool isFriend      = false;
  bool loading       = true;
  bool actionLoading = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    if (!mounted) return;
    setState(() => loading = true);
    final p  = await ApiService.getUserProfile(widget.userId);
    final f  = await ApiService.checkFriendship(widget.currentUserId, widget.userId);
    final ls = await ApiService.getLikedSongs(widget.userId);
    if (mounted) {
      setState(() {
        profile    = p;
        isFriend   = f;
        likedSongs = ls;
        loading    = false;
      });
    }
  }

  // 2. Şarkı detayına gitme ve dönüşte yenileme fonksiyonu
  void _goToSong(String songId, String songTitle) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => SongDetailScreen(songId: songId, songTitle: songTitle),
    )).then((_) => _fetchAll()); // Detaydan dönünce profili yeniler
  }

  Future<void> _toggleFriend() async {
    setState(() => actionLoading = true);
    if (isFriend) {
      await ApiService.removeFriend(widget.currentUserId, widget.userId);
    } else {
      await ApiService.addFriend(widget.currentUserId, widget.userId);
    }
    final f = await ApiService.checkFriendship(widget.currentUserId, widget.userId);
    final p = await ApiService.getUserProfile(widget.userId);
    if (mounted) {
      setState(() {
        isFriend      = f;
        profile       = p;
        actionLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isFriend ? 'Arkadaş eklendi! 🎉' : 'Arkadaşlık kaldırıldı'),
        backgroundColor: (isFriend ? kGreen : kRed).withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator(color: kPink))
          : profile == null
          ? const Center(child: Text('Profil bulunamadı',
          style: TextStyle(color: Colors.white54)))
          : NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: kBackground,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'Son Dinlenenler'),
                Tab(text: 'Beğenilenler'),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPink, kBlue, kGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white38, width: 2),
                        ),
                        child: Center(child: Text(
                          widget.userName.isNotEmpty
                              ? widget.userName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white,
                              fontSize: 32, fontWeight: FontWeight.bold),
                        )),
                      ),
                      const SizedBox(height: 5),
                      Text(profile!['name'] ?? widget.userName,
                          style: const TextStyle(color: Colors.white,
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      if (profile!['topGenre'] != null) ...[
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('🎵 ${profile!['topGenre']}',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 11)),
                        ),
                      ],
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _stat('${profile!['likedCount'] ?? 0}', 'Beğeni'),
                          const SizedBox(width: 24),
                          _stat('${profile!['friendCount'] ?? 0}', 'Arkadaş'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: actionLoading ? null : _toggleFriend,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 6),
                          decoration: BoxDecoration(
                            color: isFriend ? Colors.white24 : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: actionLoading
                              ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: kPink))
                              : Text(
                            isFriend ? '✓ Arkadaşsınız' : '+ Arkadaş Ekle',
                            style: TextStyle(
                              color: isFriend ? Colors.white70 : kPink,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSongList(
              songs: profile!['recentSongs'] as List? ?? [],
              emptyMsg: 'Dinleme geçmişi yok',
              showPlayCount: true,
            ),
            _buildSongList(
              songs: likedSongs,
              emptyMsg: 'Henüz beğenilen şarkı yok',
              showPlayCount: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongList({
    required List songs,
    required String emptyMsg,
    required bool showPlayCount,
  }) {
    if (songs.isEmpty) {
      return Center(child: Text(emptyMsg,
          style: const TextStyle(color: Colors.white38)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: songs.length,
      itemBuilder: (ctx, i) {
        final song = songs[i] as Map<String, dynamic>;
        final colors = [kPink, kBlue, kGreen, kPinkLight, kBlueLight];
        final color = colors[i % colors.length];

        final int playCount = song['playCount'] ?? 0;
        final bool isLiked = song['isLiked'] ?? (!showPlayCount);

        // 3. Kartın tıklanabilir olması sağlandı
        return GestureDetector(
          onTap: () => _goToSong(song['id'] ?? song['songId'] ?? '', song['title'] ?? ''),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: gradientCard(),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(Icons.music_note, color: color, size: 18),
              ),
              title: Text(song['title'] ?? '', style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${song['artist'] ?? ''}${song['genre'] != null ? ' • ${song['genre']}' : ''}',
                      style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.headphones, color: Colors.white38, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '$playCount kez dinledi',
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: isLiked
                  ? Icon(Icons.favorite, color: kPink.withOpacity(0.9), size: 18)
                  : const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
            ),
          ),
        );
      },
    );
  }

  Widget _stat(String value, String label) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white,
        fontSize: 16, fontWeight: FontWeight.bold)),
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
  ]);
}