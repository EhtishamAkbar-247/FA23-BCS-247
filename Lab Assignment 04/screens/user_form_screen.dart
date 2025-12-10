import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // REQUIRED: Add intl to pubspec.yaml
import '../services/supabase_service.dart';
import '../models/user_profile.dart';

class UserFormScreen extends StatefulWidget {
  final UserProfile? user;
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = SupabaseService().client;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  
  String _role = 'User';
  bool _isVerified = false;
  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      final u = widget.user!;
      _nameCtrl.text = u.fullName;
      _emailCtrl.text = u.email;
      _phoneCtrl.text = u.phone;
      _cityCtrl.text = u.city;
      _bioCtrl.text = u.bio;
      _role = u.role;
      _isVerified = u.isVerified;
      if (u.dob != null) {
        _selectedDate = u.dob;
        _dobCtrl.text = DateFormat('yyyy-MM-dd').format(u.dob!);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final newUser = UserProfile(
      id: widget.user?.id,
      fullName: _nameCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      city: _cityCtrl.text,
      role: _role,
      dob: _selectedDate,
      isVerified: _isVerified,
      bio: _bioCtrl.text,
    );

    try {
      if (widget.user == null) {
        await _supabase.from(SupabaseService.tableName).insert(newUser.toJson());
      } else {
        await _supabase.from(SupabaseService.tableName).update(newUser.toJson()).eq('id', widget.user!.id!);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved Successfully!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user == null ? 'Create Profile' : 'Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput(_nameCtrl, 'Full Name', Icons.person, true),
              const SizedBox(height: 15),
              _buildInput(_emailCtrl, 'Email Address', Icons.email, true),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildInput(_phoneCtrl, 'Phone', Icons.phone, false)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput(_cityCtrl, 'City', Icons.location_city, false)),
                ],
              ),
              const SizedBox(height: 15),
              
              // Date Picker Field
              TextFormField(
                controller: _dobCtrl,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date of Birth', prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                onTap: _pickDate,
              ),
              const SizedBox(height: 15),

              // Role Dropdown
              DropdownButtonFormField(
                value: _role,
                decoration: const InputDecoration(labelText: 'User Role', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge)),
                items: ['Admin', 'Manager', 'User', 'Guest'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState(() => _role = v as String),
              ),
              const SizedBox(height: 15),

              // Switch
              SwitchListTile(
                title: const Text('Verified User'),
                secondary: const Icon(Icons.verified, color: Colors.blue),
                value: _isVerified,
                onChanged: (v) => setState(() => _isVerified = v),
              ),

              const SizedBox(height: 15),
              TextFormField(
                controller: _bioCtrl,
                decoration: const InputDecoration(labelText: 'Short Bio', border: OutlineInputBorder(), alignLabelWithHint: true),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('SAVE DATA'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, bool required) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
      validator: required ? (v) => v!.isEmpty ? 'Required' : null : null,
    );
  }
}