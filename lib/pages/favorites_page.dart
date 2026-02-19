import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../services/favorites_manager.dart';
import '../widgets/anime_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Anime> favoriteAnime = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  // Instantané — plus besoin d'appels API, les données sont en local
  Future<void> loadFavorites() async {
    setState(() => isLoading = true);
    final favorites = await FavoritesManager.getFavorites();
    setState(() {
      favoriteAnime = favorites;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadFavorites,
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

    if (favoriteAnime.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 100, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text('Aucun favori',
                style: TextStyle(fontSize: 20, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Ajoute des animes à tes favoris !',
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
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
      itemCount: favoriteAnime.length,
      itemBuilder: (context, index) {
        return AnimeCard(
          anime: favoriteAnime[index],
          key: ValueKey(favoriteAnime[index].id),
          onFavoriteChanged: loadFavorites,
        );
      },
    );
  }
}
