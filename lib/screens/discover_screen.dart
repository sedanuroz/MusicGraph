import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'song_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final List<String> genres = [
    'Pop', 'Rock', 'Electronic', 'Classical', 'R&B',
    'Hip-Hop', 'Arabesk', 'Türk Pop', 'Türk Rap', 'Anadolu Rock'
  ];
  String selectedGenre = 'Pop';
  List<Map<String, dynamic>> songs = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  // Verileri API'den tazeleyen fonksiyon
  Future<void> fetchSongs() async {
    if (!mounted) return;
    setState(() => loading = true);
    try {
      final result = await ApiService.getPopularSongs(selectedGenre);
      if (mounted) {
        setState(() {
          songs = result;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  // Detay sayfasına gidiş ve dönüşte yenilenme mantığı (YENİ)
  void _goToSongDetail(String songId, String songTitle) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => SongDetailScreen(
        songId: songId,
        songTitle: songTitle,
      ),
    )).then((_) {
      // Detay sayfasından geri gelindiği anda listeyi tazele
      fetchSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: ShaderMask(
                shaderCallback: (b) => pinkBlueGradient.createShader(b),
                child: const Text(
                  'Keşfet 🎵',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text('Genre seç, müziği keşfet', style: TextStyle(color: Colors.white54, fontSize: 14)),
            ),

            // Genre seçici
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: genres.length,
                itemBuilder: (context, i) {
                  final g = genres[i];
                  final selected = g == selectedGenre;
                  final colors = allGenreColors[g] ?? [kPink, kPinkLight];
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedGenre = g);
                      fetchSongs();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: selected ? LinearGradient(colors: colors) : null,
                        color: selected ? null : kCard,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: selected ? Colors.transparent : Colors.white12),
                      ),
                      child: Text(g,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white60,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Şarkı listesi (RefreshIndicator eklendi)
            Expanded(
              child: loading && songs.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: kPink))
                  : songs.isEmpty
                  ? const Center(child: Text('Şarkı bulunamadı', style: TextStyle(color: Colors.white54)))
                  : RefreshIndicator(
                color: kPink,
                backgroundColor: kCard,
                onRefresh: fetchSongs,
                child: ListView.builder(
                  // Liste kısa olsa bile çekilebilmesi için fizik kuralı
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: songs.length,
                  itemBuilder: (context, i) {
                    final song = songs[i];
                    final colors = allGenreColors[selectedGenre] ?? [kPink, kPinkLight];
                    return GestureDetector(
                      onTap: () => _goToSongDetail(song['id'], song['title']), // Güncellendi
                      child: _SongCard(song: song, index: i, colors: colors),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  final Map<String, dynamic> song;
  final int index;
  final List<Color> colors;

  const _SongCard({required this.song, required this.index, required this.colors});

  @override
  Widget build(BuildContext context) {
    final energy = ((song['energy'] ?? 0.0) * 100).toInt();
    final dance  = ((song['danceability'] ?? 0.0) * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: gradientCard(colors: [kCard, kCardLight]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text('${index + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
        ),
        title: Text(song['title'] ?? '',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(song['artist'] ?? 'Bilinmeyen Sanatçı',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _MiniBar('⚡', energy, colors[0]),
            const SizedBox(height: 4),
            _MiniBar('💃', dance, colors[1]),
          ],
        ),
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String emoji;
  final int value;
  final Color color;
  const _MiniBar(this.emoji, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 4),
        Container(
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 100,
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          ),
        ),
      ],
    );
  }
}