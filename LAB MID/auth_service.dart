import 'dart:math';
import 'package:mess_pos/user_model.dart';

// This class simulates an authentication service using in-memory storage.
// In a real application, this would interact with a backend or secure local storage.
class AuthService {
  static final List<User> _users = [
    User(id: 'doc1', username: 'doctor', password: 'password', role: 'doctor'),
    User(id: 'user1', username: 'user', password: 'password', role: 'user'),
  ];

  // Simulate local storage for persistence across app restarts (optional, but good for mock)
  // For a real app, use shared_preferences or flutter_secure_storage

  Future<User?> loginUser(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    try {
      final user = _users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      return user;
    } catch (e) {
      return null; // User not found or password incorrect
    }
  }

  Future<User?> registerUser(
      String username, String password, String role) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    if (_users.any((u) => u.username == username)) {
      return null; // Username already exists
    }
    final newUser = User(
        id: Random().nextDouble().toString(),
        username: username,
        password: password,
        role: role);
    _users.add(newUser);
    return newUser;
  }
}
