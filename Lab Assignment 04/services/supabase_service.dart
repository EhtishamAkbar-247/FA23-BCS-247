import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://bwnxfcmfcpwflidkdoqs.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3bnhmY21mY3B3ZmxpZGtkb3FzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzNzMyMzgsImV4cCI6MjA4MDk0OTIzOH0.S1JwtcbJmfyOnvuIurp__IwenHfr1LLwSG3AkDw55j0';
  
  static const String tableName = 'profiles'; // <--- NEW TABLE NAME

  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  SupabaseClient get client => Supabase.instance.client;
}
