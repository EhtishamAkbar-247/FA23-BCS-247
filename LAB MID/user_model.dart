class User {
  final String id;
  final String username;
  final String password; // In a real app, store hashed passwords
  final String role; // 'doctor' or 'user'

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'role': role,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        username: json['username'] as String,
        password: json['password'] as String,
        role: json['role'] as String,
      );
}
