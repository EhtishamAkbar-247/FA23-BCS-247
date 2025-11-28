import 'package:flutter/material.dart';

void main() {
  runApp(const BmiApp());
}

class BmiApp extends StatelessWidget {
  const BmiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

/// Splash screen with your name for 5 seconds
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BmiHomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Ehtisham Abbasi App',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class BmiHomeScreen extends StatefulWidget {
  const BmiHomeScreen({super.key});

  @override
  State<BmiHomeScreen> createState() => _BmiHomeScreenState();
}

class _BmiHomeScreenState extends State<BmiHomeScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String? _bmiResult;
  String? _bmiCategory;
  String? _errorMessage;

  String? _precautionsText;
  String? _stableWeightText;

  /// List of recent bmi results: each item is a map with keys: 'bmi', 'category'
  final List<Map<String, String>> _recentResults = [];

  void _calculateBmi() {
    setState(() {
      _errorMessage = null;
      _bmiResult = null;
      _bmiCategory = null;
      _precautionsText = null;
      _stableWeightText = null;
    });

    final String heightText = _heightController.text.trim();
    final String weightText = _weightController.text.trim();

    if (heightText.isEmpty || weightText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both height and weight.';
      });
      return;
    }

    final double? heightCm = double.tryParse(heightText);
    final double? weightKg = double.tryParse(weightText);

    if (heightCm == null || weightKg == null || heightCm <= 0 || weightKg <= 0) {
      setState(() {
        _errorMessage = 'Please enter valid positive numbers.';
      });
      return;
    }

    final double heightM = heightCm / 100;
    final double bmi = weightKg / (heightM * heightM);

    String category;
    if (bmi < 18.5) {
      category = 'Underweight';
    } else if (bmi < 25) {
      category = 'Normal';
    } else if (bmi < 30) {
      category = 'Overweight';
    } else {
      category = 'Obese';
    }

    // Calculate normal (stable) weight range
    final double minNormalWeight = 18.5 * heightM * heightM;
    final double maxNormalWeight = 24.9 * heightM * heightM;

    String precautions;
    String stableInfo;

    if (category == 'Underweight') {
      final double needToGain = (minNormalWeight - weightKg);
      precautions =
          '• Eat more balanced, calorie-rich meals.\n'
          '• Add healthy snacks (nuts, milk, fruits).\n'
          '• Do light exercise to build muscle.\n'
          '• Avoid skipping meals and junk-only diet.';
      stableInfo =
          'For a stable (normal) BMI you should gain about '
          '${needToGain.toStringAsFixed(1)} kg to reach at least '
          '${minNormalWeight.toStringAsFixed(1)} kg.';
    } else if (category == 'Overweight' || category == 'Obese') {
      final double needToLose = (weightKg - maxNormalWeight);
      precautions =
          '• Reduce sugary drinks and fast food.\n'
          '• Walk or exercise at least 30 minutes daily.\n'
          '• Eat more vegetables, fruits, and lean protein.\n'
          '• Avoid late-night heavy meals.';
      stableInfo =
          'For a stable (normal) BMI you should lose about '
          '${needToLose.toStringAsFixed(1)} kg to reach around '
          '${maxNormalWeight.toStringAsFixed(1)} kg.';
    } else {
      // Normal
      precautions =
          '• Maintain a balanced diet.\n'
          '• Keep regular physical activity.\n'
          '• Sleep 7–8 hours daily.\n'
          '• Avoid too much junk food and soft drinks.';
      stableInfo =
          'Your weight is already in a stable (normal) BMI range '
          '(${minNormalWeight.toStringAsFixed(1)} kg – '
          '${maxNormalWeight.toStringAsFixed(1)} kg). Keep it up!';
    }

    setState(() {
      _bmiResult = bmi.toStringAsFixed(1);
      _bmiCategory = category;
      _precautionsText = precautions;
      _stableWeightText = stableInfo;

      // Add to recent table (max 5)
      _recentResults.insert(0, {
        'bmi': _bmiResult!,
        'category': _bmiCategory!,
      });
      if (_recentResults.length > 5) {
        _recentResults.removeLast();
      }
    });
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = const Color(0xFF1D1E33);
    final Color accent = Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        title: const Text(
          'BMI Calculator',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Input Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter your details',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Height (cm)',
                                labelStyle: const TextStyle(color: Colors.white70),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: accent),
                                ),
                                prefixIcon:
                                    const Icon(Icons.height, color: Colors.white70),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Weight (kg)',
                                labelStyle: const TextStyle(color: Colors.white70),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  borderSide: BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: accent),
                                ),
                                prefixIcon: const Icon(
                                  Icons.monitor_weight,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_errorMessage != null)
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Result Card (with precautions & stable weight text)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your BMI Result',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_bmiResult == null)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.0),
                                child: Center(
                                  child: Text(
                                    'No result yet.\nEnter your height and weight\nthen tap the button below.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          _bmiCategory ?? '',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: _categoryColor(_bmiCategory),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _bmiResult ?? '',
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Normal BMI range is 18.5 - 24.9',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (_precautionsText != null) ...[
                                    const Text(
                                      'Precautions / Tips:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _precautionsText!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  if (_stableWeightText != null) ...[
                                    const Text(
                                      'Weight adjustment for stable BMI:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _stableWeightText!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Button (above table)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: _calculateBmi,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 24,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.calculate, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Calculate BMI',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Recent Results Table
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recent BMI Results',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_recentResults.isEmpty)
                              const Text(
                                'No recent calculations.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              )
                            else
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(2),
                                  2: FlexColumnWidth(3),
                                },
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  // Header row
                                  const TableRow(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.white24,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          '#',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          'BMI',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          'Category',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Data rows
                                  ..._recentResults.asMap().entries.map(
                                    (entry) {
                                      final index = entry.key;
                                      final item = entry.value;
                                      return TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Text(
                                              item['bmi'] ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Text(
                                              item['category'] ?? '',
                                              style: TextStyle(
                                                color: _categoryColor(
                                                    item['category']),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Copyright at the very end (bold)
              const Text(
                '© 2025 Ehtisham Abbasi. All rights reserved.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _categoryColor(String? category) {
    switch (category) {
      case 'Underweight':
        return Colors.yellowAccent;
      case 'Normal':
        return Colors.greenAccent;
      case 'Overweight':
        return Colors.orangeAccent;
      case 'Obese':
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }
}
