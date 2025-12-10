import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await supabase.auth.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar Animation
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF6A11CB).withOpacity(0.1),
                child: const Icon(Icons.person, size: 60, color: Color(0xFF6A11CB)),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 20),
              
              // Welcome Text
              const Text("Authenticated User",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 30),
              
              // Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email, color: Color(0xFF2575FC)),
                        title: const Text("Email"),
                        subtitle: Text(user?.email ?? "Unknown"),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.fingerprint, color: Color(0xFF6A11CB)),
                        title: const Text("User ID"),
                        subtitle: Text(user?.id ?? "Unknown"),
                      ),
                    ],
                  ),
                ),
              ).animate().slideY(begin: 0.5, duration: 600.ms).fadeIn(),
              
              const SizedBox(height: 40),
              
              // Logout Button
              ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.exit_to_app),
                label: const Text("Secure Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
