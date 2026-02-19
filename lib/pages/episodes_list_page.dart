import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/anime.dart';
import 'episode_player_page.dart';

class EpisodesListPage extends StatelessWidget {
  final Anime anime;

  const EpisodesListPage({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    final episodeCount = anime.episodes ?? 12;

    return Scaffold(
      appBar: AppBar(
        title: Text(anime.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête anime
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: anime.imageUrl,
                    width: 100,
                    height: 140,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 140,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anime.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(anime.score.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$episodeCount Épisodes',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Épisodes',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Grille d'épisodes
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: episodeCount,
                itemBuilder: (context, index) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EpisodePlayerPage(
                              anime: anime,
                              episodeNumber: index + 1,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.deepPurple.shade600,
                              Colors.deepPurple.shade800,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_circle_filled,
                                size: 40, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              'EP ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
