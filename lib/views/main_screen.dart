//a
//b
//c

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  late TextEditingController _searchController;
  late TextEditingController _wikiSearchController;
  String _videoId = '';


  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _wikiSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _wikiSearchController.dispose();
    super.dispose();
  }

  Future<void> _searchYoutubeVideo() async {
    String apiKey = 'AIzaSyDADN_K0ZvZZkFHZ3devsWvaHbcYPN4X-M';
    String searchQuery = _searchController.text;

    String apiUrl =
        'https://www.googleapis.com/youtube/v3/search?key=$apiKey&q=$searchQuery%20trailer&type=video&part=snippet';

    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      String videoId = jsonResponse['items'][0]['id']['videoId'];
      _loadTrailer(videoId);
      print(videoId);
    } else {
      throw Exception('Failed to load video');
    }
  }

  void _loadTrailer(String videoId) {
    String url = 'https://www.youtube.com/watch?v=$videoId';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            Scaffold(
              appBar: AppBar(
                title: Text('Game Trailer'),
              ),
              body: Center(
                child: YoutubePlayer(
                  controller: YoutubePlayerController(
                    initialVideoId: videoId,
                    flags: YoutubePlayerFlags(
                      autoPlay: true,
                      mute: false,
                    ),
                  ),
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.blueAccent,
                  progressColors: ProgressBarColors(
                    playedColor: Colors.blue,
                    handleColor: Colors.blueAccent,
                  ),
                  onReady: () {
                    // Ajoutez votre logique personnalisée ici lorsque le lecteur est prêt.
                    YoutubePlayerController controller = YoutubePlayerController(
                      initialVideoId: videoId,
                      flags: YoutubePlayerFlags(
                        autoPlay: true,
                        mute: false,
                      ),
                    );
                    controller.play(); // Démarre automatiquement la lecture lorsque le lecteur est prêt.
                  },
                  onEnded: (metadata) {
                    // Ajoutez votre logique personnalisée ici lorsque la vidéo se termine.
                  },
                ),
              ),
            ),
      ),
    );
  }



  Future<void> _searchWikiDescription() async {
    String searchQuery = _wikiSearchController.text;

    String apiUrl =
        'https://fr.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exintro=true&redirects=true&titles=$searchQuery&origin=*';

    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var pages = jsonResponse['query']['pages'];
      var pageId = pages.keys.first;
      var description = pages[pageId]['extract'];

      // Clean the description from HTML tags
      var cleanDescription = _removeHtmlTags(description);

      print(
          'Wiki Description: $cleanDescription'); // Debugging: Print the description
      _loadWikiDescriptionPage(cleanDescription);
    } else {
      throw Exception('Failed to load Wikipedia description');
    }
  }

  String _removeHtmlTags(String htmlText) {
    RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  void _loadWikiDescriptionPage(String description) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            Scaffold(
              appBar: AppBar(
                title: Text(
                  'Wiki Description',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.lightBlue[100],
                elevation: 0,
              ),
              body: Container(
                color: Colors.lightBlue[100], // Background color
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          'Source: Wikipedia',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medias'),
        backgroundColor: Colors
            .lightBlue[100], // Couleur de fond de l'appBar en light blue
      ),
      body: Container(
        color: Colors.lightBlue[100], // Couleur de fond
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchField('Youtube', _searchController, _searchYoutubeVideo,
                Icons.video_library),
            SizedBox(height: 16.0),
            _buildSearchField(
                'Wikipedia', _wikiSearchController, _searchWikiDescription,
                Icons.language),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(String labelText, TextEditingController controller,
      Function() onPressed, IconData prefixIcon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: Colors.black),
        // Icône à gauche du champ de recherche
        suffixIcon: IconButton(
          icon: Icon(Icons.search, color: Colors.black),
          // Couleur de l'icône de recherche en noir
          onPressed: onPressed,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
              color: Colors.black), // Couleur de la bordure en noir
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors
              .black), // Couleur de la bordure lorsqu'elle est sélectionnée en noir
        ),
      ),
    );
  }
}