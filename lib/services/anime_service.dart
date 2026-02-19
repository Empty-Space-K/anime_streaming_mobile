import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime.dart';

class AnimeService {
  static const String _baseUrl = 'https://api.jikan.moe/v4';

  static Future<List<Anime>> getTopAnime({int limit = 20}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/top/anime?limit=$limit'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((anime) => Anime.fromJson(anime))
          .toList();
    }

    throw Exception('Erreur chargement top anime: ${response.statusCode}');
  }

  static Future<List<Anime>> getAnimeByGenre(int genreId, {int limit = 20}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/anime?genres=$genreId&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((anime) => Anime.fromJson(anime))
          .toList();
    }

    throw Exception('Erreur chargement genre: ${response.statusCode}');
  }
}
