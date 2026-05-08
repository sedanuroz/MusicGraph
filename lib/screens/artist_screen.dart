import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';

class ArtistScreen extends StatefulWidget {
  final String artistId;
  final String artistName;

  const ArtistScreen({
    super.key,
    required this.artistId,
    required this.artistName,
  });

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  Map<String, dynamic>? artistData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchArtist();
  }

  Future<void> fetchArtist() async {
    final result = await ApiService.getArtistSongs(widget.artistId);
    setState(() {
      artistData = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator(color: kPink))
          : artistData == null
          ? const Center(
          child: Text('Sanatçı bulunamadı',
              style: TextStyle(color: Colors.white54)))
          : CustomScrollView(
        slivers: [
          // Üst banner
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: kBackground,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPink, kBlue, kGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white38, width: 2),
                        ),
                        child: const Icon(Icons.person,
                            size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        artistData!['name'] ?? widget.artistName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${(artistData!['songs'] as List).length} şarkı',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Şarkı listesi
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, i) {
                  final songs =
                  artistData!['songs'] as List<dynamic>;
                  if (i >= songs.length) return null;
                  final song =
                  songs[i] as Map<String, dynamic>;
                  final energy =
                  ((song['energy'] ?? 0.0) * 100).toInt();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: gradientCard(),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: pinkBlueGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.music_note,
                            color: Colors.white, size: 20),
                      ),
                      title: Text(
                        song['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        song['album'] ?? '',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kPink.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: kPink.withOpacity(0.4)),
                        ),
                        child: Text(
                          '⚡$energy%',
                          style: const TextStyle(
                              color: kPink,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
                childCount:
                (artistData!['songs'] as List).length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}