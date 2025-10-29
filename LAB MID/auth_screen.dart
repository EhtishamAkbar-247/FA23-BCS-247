import 'package:flutter/material.dart';
import 'package:mess_pos/auth_service.dart';
import 'package:mess_pos/user_model.dart';

class AuthScreen extends StatefulWidget {
  final Function(String username, String role) onLoginSuccess;

  const AuthScreen({super.key, required this.onLoginSuccess});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  String? _errorMessage;
  String? _selectedRole; // 'doctor' or 'user'
  final AuthService _authService =
      AuthService(); // Instantiate the auth service
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  Future<void> _handleSubmit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Username and password cannot be empty.';
      });
      return;
    }
    if (_isRegistering && _selectedRole == null) {
      setState(() {
        _errorMessage = 'Please select a role (Doctor or Patient).';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    User? authenticatedUser;
    if (_isRegistering) {
      // For simplicity, new registrations default to 'user' role
      authenticatedUser = await _authService.registerUser(
          username, password, _selectedRole!); // Use selected role
      setState(() {
        _isLoading = false;
        if (authenticatedUser != null) {
          // SUCCESS: Switch to login view with a success message
          _isRegistering = false;
          _errorMessage = 'Registration successful! Please log in.';
          _usernameController.text = username; // Pre-fill username
          _passwordController.clear();
        } else {
          _errorMessage = 'Registration failed. Username might be taken.';
        }
      });
      return; // Stop execution here for registration
    } else {
      authenticatedUser = await _authService.loginUser(username, password);
      if (authenticatedUser == null) {
        _errorMessage = 'Invalid username or password.';
      }
    }

    setState(() {
      _isLoading = false;
      if (authenticatedUser != null) {
        widget.onLoginSuccess(
            authenticatedUser.username, authenticatedUser.role);
      } else {
        // Error message already set by registration/login logic
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_person,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 30),
                        Text(
                          _isRegistering
                              ? 'NEW USER REGISTRATION'
                              : 'APP LOGIN', // Changed "STAFF"
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.vpn_key_outlined),
                          ),
                          onSubmitted: (_) => _handleSubmit(),
                        ),
                        const SizedBox(height: 25),
                        if (_isRegistering) ...[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Select Role:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Doctor'),
                                  value: 'doctor',
                                  groupValue: _selectedRole,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedRole = value;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Patient'),
                                  value: 'user', // Map patient to 'user' role
                                  groupValue: _selectedRole,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedRole = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                        ],
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Text(_errorMessage!,
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                          ),
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 5,
                            ),
                            child: Text(
                              _isRegistering ? 'REGISTER ACCOUNT' : 'LOG IN',
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isRegistering = !_isRegistering;
                              _errorMessage = null;
                              _usernameController.clear();
                              _passwordController.clear();
                              _selectedRole =
                                  null; // Clear selected role on toggle
                            });
                          },
                          child: Text(_isRegistering // Changed "staff"
                              ? 'Already have an account? Log In'
                              : 'New user? Register here'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
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
