import 'package:flutter/foundation.dart';

class VideoService {
  // TODO: Remplace cette URL par ton vrai endpoint API
  // Exemple: 'https://ton-api.com/anime/$animeId/episode/$episodeNumber'
  static Future<List<Map<String, String>>> getEpisodeSources(
    int animeId,
    int episodeNumber,
  ) async {
    try {
      // TODO: Appel API réel ici
      // final response = await http.get(
      //   Uri.parse('https://ton-api.com/anime/$animeId/episode/$episodeNumber'),
      // );
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   return (data['sources'] as List).map((source) => {
      //     'name': source['name'] as String,
      //     'url': source['url'] as String,
      //     'quality': source['quality'] as String,
      //   }).toList();
      // }

      // Données placeholder en attendant l'API
      await Future.delayed(const Duration(seconds: 1));

      return [
        {
          'name': 'Source 1',
          'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          'quality': 'HD',
        },
        {
          'name': 'Source 2',
          'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          'quality': 'FHD',
        },
        {
          'name': 'Source 3',
          'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          'quality': 'SD',
        },
      ];
    } catch (e) {
      debugPrint('Erreur chargement sources vidéo: $e');
      return [];
    }
  }
}
