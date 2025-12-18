import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
// 1. IMPORT SUPABASE
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. INITIALIZE SUPABASE
  await Supabase.initialize(
    url: 'https://vmiyyfknbjttpwspghna.supabase.co',
    // We use the ANON key here. NEVER use the Service Role key in the app code.
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZtaXl5ZmtuYmp0dHB3c3BnaG5hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU5ODExNTksImV4cCI6MjA4MTU1NzE1OX0.Gaf94wYMwLg5_nnel2z4iVXLVYS_wdxWBiRCsQE--do',
  );

  runApp(const MovieBrowserApp());
}

class MovieBrowserApp extends StatelessWidget {
  const MovieBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abbasi Movie Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0d253f),
          elevation: 0,
        ),
        cardColor: const Color(0xFF1E1E1E),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.blueAccent,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // YOUR API KEY
  final String apiKey = 'd6b63fe7780aae0eb8dd6ef40e518dd9';

  List<dynamic> contentList = [];
  bool isLoading = true;
  int currentPage = 1;

  // Navigation State
  String mainCategory = 'movie';
  String subFilter = 'trending';

  // Specific Filters
  int? selectedGenreId;
  String selectedGenreName = "";
  int selectedYear = 2024;

  // TMDB Genre Map
  final Map<String, int> genres = {
    'Action': 28, 'Adventure': 12, 'Animation': 16, 'Comedy': 35,
    'Crime': 80, 'Documentary': 99, 'Drama': 18, 'Family': 10751,
    'Fantasy': 14, 'History': 36, 'Horror': 27, 'Music': 10402,
    'Mystery': 9648, 'Romance': 10749, 'Sci-Fi': 878, 'Thriller': 53,
    'War': 10752, 'Western': 37
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    String urlStr = "";

    if (mainCategory == 'anime') {
      String sortBy = 'popularity.desc';
      if (subFilter == 'top_rated') sortBy = 'vote_average.desc';
      if (subFilter == 'upcoming') sortBy = 'first_air_date.desc';
      urlStr = 'https://api.themoviedb.org/3/discover/tv?api_key=$apiKey&with_genres=16&with_original_language=ja&sort_by=$sortBy&page=$currentPage';
    }
    else if (mainCategory == 'kdrama') {
      String sortBy = 'popularity.desc';
      if (subFilter == 'top_rated') sortBy = 'vote_average.desc';
      if (subFilter == 'upcoming') sortBy = 'first_air_date.desc';
      urlStr = 'https://api.themoviedb.org/3/discover/tv?api_key=$apiKey&with_original_language=ko&sort_by=$sortBy&page=$currentPage';
    }
    else if (mainCategory == 'marvel') {
      urlStr = 'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&with_companies=420&sort_by=primary_release_date.desc&page=$currentPage';
    }
    else if (mainCategory == 'dc') {
      urlStr = 'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&with_companies=9993|128064&sort_by=primary_release_date.desc&page=$currentPage';
    }
    else if (mainCategory == 'genre') {
      String yearQuery = subFilter == 'by_year' ? '&primary_release_year=$selectedYear' : '';
      urlStr = 'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&with_genres=$selectedGenreId&sort_by=popularity.desc&page=$currentPage$yearQuery';
    }
    else {
      String endpointType = mainCategory == 'movie' ? 'movie' : 'tv';

      if (subFilter == 'trending') {
        urlStr = 'https://api.themoviedb.org/3/trending/$endpointType/week?api_key=$apiKey&page=$currentPage';
      } else if (subFilter == 'by_year') {
        String dateField = endpointType == 'movie' ? 'primary_release_year' : 'first_air_date_year';
        urlStr = 'https://api.themoviedb.org/3/discover/$endpointType?api_key=$apiKey&sort_by=popularity.desc&$dateField=$selectedYear&page=$currentPage';
      } else {
        String endpointFilter = '';
        if (subFilter == 'top_rated') {
          endpointFilter = '$endpointType/top_rated';
        } else if (subFilter == 'upcoming') {
          endpointFilter = endpointType == 'movie' ? 'movie/upcoming' : 'tv/on_the_air';
        }
        urlStr = 'https://api.themoviedb.org/3/$endpointFilter?api_key=$apiKey&page=$currentPage';
      }
    }

    try {
      final response = await http.get(Uri.parse(urlStr));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          contentList = data['results'];
          isLoading = false;
        });
      } else {
        setState(() { isLoading = false; contentList = []; });
      }
    } catch (e) {
      setState(() { isLoading = false; contentList = []; });
    }
  }

  // --- Navigation Helpers ---
  void _changeMainCategory(String category) {
    setState(() {
      mainCategory = category;
      subFilter = 'trending';
      currentPage = 1;
    });
    Navigator.pop(context);
    fetchData();
  }

  void _selectGenre(String name, int id) {
    setState(() {
      mainCategory = 'genre';
      selectedGenreName = name;
      selectedGenreId = id;
      subFilter = 'trending';
      currentPage = 1;
    });
    Navigator.pop(context);
    fetchData();
  }

  void _changeSubFilter(String? newValue) {
    if (newValue != null) {
      setState(() {
        subFilter = newValue;
        currentPage = 1;
      });
      fetchData();
    }
  }

  void _changeYear(int year) {
    setState(() {
      selectedYear = year;
      subFilter = 'by_year';
      currentPage = 1;
    });
    fetchData();
  }

  void _changePage(int increment) {
    setState(() {
      currentPage += increment;
      if (currentPage < 1) currentPage = 1;
    });
    fetchData();
  }

  String getPageTitle() {
    if (mainCategory == 'marvel') return "Marvel Universe";
    if (mainCategory == 'dc') return "DC Universe";
    if (mainCategory == 'genre') return "$selectedGenreName Movies";
    if (mainCategory == 'anime') return "Anime";
    if (mainCategory == 'kdrama') return "K-Drama";
    if (mainCategory == 'tv') return "TV Series";
    return "Abbasi Center - Movies";
  }

  @override
  Widget build(BuildContext context) {
    bool showFilter = (mainCategory != 'marvel' && mainCategory != 'dc');

    return Scaffold(
      appBar: AppBar(
        title: Text(getPageTitle(), style: const TextStyle(fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MovieSearchDelegate(apiKey: apiKey),
              );
            },
          )
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          if (showFilter) _buildFilterSection(),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                : contentList.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: contentList.length,
              itemBuilder: (context, index) {
                bool isMovie = (mainCategory == 'movie' || mainCategory == 'genre' || mainCategory == 'marvel' || mainCategory == 'dc');
                return ContentGridCard(content: contentList[index], isMovie: isMovie, apiKey: apiKey);
              },
            ),
          ),

          _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      color: const Color(0xFF1F1F1F),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          currentPage > 1
              ? ElevatedButton.icon(
            onPressed: () => _changePage(-1),
            icon: const Icon(Icons.arrow_back),
            label: const Text("Prev"),
          )
              : const SizedBox(width: 80),

          Text(
            "Page $currentPage",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),

          ElevatedButton.icon(
            onPressed: () => _changePage(1),
            icon: const Icon(Icons.arrow_forward),
            label: const Text("Next"),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: const Color(0xFF1F1F1F),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Sort / Filter:", style: TextStyle(color: Colors.white70)),
              Container(
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.white24),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: subFilter,
                    dropdownColor: const Color(0xFF2C2C2C),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.redAccent),
                    items: const [
                      DropdownMenuItem(value: 'trending', child: Text("Trending")),
                      DropdownMenuItem(value: 'top_rated', child: Text("Top Rated")),
                      DropdownMenuItem(value: 'upcoming', child: Text("New / Upcoming")),
                      DropdownMenuItem(value: 'by_year', child: Text("By Year")),
                    ],
                    onChanged: _changeSubFilter,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),

          if (subFilter == 'by_year')
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Text("Year: $selectedYear", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Slider(
                      value: selectedYear.toDouble(),
                      min: 1980,
                      max: 2026,
                      activeColor: Colors.redAccent,
                      inactiveColor: Colors.grey,
                      divisions: 46,
                      onChanged: (val) {
                        setState(() => selectedYear = val.toInt());
                      },
                      onChangeEnd: (val) => _changeYear(val.toInt()),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF0d253f)),
            accountName: Text("Abbasi Movie Center", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text("Ehtisham Akbar || FA23-BCS-247"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.play_arrow, color: Colors.white),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.movie, color: Colors.blueAccent),
            title: const Text('Movies'),
            selected: mainCategory == 'movie',
            onTap: () => _changeMainCategory('movie'),
          ),
          ListTile(
            leading: const Icon(Icons.tv, color: Colors.greenAccent),
            title: const Text('TV Series'),
            selected: mainCategory == 'tv',
            onTap: () => _changeMainCategory('tv'),
          ),
          ListTile(
            leading: const Icon(Icons.animation, color: Colors.orangeAccent),
            title: const Text('Anime'),
            selected: mainCategory == 'anime',
            onTap: () => _changeMainCategory('anime'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.pinkAccent),
            title: const Text('K-Drama'),
            selected: mainCategory == 'kdrama',
            onTap: () => _changeMainCategory('kdrama'),
          ),

          // --- 4. NEW FAVORITES SECTION IN DRAWER ---
          const Divider(),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: const Text('My Favorites (Supabase)'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen(apiKey: apiKey)),
              );
            },
          ),
          // ------------------------------------------

          const Divider(),

          ExpansionTile(
            leading: const Icon(Icons.category, color: Colors.purpleAccent),
            title: const Text("Browse by Genre"),
            initiallyExpanded: false,
            children: genres.entries.map((entry) {
              return ListTile(
                visualDensity: const VisualDensity(vertical: -2),
                dense: true,
                contentPadding: const EdgeInsets.only(left: 50),
                title: Text(entry.key, style: const TextStyle(color: Colors.white70)),
                onTap: () => _selectGenre(entry.key, entry.value),
              );
            }).toList(),
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
            child: Text("FRANCHISES", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          ),

          ListTile(
            leading: const Icon(Icons.shield, color: Colors.red),
            title: const Text('Marvel Universe'),
            onTap: () => _changeMainCategory('marvel'),
          ),
          ListTile(
            leading: const Icon(Icons.bolt, color: Colors.blue),
            title: const Text('DC Universe'),
            onTap: () => _changeMainCategory('dc'),
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("FA23-BCS-247", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_dissatisfied, size: 60, color: Colors.grey),
          const SizedBox(height: 10),
          const Text("No content found."),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: fetchData, child: const Text("Retry"))
        ],
      ),
    );
  }
}

