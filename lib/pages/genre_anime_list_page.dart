import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../services/anime_service.dart';
import '../widgets/anime_card.dart';

class GenreAnimeListPage extends StatefulWidget {
  final String genreName;
  final int genreId;

  const GenreAnimeListPage({
    super.key,
    required this.genreName,
    required this.genreId,
  });

  @override
  State<GenreAnimeListPage> createState() => _GenreAnimeListPageState();
}

class _GenreAnimeListPageState extends State<GenreAnimeListPage> {
  List<Anime> animeList = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchGenreAnime();
  }

  Future<void> fetchGenreAnime() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final results = await AnimeService.getAnimeByGenre(widget.genreId);
      setState(() {
        animeList = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.genreName} Anime'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchGenreAnime,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Erreur de chargement',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: fetchGenreAnime,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (animeList.isEmpty) {
      return const Center(
        child: Text('Aucun anime trouvé dans cette catégorie.',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: animeList.length,
      itemBuilder: (context, index) {
        return AnimeCard(
            anime: animeList[index], key: ValueKey(animeList[index].id));
      },
    );
  }
}
