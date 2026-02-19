import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/anime.dart';
import 'episodes_list_page.dart';

class AnimeDetailPage extends StatelessWidget {
  final Anime anime;

  const AnimeDetailPage({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                anime.title,
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: CachedNetworkImage(
                imageUrl: anime.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.grey, size: 64),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Infos principales
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 20, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(
                              anime.score.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${anime.episodes ?? "?"} Épisodes',
                        style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                      ),
                      if (anime.year != null) ...[
                        const SizedBox(width: 16),
                        Text(
                          anime.year!,
                          style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Genres
                  if (anime.genres.isNotEmpty) ...[
                    const Text('Genres',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: anime.genres.map((genre) {
                        return Chip(
                          label: Text(genre),
                          backgroundColor:
                              Colors.deepPurple.withValues(alpha: 0.3),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Synopsis
                  const Text('Synopsis',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    anime.synopsis,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Bouton épisodes
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EpisodesListPage(anime: anime),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_circle_filled, size: 28),
                      label: const Text('Voir les épisodes',
                          style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
