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

  Map<String, dynamic> toJson() {
    return {
      'mal_id': id,
      'title': title,
      'episodes': episodes,
      'year': year,
      'synopsis': synopsis,
      'imageUrl': imageUrl,
      'score': score,
      'genres': genres,
    };
  }
}
