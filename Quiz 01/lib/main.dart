import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const UltraProDiceApp());
}

class UltraProDiceApp extends StatelessWidget {
  const UltraProDiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ultra Pro Dice - Ehtisham Akbar',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const UltraProDiceHome(),
    );
  }
}

class UltraProDiceHome extends StatefulWidget {
  const UltraProDiceHome({super.key});

  @override
  State<UltraProDiceHome> createState() => _UltraProDiceHomeState();
}

class _UltraProDiceHomeState extends State<UltraProDiceHome>
    with TickerProviderStateMixin {
  int diceNumber = 1;
  int rollCount = 0;
  List<int> history = [];

  late AnimationController _diceController;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  late AnimationController _bgController;

  final List<List<Color>> _gradients = [
    [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)],
    [const Color(0xFF232526), const Color(0xFF414345), const Color(0xFF232526)],
    [const Color(0xFF141E30), const Color(0xFF243B55), const Color(0xFF141E30)],
    [const Color(0xFF373B44), const Color(0xFF4286f4), const Color(0xFF373B44)],
  ];

  int _currentGradient = 0;
  int _nextGradient = 1;

  @override
  void initState() {
    super.initState();

    _diceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _rotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _diceController, curve: Curves.easeOutCirc),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _diceController, curve: Curves.elasticOut),
    );

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  void rollDice() {
    HapticFeedback.lightImpact();
    _diceController.forward(from: 0);

    setState(() {
      diceNumber = Random().nextInt(6) + 1;
      rollCount++;
      history.insert(0, diceNumber);
      if (history.length > 5) history.removeLast();

      _currentGradient = _nextGradient;
      _nextGradient = Random().nextInt(_gradients.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final diceSize = screenW * 0.18; // 🔹 Smaller responsive dice

    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        final t = _bgController.value;
        final gradientColors = [
          Color.lerp(_gradients[_currentGradient][0],
              _gradients[_nextGradient][0], t)!,
          Color.lerp(_gradients[_currentGradient][1],
              _gradients[_nextGradient][1], t)!,
          Color.lerp(_gradients[_currentGradient][2],
              _gradients[_nextGradient][2], t)!,
        ];

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Colors.lightBlueAccent],
                      ).createShader(bounds),
                      child: const Text(
                        "Ultra Pro Dice 🎲",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "By Ehtisham Akbar",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Glass dice card
                    Container(
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.15), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: _scale,
                            child: RotationTransition(
                              turns: _rotation,
                              child: Image.asset(
                                'assets/images/$diceNumber.png',
                                width: diceSize,
                                height: diceSize,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            "You rolled a $diceNumber",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Total Rolls: $rollCount",
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: rollDice,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 16),
                              elevation: 10,
                            ),
                            child: const Text(
                              "ROLL DICE",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // History Section
                    if (history.isNotEmpty) ...[
                      const Text(
                        "Recent Rolls",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: history
                            .map((num) => Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    "$num",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _diceController.dispose();
    _bgController.dispose();
    super.dispose();
  }
}
