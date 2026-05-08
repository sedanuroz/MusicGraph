import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class SongDetailScreen extends StatefulWidget {
  final String songId;
  final String songTitle;

  const SongDetailScreen({
    super.key,
    required this.songId,
    required this.songTitle,
  });

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  Map<String, dynamic>? song;
  String userId  = '';
  bool isLiked   = false;
  bool loading   = true;
  bool likeLoading   = false;
  bool listenLoading = false;
  int  listenCount   = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final id = await AuthService.getUserId();
    setState(() => userId = id ?? '');

    final detail = await ApiService.getSongDetail(widget.songId);
    final liked  = userId.isNotEmpty
        ? await ApiService.isSongLiked(widget.songId, userId)
        : false;

    setState(() {
      song    = detail;
      isLiked = liked;
      loading = false;
    });
  }

  Future<void> _toggleLike() async {
    if (userId.isEmpty) return;
    setState(() => likeLoading = true);
    if (isLiked) {
      await ApiService.unlikeSong(widget.songId, userId);
    } else {
      await ApiService.likeSong(widget.songId, userId);
    }
    final liked = await ApiService.isSongLiked(widget.songId, userId);
    setState(() { isLiked = liked; likeLoading = false; });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isLiked ? '❤️ Beğenildi!' : '💔 Beğeni kaldırıldı'),
        backgroundColor: (isLiked ? kPink : Colors.white24),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  Future<void> _listen() async {
    if (userId.isEmpty) return;
    setState(() => listenLoading = true);
    await ApiService.listenSong(widget.songId, userId);
    setState(() {
      listenCount++;
      listenLoading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('🎵 Dinlendi! Sayaç güncellendi.'),
        backgroundColor: kBlue.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator(color: kPink))
          : song == null
              ? const Center(child: Text('Şarkı bulunamadı',
                  style: TextStyle(color: Colors.white54)))
              : CustomScrollView(
                  slivers: [
                    // ── App Bar ───────────────────────────────────────
                    SliverAppBar(
                      expandedHeight: 280,
                      pinned: true,
                      backgroundColor: kBackground,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [kPink, kBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: SafeArea(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                // Büyük müzik ikonu
                                Container(
                                  width: 110, height: 110,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                        color: Colors.white30, width: 2),
                                  ),
                                  child: const Icon(Icons.music_note,
                                      color: Colors.white, size: 56),
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Text(song!['title'] ?? '',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(height: 6),
                                Text(song!['artist'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 15)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // ── Beğen + Dinle butonları ───────────────
                            Row(children: [
                              // Beğen butonu
                              Expanded(
                                child: GestureDetector(
                                  onTap: likeLoading ? null : _toggleLike,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: isLiked
                                          ? const LinearGradient(
                                              colors: [kPink, Color(0xFFFF9EC4)])
                                          : null,
                                      color: isLiked ? null : kCard,
                                      borderRadius: BorderRadius.circular(14),
                                      border: isLiked
                                          ? null
                                          : Border.all(
                                              color: kPink.withOpacity(0.5)),
                                    ),
                                    child: Center(
                                      child: likeLoading
                                          ? const SizedBox(width: 20, height: 20,
                                              child: CircularProgressIndicator(
                                                  color: kPink, strokeWidth: 2))
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isLiked
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: isLiked
                                                      ? Colors.white
                                                      : kPink,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  isLiked ? 'Beğenildi' : 'Beğen',
                                                  style: TextStyle(
                                                    color: isLiked
                                                        ? Colors.white
                                                        : kPink,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Dinle butonu
                              Expanded(
                                child: GestureDetector(
                                  onTap: listenLoading ? null : _listen,
                                  child: Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                          colors: [kBlue, kGreen]),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: listenLoading
                                          ? const SizedBox(width: 20, height: 20,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2))
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 22),
                                                const SizedBox(width: 6),
                                                Text(
                                                  listenCount > 0
                                                      ? 'Dinlendi (+$listenCount)'
                                                      : 'Dinle',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),

                            const SizedBox(height: 28),

                            // ── Şarkı bilgileri ───────────────────────
                            const Text('Şarkı Bilgileri',
                              style: TextStyle(color: Colors.white,
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),

                            // Albüm & Genre
                            Row(children: [
                              Expanded(child: _infoCard(
                                icon: Icons.album,
                                label: 'Albüm',
                                value: song!['album'] ?? 'Bilinmiyor',
                                color: kPink,
                              )),
                              const SizedBox(width: 12),
                              Expanded(child: _infoCard(
                                icon: Icons.category,
                                label: 'Tür',
                                value: song!['genre'] ?? 'Bilinmiyor',
                                color: kGreen,
                              )),
                            ]),

                            const SizedBox(height: 12),

                            // Yıl
                            if (song!['year'] != null)
                              _infoCard(
                                icon: Icons.calendar_today,
                                label: 'Yıl',
                                value: '${song!['year']}',
                                color: kBlue,
                              ),

                            const SizedBox(height: 28),

                            // ── Ses Özellikleri ───────────────────────
                            const Text('Ses Özellikleri 🎛️',
                              style: TextStyle(color: Colors.white,
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),

                            _audioBar('⚡ Enerji',
                                song!['energy'] ?? 0.0, kPink),
                            const SizedBox(height: 10),
                            _audioBar('💃 Dans Edilebilirlik',
                                song!['danceability'] ?? 0.0, kBlue),
                            const SizedBox(height: 10),
                            _audioBar('😊 Mutluluk (Valence)',
                                song!['valence'] ?? 0.0, kGreen),
                            const SizedBox(height: 10),

                            // Tempo ayrı göster
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: gradientCard(),
                              child: Row(children: [
                                const Text('🥁 Tempo',
                                  style: TextStyle(color: Colors.white70,
                                      fontSize: 14)),
                                const Spacer(),
                                Text(
                                  '${(song!['tempo'] ?? 0.0).toStringAsFixed(0)} BPM',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ]),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: gradientCard(),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(
                  color: Colors.white38, fontSize: 11)),
              Text(value, style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600,
                  fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          )),
        ]),
      );

  Widget _audioBar(String label, double value, Color color) {
    final percent = (value * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label, style: const TextStyle(
              color: Colors.white70, fontSize: 13)),
          const Spacer(),
          Text('$percent%', style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
