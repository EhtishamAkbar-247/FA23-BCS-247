import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mess_pos/patient.dart';
import 'package:mess_pos/patient_database_service.dart';
import 'package:intl/intl.dart'; // Corrected import

class UserDashboardScreen extends StatefulWidget {
  final String username;
  const UserDashboardScreen({super.key, required this.username});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final PatientDatabaseService _dbService = PatientDatabaseService();
  Patient? _currentPatient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    final allPatients = await _dbService.loadPatients();
    try {
      final patient = allPatients.firstWhere((p) => p.name == widget.username);
      setState(() {
        _currentPatient = patient;
        _isLoading = false;
      });
    } catch (e) {
      // Handle case where patient is not found
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPatient == null
              ? const Center(
                  child: Text('Patient record not found for this user.'))
              : _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildAppointmentCard(),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Current Diagnosis',
          content: _currentPatient!.diagnosis,
          icon: Icons.local_hospital,
          iconColor: Colors.red.shade400,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Doctor\'s Precautions',
          content: _currentPatient!.precautions ?? 'No precautions specified.',
          icon: Icons.health_and_safety,
          iconColor: Colors.orange.shade400,
        ),
        const SizedBox(height: 16),
        _buildActionsCard(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue[100],
          backgroundImage: _currentPatient!.imagePath != null
              ? FileImage(File(_currentPatient!.imagePath!))
              : null,
          child: _currentPatient!.imagePath == null
              ? Text(_currentPatient!.name[0],
                  style: const TextStyle(fontSize: 24))
              : null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back,',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text(
              _currentPatient!.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppointmentCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade700,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Next Appointment',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text(
                  _currentPatient!.nextAppointment != null
                      ? DateFormat('EEEE, MMMM d, yyyy')
                          .format(_currentPatient!.nextAppointment!)
                      : 'Not Scheduled',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title,
      required String content,
      required IconData icon,
      required Color iconColor}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.receipt_long, color: Colors.blue, size: 30),
        title: const Text('Generate Full Report',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('View your complete health summary'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showReportDialog(context),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Health Report'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              _buildReportRow('Patient Name:', _currentPatient!.name),
              const Divider(),
              _buildReportRow('Diagnosis:', _currentPatient!.diagnosis),
              const Divider(),
              _buildReportRow(
                  'Precautions:', _currentPatient!.precautions ?? 'N/A'),
              const Divider(),
              _buildReportRow('Recommended Medicine:',
                  _currentPatient!.recommendedMedicine ?? 'N/A'),
              const Divider(),
              _buildReportRow(
                  'Referred Doctor:', _currentPatient!.referredDoctor ?? 'N/A'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
