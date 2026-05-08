import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'artist_screen.dart';
import 'song_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> songResults   = [];
  List<Map<String, dynamic>> artistResults = [];
  bool searching  = false;
  bool hasSearched = false;

  String userName   = '';
  String userId     = '';
  List<Map<String, dynamic>> topSongs   = [];
  List<Map<String, dynamic>> likedSongs = [];
  bool loadingPersonal = true;
  Map<String, dynamic>? nowPlaying;

  @override
  void initState() {
    super.initState();
    _loadPersonal();
  }

  // Verileri API'den tazeleyen ana fonksiyon
  Future<void> _loadPersonal() async {
    // Eğer pull-to-refresh yapılıyorsa loadingPersonal true olmamalı ki ekran zıplamasın
    final name = await AuthService.getUserName();
    final id   = await AuthService.getUserId();

    if (mounted) {
      setState(() {
        userName = name ?? 'Kullanıcı';
        userId   = id   ?? '';
      });
    }

    if (userId.isEmpty) {
      if (mounted) setState(() => loadingPersonal = false);
      return;
    }

    // Backend'den en güncel verileri çekiyoruz
    final top   = await ApiService.getTopSongs(userId);
    final liked = await ApiService.getLikedSongs(userId);

    if (mounted) {
      setState(() {
        topSongs        = top;
        likedSongs      = liked; // Veritabanındaki güncel beğeni listesi buraya aktarılır
        nowPlaying      = top.isNotEmpty ? top.first : null;
        loadingPersonal = false;
      });
    }
  }

  Future<void> search(String q) async {
    if (q.trim().isEmpty) {
      setState(() { songResults = []; artistResults = []; hasSearched = false; });
      return;
    }
    setState(() => searching = true);
    final songs   = await ApiService.searchSongs(q);
    final artists = await ApiService.searchArtists(q);
    setState(() {
      songResults   = songs;
      artistResults = artists;
      searching     = false;
      hasSearched   = true;
    });
  }

  // Detay sayfasına gidiş ve dönüşte yenileme
  void _goToSong(String songId, String songTitle) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => SongDetailScreen(songId: songId, songTitle: songTitle),
    )).then((_) => _loadPersonal()); // Detaydan dönünce verileri tazeler
  }

  // Sanatçı sayfasına gidiş ve dönüşte yenileme (YENİ EKLENDİ)
  void _goToArtist(String artistId, String artistName) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ArtistScreen(artistId: artistId, artistName: artistName),
    )).then((_) => _loadPersonal()); // Sanatçı sayfasında bir şey beğenilirse dönünce yeniler
  }

  @override
  Widget build(BuildContext context) {
    // build içinde verileri gruplama (State değiştikçe burası otomatik yeniden hesaplanır)
    Map<String, List<Map<String, dynamic>>> groupedLikedSongs = {};
    for (var song in likedSongs) {
      String genre = song['genre'] ?? 'Diğer';
      if (!groupedLikedSongs.containsKey(genre)) {
        groupedLikedSongs[genre] = [];
      }
      groupedLikedSongs[genre]!.add(song);
    }
    final genres = groupedLikedSongs.keys.toList();

    return Scaffold(
      body: SafeArea(
        // Pull-to-refresh özelliği eklendi
        child: RefreshIndicator(
          color: kGreen,
          backgroundColor: kCard,
          onRefresh: _loadPersonal,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Boş olsa bile çekilebilmesi için
            slivers: [
              // ── 1. BAŞLIK VE ARAMA KUTUSU ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hoş geldin 👋', style: TextStyle(color: Colors.white54, fontSize: 14)),
                              ShaderMask(
                                shaderCallback: (b) => profileGradient.createShader(b),
                                child: Text(userName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: kCard, shape: BoxShape.circle, border: Border.all(color: Colors.white10)),
                            child: const Icon(Icons.headphones_rounded, color: kBlue, size: 24),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: search,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Şarkı, sanatçı veya tür ara...',
                            hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                            prefixIcon: searching
                                ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: kGreen, strokeWidth: 2)))
                                : const Icon(Icons.search_rounded, color: kGreen, size: 22),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. ARAMA SONUÇLARI ─────────────────────────────────────
              if (hasSearched) ...[
                if (artistResults.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 12),
                      child: Text('Sanatçılar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: artistResults.length,
                        itemBuilder: (context, i) {
                          final ar = artistResults[i];
                          return GestureDetector(
                            onTap: () => _goToArtist(ar['id'], ar['name']), // Güncellendi
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(children: [
                                Container(
                                  width: 64, height: 64,
                                  decoration: const BoxDecoration(gradient: blueGreenGradient, shape: BoxShape.circle),
                                  child: Center(child: Text((ar['name'] as String)[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                                ),
                                const SizedBox(height: 6),
                                Text(ar['name'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 1, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                if (songResults.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Text('Şarkılar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, i) {
                        final song = songResults[i];
                        return GestureDetector(
                          onTap: () => _goToSong(song['id'], song['title']),
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            decoration: gradientCard(),
                            child: ListTile(
                              leading: Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(gradient: profileGradient, borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.music_note, color: Colors.white, size: 20),
                              ),
                              title: Text(song['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                              subtitle: Text(song['artist'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
                            ),
                          ),
                        );
                      },
                      childCount: songResults.length,
                    ),
                  ),
                ],
              ]

              // ── 3. KİŞİSELLEŞTİRİLMİŞ İÇERİK ───────────────────────────
              else ...[
                if (loadingPersonal)
                  const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.only(top: 50), child: CircularProgressIndicator(color: kPink))))
                else ...[
                  // Hero Card (Zirvedeki Şarkın)
                  if (nowPlaying != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: GestureDetector(
                          onTap: () => _goToSong(nowPlaying!['id'], nowPlaying!['title']),
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              gradient: profileGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [BoxShadow(color: kBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: Stack(
                              children: [
                                Positioned(right: -20, bottom: -20, child: Icon(Icons.music_note, size: 150, color: Colors.white.withOpacity(0.1))),
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 80, height: 80,
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                                        child: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 48),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Zirvedeki Şarkın 🏆', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                                            Text(nowPlaying!['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            Text(nowPlaying!['artist'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.headphones, color: Colors.white, size: 20),
                                          Text('${nowPlaying!['playCount']}x', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Son Dinlenenler
                  if (topSongs.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 28, 20, 16),
                        child: Text('Son Dinlenenler ✨', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: topSongs.length,
                          itemBuilder: (ctx, i) {
                            final song = topSongs[i];
                            final colors = [kPink, kBlue, kGreen];
                            final color = colors[i % colors.length];
                            return GestureDetector(
                              onTap: () => _goToSong(song['id'], song['title']),
                              child: Container(
                                width: 220,
                                margin: const EdgeInsets.only(right: 14),
                                decoration: gradientCard(),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 70, height: double.infinity,
                                      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: const BorderRadius.horizontal(left: Radius.circular(16))),
                                      child: Center(child: Icon(Icons.play_circle_outline_rounded, color: color, size: 32)),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(song['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            Text(song['artist'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.headphones_rounded, color: Colors.white38, size: 12),
                                                  const SizedBox(width: 4),
                                                  Text('${song['playCount']} kez', style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // Beğenilenler
                  if (genres.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
                        child: Text('Kategorilere Göre Beğendiklerin ❤️', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (ctx, i) {
                          final genreName = genres[i];
                          final songsInGenre = groupedLikedSongs[genreName]!;
                          return Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: gradientCard(),
                              child: ExpansionTile(
                                leading: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.library_music_rounded, color: Colors.blue, size: 20),
                                ),
                                title: Text(genreName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Text('${songsInGenre.length} Şarkı', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                iconColor: Colors.blue,
                                collapsedIconColor: Colors.white,
                                children: songsInGenre.map((song) => _buildGenreSongItem(song)).toList(),
                              ),
                            ),
                          );
                        },
                        childCount: genres.length,
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ]
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenreSongItem(Map<String, dynamic> song) {
    return GestureDetector(
      onTap: () => _goToSong(song['id'], song['title']),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
        child: ListTile(
          leading: const Icon(Icons.favorite, color: Colors.red, size: 18),
          title: Text(song['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: Text(song['artist'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 11)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.headphones_rounded, color: Colors.blue, size: 14),
              const SizedBox(width: 4),
              Text('${song['playCount'] ?? 0} dinleme', style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}