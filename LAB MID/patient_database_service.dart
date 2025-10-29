import 'dart:convert';
import 'package:mess_pos/patient.dart'; // This import is already correct.

// This class simulates a local database using a mock in-memory storage.
// For a real application, this would be replaced with a package like sqflite.
class PatientDatabaseService {
  static const String _patientsKey = 'patients_key';

  // Mock in-memory storage.
  static final Map<String, String> _mockStorage = {};

  // Initial dummy data for the app.
  List<Patient> _getInitialPatients() => [
        Patient(
            id: 'p1',
            name: "John Doe",
            phoneNumber: '123-456-7890',
            diagnosis: 'Common Cold',
            dateOfBirth: DateTime(1985, 5, 15),
            gender: 'Male',
            address: '123 Main St, Anytown',
            email: 'john.doe@example.com',
            recommendedMedicine: 'Paracetamol 500mg',
            referredDoctor: 'Dr. Emily White',
            precautions: 'Rest and drink plenty of fluids.',
            nextAppointment: DateTime.now().add(const Duration(days: 7))),
        Patient(
            id: 'p2',
            name: "Jane Smith",
            phoneNumber: '987-654-3210',
            diagnosis: 'Migraine',
            dateOfBirth: DateTime(1992, 11, 22),
            gender: 'Female',
            address: '456 Oak Ave, Otherville',
            email: 'jane.smith@example.com',
            recommendedMedicine: 'Ibuprofen 200mg',
            referredDoctor: 'Dr. Alex Green',
            precautions: 'Avoid bright lights and loud noises.',
            nextAppointment: DateTime.now().add(const Duration(days: 14))),
      ];

  // Generic method to load data from mock storage.
  Future<List<T>> _loadData<T>(
      // Corrected type parameter constraint
      String key,
      T Function(Map<String, dynamic>) fromJson,
      List<T> Function() initialData) async {
    String? jsonString = _mockStorage[key];
    if (jsonString == null) {
      final data = initialData();
      await _saveData(key, data);
      return data;
    }
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => fromJson(e)).toList();
  }

  // Generic method to save data to mock storage. // Corrected type parameter constraint
  Future<void> _saveData<T>(String key, List<T> data) async {
    final jsonString =
        jsonEncode(data.map((e) => (e as dynamic).toJson()).toList());
    _mockStorage[key] = jsonString;
  }

  Future<List<Patient>> loadPatients() async =>
      _loadData(_patientsKey, Patient.fromJson, _getInitialPatients);
  Future<void> savePatients(List<Patient> patients) async =>
      _saveData(_patientsKey, patients);
}
