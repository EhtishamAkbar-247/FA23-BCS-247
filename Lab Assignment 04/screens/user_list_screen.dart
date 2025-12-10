import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/user_profile.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _supabase = SupabaseService().client;
  List<UserProfile> _users = [];
  List<UserProfile> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from(SupabaseService.tableName)
          .select()
          .order('id', ascending: false);
      
      final data = (response as List).map((e) => UserProfile.fromJson(e)).toList();
      
      setState(() {
        _users = data;
        _filteredUsers = data;
        _isLoading = false;
      });
    } catch (e) {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _filter(String query) {
    setState(() {
      _filteredUsers = _users.where((u) => 
        u.fullName.toLowerCase().contains(query.toLowerCase()) || 
        u.email.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  Future<void> _deleteUser(int id) async {
    await _supabase.from(SupabaseService.tableName).delete().eq('id', id);
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : ListView.builder(
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return Dismissible(
                      key: Key(user.id.toString()),
                      background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteUser(user.id!),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: user.isVerified ? Colors.indigo : Colors.grey,
                            child: Text(user.fullName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${user.role} • ${user.city}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => UserFormScreen(user: user)),
                            ).then((_) => _fetchUsers());
                          },
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserFormScreen()),
          ).then((_) => _fetchUsers());
        },
      ),
    );
  }
}