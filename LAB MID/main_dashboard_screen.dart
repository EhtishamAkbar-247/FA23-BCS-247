import 'package:flutter/material.dart';
import 'package:mess_pos/patient_list_screen.dart';
import 'package:mess_pos/auth_screen.dart';
import 'package:mess_pos/user_dashboard_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isAuthenticated = false;
  String? _currentUser;
  String? _currentUserRole;
  // Removed misplaced closing brace and added missing variable declarations

  void _handleLoginSuccess(String username, String role) {
    setState(() {
      _isAuthenticated = true;
      _currentUser = username;
      _currentUserRole = role;
    });
  }

  void _logout() {
    setState(() {
      _isAuthenticated = false;
      _currentUser = null;
      _currentUserRole = null;
    });
  }
  // Removed misplaced closing brace

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return AuthScreen(onLoginSuccess: _handleLoginSuccess);
    } else {
      return _buildAnimatedDashboard();
    }
  }

  Widget _buildAnimatedDashboard() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor App Dashboards'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AnimatedSlideFade(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Logged in as: $_currentUser ($_currentUserRole)',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            if (_currentUserRole == 'doctor')
              _AnimatedSlideFade(
                delay: const Duration(milliseconds: 300),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const PatientListScreen()),
                    );
                  },
                  icon: const Icon(Icons.medical_services, size: 30),
                  label: const Text('Go to Doctor Dashboard',
                      style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            const SizedBox(height: 30),
            _AnimatedSlideFade(
              delay: const Duration(milliseconds: 400),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            UserDashboardScreen(username: _currentUser!)),
                  );
                },
                icon: const Icon(Icons.person, size: 30),
                label: const Text('Go to User Dashboard',
                    style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '© 2025 Ehtisham Akbar — FA23-BCS-247. All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
      ),
    );
  }
}

// Helper widget for staggered animations
class _AnimatedSlideFade extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedSlideFade({required this.child, required this.delay});

  @override
  State<_AnimatedSlideFade> createState() => _AnimatedSlideFadeState();
}

class _AnimatedSlideFadeState extends State<_AnimatedSlideFade>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
