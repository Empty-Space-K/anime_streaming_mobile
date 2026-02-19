import 'package:flutter/material.dart';
import 'genre_anime_list_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  static const List<Map<String, dynamic>> categories = [
    {'name': 'Action', 'icon': Icons.local_fire_department, 'genreId': 1},
    {'name': 'Adventure', 'icon': Icons.explore, 'genreId': 2},
    {'name': 'Comedy', 'icon': Icons.emoji_emotions, 'genreId': 4},
    {'name': 'Drama', 'icon': Icons.theater_comedy, 'genreId': 8},
    {'name': 'Fantasy', 'icon': Icons.auto_awesome, 'genreId': 10},
    {'name': 'Romance', 'icon': Icons.favorite, 'genreId': 22},
    {'name': 'Sci-Fi', 'icon': Icons.rocket_launch, 'genreId': 24},
    {'name': 'Slice of Life', 'icon': Icons.coffee, 'genreId': 36},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
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
                    builder: (context) => GenreAnimeListPage(
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
                    Icon(category['icon'] as IconData,
                        size: 48, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      category['name'] as String,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
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
