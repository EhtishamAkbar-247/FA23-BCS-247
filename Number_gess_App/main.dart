import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:number_gess/matrix_background.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

import 'platform_init.dart'
    if (dart.library.html) 'platform_init_web.dart';

void main() async {
  // Perform platform-specific initialization.
  platformInit();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _themeIndex = 0;

  final List<ThemeData> _themes = [
    // 1. Default White Theme
    ThemeData.light().copyWith(
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
          primary: Colors.blue, secondary: Colors.blueAccent),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.blue)),
    ),
    // 2. Hacker Green Theme
    ThemeData.dark().copyWith(
      primaryColor: Colors.greenAccent,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
          primary: Colors.greenAccent, secondary: Colors.lightGreenAccent),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.greenAccent)),
    ),
    // 3. Cyberpunk Purple Theme
    ThemeData.dark().copyWith(
      primaryColor: Colors.purpleAccent,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
          primary: Colors.purpleAccent, secondary: Colors.pinkAccent),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.purpleAccent)),
    ),
  ];

  void _changeTheme() {
    setState(() {
      _themeIndex = (_themeIndex + 1) % _themes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _themes[_themeIndex],
      debugShowCheckedModeBanner: false,
      home: kIsWeb
          ? const Scaffold(
              body: Center(
                child: Text(
                    'This application is not fully supported on the web.'),
              ),
            )
          : GameApp(changeTheme: _changeTheme),
    );
  }
}


class GameApp extends StatelessWidget {
  final VoidCallback changeTheme;
  const GameApp({super.key, required this.changeTheme});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Database>(
        future: _initDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else if (snapshot.hasData) {
            return MyHomePage(
              title: 'Number Guessing Game',
              database: snapshot.data!, changeTheme: changeTheme,
            );
          } else {
            return const Scaffold(
              body: Center(child: Text('Something went wrong')),
            );
          }
        },
      );
  }

  Future<Database> _initDatabase() async {
    // WidgetsFlutterBinding.ensureInitialized() is called in main(), no need to call it here.
    return openDatabase(
      p.join(await getDatabasesPath(), 'scores_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE scores(id INTEGER PRIMARY KEY, score INTEGER, date TEXT)',
        );
      },
      version: 1,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.database, required this.changeTheme});

  final String title;
  final Database database;
  final VoidCallback changeTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late int _targetNumber;
  int _attempts = 0;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _targetNumber = Random().nextInt(100) + 1;
      _attempts = 0;
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _clearScores() async {
    final db = widget.database;
    await db.delete('scores');
    setState(() {
      // To refresh the view if the dialog is rebuilt
    });
  }

  Future<void> _saveScore(int score) async {
    final db = widget.database;
    await db.insert(
      'scores',
      {'score': score, 'date': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> _getScores() async {
    final db = widget.database;
    return db.query('scores', orderBy: 'score ASC');
  }

  void _checkGuess() {
    final guess = int.tryParse(_controller.text);
    if (guess == null) {
      return;
    }

    setState(() {
      _attempts++;
    });

    // Auto-change theme on correct guess
    if (guess == _targetNumber) {
      widget.changeTheme();
    }

    String message;
    if (guess == _targetNumber) {
      message = 'You got it in $_attempts attempts!';
      _saveScore(_attempts);
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Congratulations!'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text('Play Again'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _resetGame();
                },
              ),
            ],
          );
        },
      );
    } else if (guess < _targetNumber) {
      message = 'Too low!';
      _shakeController.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      message = 'Too high!';
      _shakeController.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MatrixBackground(),
        Scaffold(
          backgroundColor: Colors.transparent, // Make scaffold transparent
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(widget.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.palette),
                tooltip: 'Change Theme',
                onPressed: widget.changeTheme,
              ),
              IconButton(
                icon: const Icon(Icons.leaderboard),
                onPressed: () async {
                  final scores = await _getScores();
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('High Scores'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: scores.length,
                            itemBuilder: (context, index) {
                              final score = scores[index];
                              final date = DateTime.parse(score['date']);
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                  child: Text('${index + 1}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                ),
                                title: Text('Attempts: ${score['score']}'),
                                subtitle: Text(DateFormat.yMMMd().add_jm().format(date)),
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              _clearScores();
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text('Clear Scores', style: TextStyle(color: Colors.redAccent)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Close'),
                          )
                        ],
                      );
                    },
                  );
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
              'I\'m thinking of a number between 1 and 100.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
              child: Text(
                'Attempts: $_attempts',
                key: ValueKey<int>(_attempts),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  labelText: 'Enter your guess',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (_) => _checkGuess(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkGuess,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Guess'),
            ).animate(onPlay: (controller) => controller.repeat())
                .boxShadow(
                  duration: 2000.ms,
                  begin: BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.0), blurRadius: 10, spreadRadius: 1),
                  end: BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), blurRadius: 10, spreadRadius: 3),
                )
                .then(delay: 2000.ms)
                .boxShadow(end: BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.0), blurRadius: 10, spreadRadius: 1)),
            const Spacer(),
            const Text(
              'EHTISHAM AKBAR || FA23-BCS-247',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _resetGame,
            tooltip: 'New Game',
            child: const Icon(Icons.refresh),
          ).animate(onPlay: (controller) => controller.repeat())
              .boxShadow(
                duration: 2000.ms,
                begin: BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.0), blurRadius: 10, spreadRadius: 1),
                end: BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.7), blurRadius: 10, spreadRadius: 5),
              )
              .then(delay: 2000.ms)
              .boxShadow(end: BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.0), blurRadius: 10, spreadRadius: 1)),
        ),
      ],
    );
  }
}
