import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../services/video_service.dart';

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
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadVideoSources();
  }

  Future<void> _loadVideoSources() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final sources = await VideoService.getEpisodeSources(
        widget.anime.id,
        widget.episodeNumber,
      );
      setState(() {
        _sources = sources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.anime.title} - EP ${widget.episodeNumber}'),
      ),
      body: Column(
        children: [
          // Zone vidéo
          _buildVideoArea(),

          // Sélection de source
          _buildSourceSelector(),

          // Infos épisode
          Expanded(child: _buildEpisodeInfo()),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    return Container(
      width: double.infinity,
      height: 250,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isLoading)
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text('Chargement des sources...',
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            )
          else if (_hasError || _sources.isEmpty)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Aucune source disponible',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadVideoSources,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_outline,
                    size: 80, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Épisode ${widget.episodeNumber}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Source: ${_sources[_selectedSource]['name']} (${_sources[_selectedSource]['quality']})',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSourceSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sources vidéo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_sources.isEmpty)
            const Center(
              child: Text('Aucune source disponible',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            Row(
              children: List.generate(_sources.length, (index) {
                final isSelected = _selectedSource == index;
                final source = _sources[index];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: index < _sources.length - 1 ? 8 : 0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedSource = index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Switched to ${source['name']} (${source['quality']})'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected ? Colors.deepPurple : Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle : Icons.play_arrow,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(source['name']!,
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center),
                          Text(source['quality']!,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white70),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildEpisodeInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.anime.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(widget.anime.score.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 16),
              Text(
                'Épisode ${widget.episodeNumber} / ${widget.anime.episodes ?? "?"}',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Synopsis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                widget.anime.synopsis,
                style: TextStyle(
                    fontSize: 14, height: 1.5, color: Colors.grey[300]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