// --- 5. NEW FAVORITES SCREEN (READ & DELETE) ---
class FavoritesScreen extends StatefulWidget {
  final String apiKey;
  const FavoritesScreen({super.key, required this.apiKey});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<dynamic> favoritesList = [];

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    try {
      // READ from Supabase table 'favorites'
      final data = await supabase
          .from('favorites')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        favoritesList = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching favorites: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : favoritesList.isEmpty
          ? const Center(child: Text("No favorites yet."))
          : GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: favoritesList.length,
        itemBuilder: (context, index) {
          final fav = favoritesList[index];
          // Adapt Supabase data to the format ContentGridCard expects
          final contentMap = {
            'id': fav['tmdb_id'],
            'title': fav['title'],
            'name': fav['title'], // Support both keys
            'poster_path': fav['poster_path'],
            'overview': fav['overview'],
            'vote_average': fav['vote_average'],
            'release_date': fav['release_date'],
            'first_air_date': fav['release_date'],
          };
          
          return ContentGridCard(
            content: contentMap,
            isMovie: fav['is_movie'] ?? true,
            apiKey: widget.apiKey,
          );
        },
      ),
    );
  }
}

// --- CARD ---

class ContentGridCard extends StatelessWidget {
  final dynamic content;
  final bool isMovie;
  final String apiKey;

