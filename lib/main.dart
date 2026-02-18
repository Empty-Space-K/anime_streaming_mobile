import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AnimeStreamingApp());
}

class AnimeStreamingApp extends StatelessWidget {
  const AnimeStreamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime Streaming',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AnimeHomePage(),
    const CategoriesPage(),
    const FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}

class AnimeHomePage extends StatefulWidget {
  const AnimeHomePage({super.key});

  @override
  State<AnimeHomePage> createState() => _AnimeHomePageState();
}

class _AnimeHomePageState extends State<AnimeHomePage> {
  List<Anime> animeList = [];
  List<Anime> filteredAnimeList = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAnimeData();
  }

  Future<void> fetchAnimeData() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://api.jikan.moe/v4/top/anime?limit=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> animeData = data['data'];

        setState(() {
          animeList = animeData.map((anime) => Anime.fromJson(anime)).toList();
          filteredAnimeList = animeList;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading anime: $e')),
        );
      }
    }
  }

  void filterAnime(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredAnimeList = animeList;
      } else {
        filteredAnimeList = animeList
            .where((anime) =>
                anime.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime Streaming'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAnimeData,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search anime...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          filterAnime('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: filterAnime,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAnimeList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty
                                  ? 'No anime found'
                                  : 'No results for "$searchQuery"',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: filteredAnimeList.length,
                          itemBuilder: (context, index) {
                            final anime = filteredAnimeList[index];
                            return AnimeCard(anime: anime, key: ValueKey(anime.id));
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Action', 'icon': Icons.local_fire_department, 'genreId': 1},
      {'name': 'Adventure', 'icon': Icons.explore, 'genreId': 2},
      {'name': 'Comedy', 'icon': Icons.emoji_emotions, 'genreId': 4},
      {'name': 'Drama', 'icon': Icons.theater_comedy, 'genreId': 8},
      {'name': 'Fantasy', 'icon': Icons.auto_awesome, 'genreId': 10},
      {'name': 'Romance', 'icon': Icons.favorite, 'genreId': 22},
      {'name': 'Sci-Fi', 'icon': Icons.rocket_launch, 'genreId': 24},
      {'name': 'Slice of Life', 'icon': Icons.coffee, 'genreId': 36},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenreAnimeList(
                      genreName: category['name'] as String,
                      genreId: category['genreId'] as int,
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
                      Colors.deepPurple.shade700,
                      Colors.deepPurple.shade900,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GenreAnimeList extends StatefulWidget {
  final String genreName;
  final int genreId;

  const GenreAnimeList({
    super.key,
    required this.genreName,
    required this.genreId,
  });

  @override
  State<GenreAnimeList> createState() => _GenreAnimeListState();
}

class _GenreAnimeListState extends State<GenreAnimeList> {
  List<Anime> animeList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGenreAnime();
  }

  Future<void> fetchGenreAnime() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://api.jikan.moe/v4/anime?genres=${widget.genreId}&limit=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> animeData = data['data'];

        setState(() {
          animeList = animeData.map((anime) => Anime.fromJson(anime)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.genreName} Anime'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: animeList.length,
              itemBuilder: (context, index) {
                return AnimeCard(anime: animeList[index], key: ValueKey(animeList[index].id));
              },
            ),
    );
  }
}

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

  Future<void> loadFavorites() async {
    setState(() => isLoading = true);

    final favoriteIds = await FavoritesManager.getFavorites();
    final List<Anime> loadedFavorites = [];

    for (final id in favoriteIds) {
      try {
        final response = await http.get(
          Uri.parse('https://api.jikan.moe/v4/anime/$id'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          loadedFavorites.add(Anime.fromJson(data['data']));
        }
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        // Skip failed requests
      }
    }

    setState(() {
      favoriteAnime = loadedFavorites;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadFavorites,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteAnime.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 100,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add some anime to your favorites!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
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
                      onFavoriteChanged: () => loadFavorites(),
                    );
                  },
                ),
    );
  }
}

class AnimeCard extends StatefulWidget {
  final Anime anime;
  final VoidCallback? onFavoriteChanged;

