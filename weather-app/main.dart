import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

const String apiKey = 'bd5e378503939ddaee76f12ad7a97608'; // Replace with your OpenWeatherMap API key

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amazing Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const WeatherHomeScreen(),
    );
  }
}

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> with TickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  Map<String, dynamic>? _currentWeather;
  String? _errorMessage;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cityController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentWeather(String city, {bool fromRefresh = false}) async {
    if (fromRefresh) _refreshController.requestRefresh();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentWeather = null;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'));
      if (response.statusCode == 200) {
        setState(() {
          _currentWeather = json.decode(response.body);
          _isLoading = false;
        });
        _animationController.forward(from: 0.0);
      } else {
        setState(() {
          _errorMessage = 'Invalid city or API error. Please try again.';
          _isLoading = false;
        });
      }
    } on SocketException {
      setState(() {
        _errorMessage = 'No internet connection. Please check your network.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }

    if (fromRefresh) _refreshController.refreshCompleted();
  }

  LinearGradient _getBackgroundGradient(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'clear':
        return const LinearGradient(colors: [Colors.orange, Colors.yellow], begin: Alignment.topCenter, end: Alignment.bottomCenter);
      case 'clouds':
        return const LinearGradient(colors: [Colors.grey, Colors.blueGrey], begin: Alignment.topCenter, end: Alignment.bottomCenter);
      case 'rain':
        return const LinearGradient(colors: [Colors.blue, Colors.indigo], begin: Alignment.topCenter, end: Alignment.bottomCenter);
      case 'snow':
        return const LinearGradient(colors: [Colors.white, Colors.lightBlue], begin: Alignment.topCenter, end: Alignment.bottomCenter);
      default:
        return const LinearGradient(colors: [Colors.blue, Colors.lightBlue], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? weatherCondition = _currentWeather?['weather']?[0]?['main'];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Amazing Weather App'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: _getBackgroundGradient(weatherCondition),
        ),
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: () {
            if (_cityController.text.isNotEmpty) {
              _fetchCurrentWeather(_cityController.text, fromRefresh: true);
            } else {
              _refreshController.refreshCompleted();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Enter city name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_cityController.text.isNotEmpty) {
                      _fetchCurrentWeather(_cityController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Search'),
                ),
                const SizedBox(height: 32),
                if (_isLoading)
                  const Center(
                    child: SpinKitFadingCircle(
                      color: Colors.white,
                      size: 50.0,
                    ),
                  ),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                if (_currentWeather != null) ...[
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              _currentWeather!['name'],
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Image.network(
                                'http://openweathermap.org/img/wn/${_currentWeather!['weather'][0]['icon']}@2x.png',
                                width: 120,
                                height: 120,
                              ),
                            ),
                            SlideTransition(
                              position: _slideAnimation,
                              child: Text(
                                '${_currentWeather!['main']['temp']}°C',
                                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              _currentWeather!['weather'][0]['description'].toUpperCase(),
                              style: const TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => NextDayWeatherScreen(city: _cityController.text),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('View Next Day Weather'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NextDayWeatherScreen extends StatefulWidget {
  final String city;

  const NextDayWeatherScreen({super.key, required this.city});

  @override
  State<NextDayWeatherScreen> createState() => _NextDayWeatherScreenState();
}

class _NextDayWeatherScreenState extends State<NextDayWeatherScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? _forecastData;
  String? _errorMessage;
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
    _fetchForecast();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchForecast() async {
    setState(() {
      _errorMessage = null;
      _forecastData = null;
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=${widget.city}&appid=$apiKey&units=metric'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['list'].length > 8) {
          setState(() {
            _forecastData = data['list'][8]; // ~24 hours ahead
            _isLoading = false;
          });
          _animationController.forward(from: 0.0);
        } else {
          setState(() {
            _errorMessage = 'No forecast data available.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid city or API error.';
          _isLoading = false;
        });
      }
    } on SocketException {
      setState(() {
        _errorMessage = 'No internet connection.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  LinearGradient _getBackgroundGradient(String? condition) {
    // Same as home screen for consistency
    switch (condition?.toLowerCase()) {
      case 'clear':
        return const LinearGradient(colors: [Colors.orange, Colors.yellow], begin: Alignment.topCenter, end: Alignment.bottomCenter);
      case 'clouds':
        return const LinearGradient(colors: [Colors.grey, Colors.blueGrey], begin: Alignment.topCenter, end: Alignment.bottomCenter);
      case 'rain':
        return const LinearGradient(colors: [Colors.blue, Colors.indigo], begin: Alignment.topCenter, end: Alignment.bottomCenter);
      case 'snow':
        return const LinearGradient(colors: [Colors.white, Colors.lightBlue], begin: Alignment.topCenter, end: Alignment.bottomCenter);
      default:
        return const LinearGradient(colors: [Colors.blue, Colors.lightBlue], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final formattedDate = DateFormat('MMMM d, yyyy').format(tomorrow);
    String? weatherCondition = _forecastData?['weather']?[0]?['main'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Next Day Forecast'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: _getBackgroundGradient(weatherCondition),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Forecast for ${widget.city} on $formattedDate',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const SpinKitFadingCircle(
                  color: Colors.white,
                  size: 50.0,
                ),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              if (_forecastData != null) ...[
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Image.network(
                              'http://openweathermap.org/img/wn/${_forecastData!['weather'][0]['icon']}@2x.png',
                              width: 120,
                              height: 120,
                            ),
                          ),
                          Text(
                            '${_forecastData!['main']['temp']}°C',
                            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _forecastData!['weather'][0]['description'].toUpperCase(),
                            style: const TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