  const ContentGridCard({super.key, required this.content, required this.isMovie, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    final title = content['title'] ?? content['name'] ?? 'Unknown';
    final date = content['release_date'] ?? content['first_air_date'] ?? 'Unknown';
    final voteAverage = (content['vote_average'] ?? 0.0).toDouble();
    final posterPath = content['poster_path'];
    final imageUrl = posterPath != null
        ? 'https://image.tmdb.org/t/p/w500$posterPath'
        : 'https://via.placeholder.com/300x450?text=No+Image';

    Color ratingColor = voteAverage >= 7 ? Colors.green : (voteAverage >= 5 ? Colors.yellow : Colors.red);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              contentId: content['id'],
              isMovie: isMovie,
              apiKey: apiKey,
              posterUrl: imageUrl,
              title: title,
              basicOverview: content['overview'],
              // Pass metadata for saving to Supabase
              voteAverage: voteAverage,
              releaseDate: date,
              posterPath: posterPath,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8,
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: const Color(0xFF1E1E1E),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          date.length > 4 ? date.substring(0, 4) : date,
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: ratingColor),
                ),
                child: Text(
                  voteAverage.toStringAsFixed(1),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ratingColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- DETAILS SCREEN (UPDATED FOR SUPABASE CRUD) ---

class DetailScreen extends StatefulWidget {
  final int contentId;
  final bool isMovie;
  final String apiKey;
  final String posterUrl;
  final String title;
  final String? basicOverview;
  
  // Extra fields needed for Supabase insert
  final double? voteAverage;
  final String? releaseDate;
  final String? posterPath;

  const DetailScreen({
    super.key,
    required this.contentId,
    required this.isMovie,
    required this.apiKey,
    required this.posterUrl,
    required this.title,
    this.basicOverview,
    this.voteAverage,
    this.releaseDate,
    this.posterPath,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic>? details;
  List<dynamic> images = [];
  String? trailerKey;
  bool isLoading = true;

  // Supabase State
  final supabase = Supabase.instance.client;
  bool isFavorite = false;
  bool checkingFav = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
    checkIfFavorite();
  }

  // --- 6. CHECK IF FAVORITE (READ) ---
  Future<void> checkIfFavorite() async {
    try {
      final data = await supabase
          .from('favorites')
          .select()
          .eq('tmdb_id', widget.contentId)
          .maybeSingle();
      
      if (mounted) {
        setState(() {
          isFavorite = data != null;
          checkingFav = false;
        });
      }
    } catch (e) {
      debugPrint("Error checking favorite: $e");
    }
  }

  // --- 7. TOGGLE FAVORITE (CREATE / DELETE) ---
  Future<void> toggleFavorite() async {
    try {
      if (isFavorite) {
        // DELETE
        await supabase.from('favorites').delete().eq('tmdb_id', widget.contentId);
        setState(() => isFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from Favorites")));
      } else {
        // CREATE (INSERT)
        await supabase.from('favorites').insert({
          'tmdb_id': widget.contentId,
          'title': widget.title,
          'poster_path': widget.posterPath,
          'overview': widget.basicOverview,
          'vote_average': widget.voteAverage,
          'release_date': widget.releaseDate,
          'is_movie': widget.isMovie,
        });
        setState(() => isFavorite = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to Favorites")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> fetchDetails() async {
    final type = widget.isMovie ? 'movie' : 'tv';
    final url = Uri.parse('https://api.themoviedb.org/3/$type/${widget.contentId}?api_key=${widget.apiKey}&append_to_response=images,credits,videos&include_video_language=hi,en');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        String? tKey;
        if (data['videos'] != null && data['videos']['results'] != null) {
          final List videos = data['videos']['results'];
          final trailers = videos.where((v) => v['site'] == 'YouTube' && v['type'] == 'Trailer').toList();

          if (trailers.isNotEmpty) {
            var specificTrailer = trailers.firstWhere(
                    (v) => v['iso_639_1'] == 'hi',
                orElse: () => null
            );
            specificTrailer ??= trailers.firstWhere(
                    (v) => v['iso_639_1'] == 'en',
                orElse: () => null
            );
            specificTrailer ??= trailers.first;

            if (specificTrailer != null) {
              tKey = specificTrailer['key'];
            }
          }
        }

        setState(() {
          details = data;
          if (data['images'] != null && data['images']['backdrops'] != null) {
            images = data['images']['backdrops'];
          }
          trailerKey = tKey;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _launchTrailer() async {
    if (trailerKey == null) return;

    final Uri url = Uri.parse('https://www.youtube.com/watch?v=$trailerKey');

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch YouTube.")),
        );
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final overview = details?['overview'] ?? widget.basicOverview ?? 'No description available.';
    final date = details != null
        ? (details?['release_date'] ?? details?['first_air_date'] ?? 'Unknown')
        : '';
    final genres = details?['genres'] as List<dynamic>?;

    String? backdropPath = details?['backdrop_path'];
    final backdropUrl = backdropPath != null
        ? 'https://image.tmdb.org/t/p/w780$backdropPath'
        : 'https://via.placeholder.com/780x440?text=No+Image';

    return Scaffold(
      // ADDED FLOATING ACTION BUTTON FOR FAVORITE
      floatingActionButton: FloatingActionButton(
        onPressed: toggleFavorite,
        backgroundColor: Colors.white,
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.black,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.title, textScaleFactor: 0.8),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(backdropUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (genres != null)
                      Wrap(
                        spacing: 8,
                        children: genres.map((g) => Chip(
                          label: Text(g['name'], style: const TextStyle(fontSize: 10)),
                          backgroundColor: Colors.white10,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        )).toList(),
                      ),

                    const SizedBox(height: 15),

                    if (trailerKey != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _launchTrailer,
                          icon: const Icon(Icons.play_circle_fill, size: 28),
                          label: const Text("Watch Trailer on YouTube", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    if (trailerKey != null)
                      const SizedBox(height: 20),

                    const Text("Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    const SizedBox(height: 8),
                    Text(overview, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white70)),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(date, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 20),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 5),
                        Text("${details?['vote_average']?.toStringAsFixed(1) ?? '?'} / 10", style: const TextStyle(color: Colors.amber)),
                      ],
                    ),

                    const SizedBox(height: 30),
                    if (images.isNotEmpty) ...[
                      const Text("Gallery", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length > 8 ? 8 : images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  'https://image.tmdb.org/t/p/w300${images[index]['file_path']}',
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                    const Divider(color: Colors.white12),
                    const Center(child: Text("Copyright: Ehtisham Akbar || FA23-BCS-247", style: TextStyle(color: Colors.grey, fontSize: 12))),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class MovieSearchDelegate extends SearchDelegate {
  final String apiKey;

  MovieSearchDelegate({required this.apiKey});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0d253f),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          if (query.trim().isNotEmpty) {
            showResults(context);
          }
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) return const Center(child: Text("Please enter a search term"));

    return FutureBuilder(
      future: _searchContent(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
        }
        final results = snapshot.data as List<dynamic>? ?? [];
        if (results.isEmpty) return const Center(child: Text("No results found."));

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            bool isMovie = item['media_type'] == 'movie';
            return ContentGridCard(content: item, isMovie: isMovie, apiKey: apiKey);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_creation_outlined, size: 80, color: Colors.white10),
            SizedBox(height: 10),
            Text("Search Movies & TV Shows", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListTile(
      leading: const Icon(Icons.search, color: Colors.redAccent),
      title: Text('Search for "$query"'),
      onTap: () => showResults(context),
    );
  }

  Future<List<dynamic>> _searchContent(String query) async {
    final url = Uri.parse('https://api.themoviedb.org/3/search/multi?api_key=$apiKey&query=$query&include_adult=false');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List).where((item) => item['media_type'] == 'movie' || item['media_type'] == 'tv').toList();
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return [];
  }
}
