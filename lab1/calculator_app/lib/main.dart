import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Calculator')),
        body: const Center(child: Text('Hello, Calculator!')),
      ),
    );
  }
}
