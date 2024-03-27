import 'package:flutter/material.dart'; //bibliothèque de de base pour les interfaces
import 'package:http/http.dart' as http; //bibliothèque HTTP pour les requêtes web
import 'dart:convert'; //bibliothèque pour la conversion des fichiers json
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; //bibliothèque pour afficher des vidéos youtube

class MainScreen extends StatefulWidget { //Création de la class pour l'écran sur lequel il y a les barres de recherches
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  late TextEditingController _searchController; // controle la barre de recherche Youtube
  late TextEditingController _wikiSearchController; // controle la barre de recherche Wikipedia
  String _videoId = ''; //creation de la variable qui contiendra l'ID de la video

  @override
  void initState() { //initialisation
    super.initState();
    _searchController = TextEditingController();
    _wikiSearchController = TextEditingController();
  }

  @override
  void dispose() { //suppression
    _searchController.dispose();
    _wikiSearchController.dispose();
    super.dispose();
  }

  Future<void> _searchYoutubeVideo() async { //fonction pour chercher les videos youtube
    String apiKey = 'AIzaSyDADN_K0ZvZZkFHZ3devsWvaHbcYPN4X-M'; //clé API youtube
    String searchQuery = _searchController.text; //recupere le texte entré par l'utilisateur dans la barre de recherche

    String apiUrl =
        'https://www.googleapis.com/youtube/v3/search?key=$apiKey&q=$searchQuery%20trailer&type=video&part=snippet'; //URL API youtube

    var response = await http.get(Uri.parse(apiUrl)); //requete HTTP
    if (response.statusCode == 200) { //requete reussie
      var jsonResponse = json.decode(response.body); //convertit le JSON
      String videoId = jsonResponse['items'][0]['id']['videoId']; //recupere l'element "VideoID"
      _loadTrailer(videoId); //charge la video a partir de l'ID
      print(videoId); //Debug qui nous permettait de verifier que le code renvoyait le bon videoID
    } else {
      throw Exception('Failed to load video');
    }
  }

  void _loadTrailer(String videoId) { //charge la video a partir du videoID
    String url = 'https://www.youtube.com/watch?v=$videoId'; //URL de la video
    Navigator.of(context).push( //ouverture d'une nouvelle page dans laquelle le lecteur s'ouvre
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
                    YoutubePlayerController controller = YoutubePlayerController(
                      initialVideoId: videoId,
                      flags: YoutubePlayerFlags(
                        autoPlay: true,
                        mute: false,
                      ),
                    );
                    controller.play();
                  },
                  onEnded: (metadata) {
                  },
                ),
              ),
            ),
      ),
    );
  }

  Future<void> _searchWikiDescription() async { //utilisation de l'API wikipedia
    String searchQuery = _wikiSearchController.text; //recuperation de ce qu'a entré l'utilisateur

    String apiUrl =
        'https://fr.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exintro=true&redirects=true&titles=$searchQuery&origin=*'; //URL

    var response = await http.get(Uri.parse(apiUrl)); //requete HTTP
    if (response.statusCode == 200) { //si la requete est reussi
      var jsonResponse = json.decode(response.body); //conversion du JSON
      var pages = jsonResponse['query']['pages']; //recuperation de la page correspondante a la recherche
      var pageId = pages.keys.first;//recuperation de l'ID de la page
      var description = pages[pageId]['extract']; //recuperation de la description de la page qui nous interesse

      var cleanDescription = _removeHtmlTags(description); //retire les balises html

      print(
          'Wiki Description: $cleanDescription'); //debug pour verifier que la description est bien récupérée
      _loadWikiDescriptionPage(cleanDescription); //charge une page avec dedans la description de wikipedia
    } else {
      throw Exception('Failed to load Wikipedia description');
    }
  }

  String _removeHtmlTags(String htmlText) { //retire les balises html (merci internet)
    RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  void _loadWikiDescriptionPage(String description) { //chargement de la page avec la description
    Navigator.of(context).push( //creation de la page
        MaterialPageRoute(
        builder: (context) =>
        Scaffold(
          appBar: AppBar(// details, couleurs etc de la page
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
            color: Colors.lightBlue[100],
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
                      description, //affiche la description Wikipedia
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
  Widget build(BuildContext context) { //creation de la page avec les barres de recherche
    return Scaffold(
      appBar: AppBar(
        title: Text('Medias'),
        backgroundColor: Colors
            .lightBlue[100],
      ),
      body: Container(
        color: Colors.lightBlue[100],
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchField('Youtube', _searchController, _searchYoutubeVideo,
                Icons.video_library), //barre de recherche youtube
            SizedBox(height: 16.0),
            _buildSearchField(
                'Wikipedia', _wikiSearchController, _searchWikiDescription,
                Icons.language), //barre de recherche wikipedia
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(String labelText, TextEditingController controller,
      Function() onPressed, IconData prefixIcon) { //creation de la barre de recherche
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: Colors.black),//icone
        suffixIcon: IconButton(
          icon: Icon(Icons.search, color: Colors.black),
          onPressed: onPressed,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
              color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors
              .black),
        ),
      ),
    );
  }
}
