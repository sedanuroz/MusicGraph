import 'dart:convert';
import 'package:http/http.dart' as http;



class ApiService {
  //static const String baseUrl = 'http://192.168.1.179:8000';
  static const String baseUrl = 'http://10.111.129.19:8001'; // telefon

  // ── Şarkılar ──────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getPopularSongs(String genre) async {
    final res = await http.get(Uri.parse('$baseUrl/songs/popular?genre=${Uri.encodeComponent(genre)}'));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body)['songs']);
    return [];
  }

  static Future<Map<String, dynamic>?> getSongDetail(String songId) async {
    final res = await http.get(Uri.parse('$baseUrl/songs/$songId'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  static Future<List<Map<String, dynamic>>> searchSongs(String q) async {
    final res = await http.get(Uri.parse('$baseUrl/songs/search/query?q=${Uri.encodeComponent(q)}'));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body)['results']);
    return [];
  }

  static Future<List<Map<String, dynamic>>> getFriendsWhoLiked(
      String songId, String userId) async {
    final res = await http.get(Uri.parse(
        '$baseUrl/songs/$songId/liked-by-friends?user_id=$userId'));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body)['friends']);
    return [];
  }

  // ── Beğeni ────────────────────────────────────────────────────────────
  static Future<bool> isSongLiked(String songId, String userId) async {
    final res = await http.get(Uri.parse(
        '$baseUrl/songs/$songId/is-liked?user_id=$userId'));
    if (res.statusCode == 200) return jsonDecode(res.body)['isLiked'] ?? false;
    return false;
  }

  static Future<void> likeSong(String songId, String userId) async {
    await http.post(Uri.parse('$baseUrl/songs/$songId/like?user_id=$userId'));
  }

  static Future<void> unlikeSong(String songId, String userId) async {
    await http.delete(Uri.parse('$baseUrl/songs/$songId/like?user_id=$userId'));
  }

  // ── Dinleme ───────────────────────────────────────────────────────────
  static Future<void> listenSong(String songId, String userId) async {
    await http.post(Uri.parse('$baseUrl/songs/$songId/listen?user_id=$userId'));
  }

  // ── Sanatçılar ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getArtistSongs(String artistId) async {
    final res = await http.get(Uri.parse('$baseUrl/artists/$artistId/songs'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  static Future<List<Map<String, dynamic>>> searchArtists(String q) async {
    final res = await http.get(Uri.parse('$baseUrl/artists/search/query?q=${Uri.encodeComponent(q)}'));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body)['results']);
    return [];
  }

  // ── Kullanıcılar ──────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/users/'));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body)['users']);
    return [];
  }

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final res = await http.get(Uri.parse('$baseUrl/users/$userId/profile'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  static Future<List<Map<String, dynamic>>> getTopSongs(String userId) async {
    final res = await http.get(Uri.parse('$baseUrl/users/$userId/top-songs'));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body)['topSongs']);
    return [];
  }

  static Future<List<Map<String, dynamic>>> getLikedSongs(String userId) async {
    final res = await http.get(Uri.parse('$baseUrl/users/$userId/liked-songs'));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body)['likedSongs']);
    return [];
  }

  static Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    final res = await http.get(Uri.parse('$baseUrl/users/$userId/friends'));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body)['friends']);
    return [];
  }

  static Future<List<Map<String, dynamic>>> getRecommendations(String userId) async {
    final res = await http.get(Uri.parse('$baseUrl/users/$userId/social-radar'));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body)['socialRadar']);
    return [];
  }

  // ── Arkadaşlık ────────────────────────────────────────────────────────
  static Future<void> addFriend(String userId, String targetId) async {
    await http.post(Uri.parse('$baseUrl/users/$userId/friend/$targetId'));
  }

  static Future<void> removeFriend(String userId, String targetId) async {
    await http.delete(Uri.parse('$baseUrl/users/$userId/friend/$targetId'));
  }

  static Future<bool> checkFriendship(String userId, String targetId) async {
    final res = await http.get(Uri.parse('$baseUrl/users/$userId/is-friend/$targetId'));
    if (res.statusCode == 200) return jsonDecode(res.body)['isFriend'] ?? false;
    return false;
  }

  // ── Öneri ─────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getTasteTwins(String userId) async {
    final res = await http.get(Uri.parse('$baseUrl/users/$userId/taste-twins'));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body)['tasteTwins']);
    return [];
  }

  static Future<List<Map<String, dynamic>>> getSocialRadar(String userId) async {
    final res = await http.get(Uri.parse('$baseUrl/users/$userId/social-radar'));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body)['socialRadar']);
    return [];
  }

  static Future<List<Map<String, dynamic>>> getDiscoverUsers(String userId) async {
    final res = await http.get(Uri.parse('$baseUrl/users/$userId/discover-users'));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(res.body)['discoverUsers']);
    return [];
  }
}