import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime.dart';

class FavoritesManager {
  static SharedPreferences? _prefs;
  static const String _favoritesKey = 'favorites';

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Sauvegarde l'objet Anime complet pour éviter les appels API au chargement
  static Future<void> addFavorite(Anime anime) async {
    final prefs = await _getPrefs();
    final List<String> raw = prefs.getStringList(_favoritesKey) ?? [];

    final alreadyExists = raw.any((item) {
      final decoded = json.decode(item);
      return decoded['mal_id'] == anime.id;
    });

    if (!alreadyExists) {
      raw.add(json.encode(anime.toJson()));
      await prefs.setStringList(_favoritesKey, raw);
    }
  }

  static Future<void> removeFavorite(int animeId) async {
    final prefs = await _getPrefs();
    final List<String> raw = prefs.getStringList(_favoritesKey) ?? [];
    raw.removeWhere((item) {
      final decoded = json.decode(item);
      return decoded['mal_id'] == animeId;
    });
    await prefs.setStringList(_favoritesKey, raw);
  }

  static Future<bool> isFavorite(int animeId) async {
    final prefs = await _getPrefs();
    final List<String> raw = prefs.getStringList(_favoritesKey) ?? [];
    return raw.any((item) {
      final decoded = json.decode(item);
      return decoded['mal_id'] == animeId;
    });
  }

  // Retourne directement les objets Anime sans appel API
  static Future<List<Anime>> getFavorites() async {
    final prefs = await _getPrefs();
    final List<String> raw = prefs.getStringList(_favoritesKey) ?? [];
    return raw.map((item) {
      final decoded = json.decode(item) as Map<String, dynamic>;
      return Anime(
        id: decoded['mal_id'],
        title: decoded['title'],
        episodes: decoded['episodes'],
        year: decoded['year'],
        synopsis: decoded['synopsis'],
        imageUrl: decoded['imageUrl'],
        score: (decoded['score'] as num).toDouble(),
        genres: List<String>.from(decoded['genres']),
      );
    }).toList();
  }
}