  const AnimeCard({
    super.key,
    required this.anime,
    this.onFavoriteChanged,
  });

  @override
  State<AnimeCard> createState() => _AnimeCardState();
}

class _AnimeCardState extends State<AnimeCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  Future<void> checkFavorite() async {
    final favorite = await FavoritesManager.isFavorite(widget.anime.id);
    setState(() {
      isFavorite = favorite;
    });
  }

  Future<void> toggleFavorite() async {
    if (isFavorite) {
      await FavoritesManager.removeFavorite(widget.anime.id);
    } else {
      await FavoritesManager.addFavorite(widget.anime.id);
    }
    setState(() {
      isFavorite = !isFavorite;
    });
    widget.onFavoriteChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimeDetailPage(anime: widget.anime),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.anime.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_not_supported,
                            color: Colors.grey, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            widget.anime.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.anime.score.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: toggleFavorite,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.anime.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.anime.episodes ?? "?"} Episodes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              background: Image.network(
                anime.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
                        '${anime.episodes ?? "?"} Episodes',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (anime.year != null)
                        Text(
                          anime.year!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (anime.genres.isNotEmpty) ...[
                    const Text(
                      'Genres',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: anime.genres.map((genre) {
                        return Chip(
                          label: Text(genre),
                          backgroundColor: Colors.deepPurple.withOpacity(0.3),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'Synopsis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    anime.synopsis,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EpisodesListPage(anime: anime),
                              ),
                            );
                          },
                          icon: const Icon(Icons.list, size: 24),
                          label: const Text(
                            'Episodes',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoPlayerPage(anime: anime),
                              ),
                            );
                          },
                          icon: const Icon(Icons.movie, size: 24),
                          label: const Text(
                            'Trailer',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.deepPurple.shade700,
                          ),
                        ),
                      ),
                    ],
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

class VideoPlayerPage extends StatelessWidget {
  final Anime anime;

