import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // YOUR PROVIDED URL
    url: 'https://fmdnukbcyjejxwvcoxhd.supabase.co',
    // YOUR PROVIDED ANON KEY
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZtZG51a2JjeWplanh3dmNveGhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzODgzNDAsImV4cCI6MjA4MDk2NDM0MH0.I19JSbORNBs5d_EVbYeQEQOlQ1TYQDMz2Qkil6QYlIE',
  );

  runApp(const MyApp());
}

// Global Supabase client accessor
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Pro Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A11CB), // Deep Purple
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6A11CB), width: 2),
          ),
        ),
      ),
      // Check if user is already logged in
      home: supabase.auth.currentUser != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}