  const VideoPlayerPage({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(anime.title),
      ),
      body: Column(
        children: [
          // Video player placeholder
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade700,
                  Colors.deepPurple.shade900,
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  anime.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 80,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Video Player Demo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'In a production app, this would stream anime episodes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anime.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        anime.score.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${anime.episodes ?? "?"} Episodes',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Episodes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: anime.episodes ?? 12,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              child: Text('${index + 1}'),
                            ),
                            title: Text('Episode ${index + 1}'),
                            subtitle: Text('${anime.title} - Ep ${index + 1}'),
                            trailing: const Icon(
                              Icons.play_circle_filled,
                              color: Colors.deepPurple,
                              size: 32,
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Now playing Episode ${index + 1}'),
                                  action: SnackBarAction(
                                    label: 'OK',
                                    onPressed: () {},
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
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

class EpisodesListPage extends StatelessWidget {
  final Anime anime;

  const EpisodesListPage({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    final episodeCount = anime.episodes ?? 12;

    return Scaffold(
      appBar: AppBar(
        title: Text('${anime.title} - Episodes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    anime.imageUrl,
                    width: 100,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 140,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            anime.score.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$episodeCount Episodes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Episodes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
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
                            const Icon(
                              Icons.play_circle_filled,
                              size: 40,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'EP ${index + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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

class EpisodePlayerPage extends StatefulWidget {
  final Anime anime;
  final int episodeNumber;

  const EpisodePlayerPage({
    super.key,
    required this.anime,
    required this.episodeNumber,
  });

  @override
  State<EpisodePlayerPage> createState() => _EpisodePlayerPageState();
}

class _EpisodePlayerPageState extends State<EpisodePlayerPage> {
  int _selectedSource = 0;
  List<Map<String, String>> _sources = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideoSources(); // Load video sources when page opens
  }

  // Load video sources from API
  Future<void> _loadVideoSources() async {
    setState(() => _isLoading = true);

    // TODO: This is where your API is called!
    // It passes the anime ID and episode number to get the video URLs
    final sources = await VideoService.getEpisodeSources(
      widget.anime.id,
      widget.episodeNumber,
    );

    setState(() {
      _sources = sources;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.anime.title} - EP ${widget.episodeNumber}'),
      ),
      body: Column(
        children: [
          // Video Player Area
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade700,
                  Colors.deepPurple.shade900,
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  widget.anime.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
                Container(
                  color: Colors.black.withOpacity(0.6),
                  child: _isLoading
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Loading video sources...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        )
                      : _sources.isEmpty
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No video sources available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.play_circle_outline,
                                  size: 80,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Episode ${widget.episodeNumber}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Playing from ${_sources[_selectedSource]['name']} (${_sources[_selectedSource]['quality']})',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_sources.length} sources available',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                ),
              ],
            ),
          ),

          // Source Selection
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Video Sources',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _sources.isEmpty
                        ? const Center(
                            child: Text(
                              'No sources available',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : Row(
                            children: List.generate(_sources.length, (index) {
                              final isSelected = _selectedSource == index;
                              final source = _sources[index];
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: index < _sources.length - 1 ? 8 : 0,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedSource = index;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Switched to ${source['name']} (${source['quality']})',
                                          ),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected
                                          ? Colors.deepPurple
                                          : Colors.grey[800],
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle
                                              : Icons.play_arrow,
                                          size: 20,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          source['name']!,
                                          style: const TextStyle(fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          source['quality']!,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white70,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
              ],
            ),
          ),

          // Episode Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.anime.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        widget.anime.score.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Episode ${widget.episodeNumber} of ${widget.anime.episodes ?? "?"}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Synopsis',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.anime.synopsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey[300],
                        ),
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

// Video Service - handles fetching video URLs from API
class VideoService {
  // TODO: Replace this URL with your actual API endpoint
  // Example: 'https://your-api.com/anime/$animeId/episode/$episodeNumber'
  static Future<List<Map<String, String>>> getEpisodeSources(
    int animeId,
    int episodeNumber,
  ) async {
    try {
      // TODO: Make API call here
      // Example:
      // final response = await http.get(
      //   Uri.parse('https://your-api.com/anime/$animeId/episode/$episodeNumber'),
      // );
      //
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   return (data['sources'] as List).map((source) => {
      //     'name': source['name'] as String,
      //     'url': source['url'] as String,
      //     'quality': source['quality'] as String,
      //   }).toList();
      // }

      // For now, return placeholder data
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay

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
      print('Error fetching video sources: $e');
      return [];
    }
  }
}

// Favorites Manager
class FavoritesManager {
  static SharedPreferences? _prefs;
  static const String _favoritesKey = 'favorites';

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<List<int>> getFavorites() async {
    final prefs = await _getPrefs();
    final List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];
    return favorites.map((id) => int.parse(id)).toList();
  }

  static Future<void> addFavorite(int animeId) async {
    final prefs = await _getPrefs();
    final favorites = await getFavorites();
    if (!favorites.contains(animeId)) {
      favorites.add(animeId);
      await prefs.setStringList(
        _favoritesKey,
        favorites.map((id) => id.toString()).toList(),
      );
    }
  }

  static Future<void> removeFavorite(int animeId) async {
    final prefs = await _getPrefs();
    final favorites = await getFavorites();
    favorites.remove(animeId);
    await prefs.setStringList(
      _favoritesKey,
      favorites.map((id) => id.toString()).toList(),
    );
  }

  static Future<bool> isFavorite(int animeId) async {
    final favorites = await getFavorites();
    return favorites.contains(animeId);
  }
}

// Anime Model
class Anime {
  final int id;
  final String title;
  final int? episodes;
  final String? year;
  final String synopsis;
  final String imageUrl;
  final double score;
  final List<String> genres;

  Anime({
    required this.id,
    required this.title,
    this.episodes,
    this.year,
    required this.synopsis,
    required this.imageUrl,
    required this.score,
    required this.genres,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['mal_id'],
      title: json['title'],
      episodes: json['episodes'],
      year: json['year']?.toString(),
      synopsis: json['synopsis'] ?? 'No description available.',
      imageUrl: json['images']['jpg']['large_image_url'],
      score: (json['score'] ?? 0).toDouble(),
      genres: (json['genres'] as List)
          .map((genre) => genre['name'] as String)
          .toList(),
    );
  }
}
