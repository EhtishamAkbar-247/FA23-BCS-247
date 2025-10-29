import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mess_pos/patient.dart'; // This import is already correct.

class PatientEditScreen extends StatefulWidget {
  final Patient? patient;
  final Function(Patient) onSave;

  const PatientEditScreen({
    super.key,
    this.patient,
    required this.onSave,
  });

  @override
  State<PatientEditScreen> createState() => _PatientEditScreenState();
}

class _PatientEditScreenState extends State<PatientEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _diagnosisController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _recommendedMedicineController;
  late TextEditingController _referredDoctorController;
  late TextEditingController _precautionsController;
  late TextEditingController _nextAppointmentController;
  File? _imageFile;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patient?.name ?? '');
    _phoneController =
        TextEditingController(text: widget.patient?.phoneNumber ?? '');
    _diagnosisController =
        TextEditingController(text: widget.patient?.diagnosis ?? '');
    _dobController = TextEditingController(
        text: widget.patient?.dateOfBirth != null
            ? _formatDate(widget.patient!.dateOfBirth!)
            : '');
    _addressController =
        TextEditingController(text: widget.patient?.address ?? '');
    _emailController = TextEditingController(text: widget.patient?.email ?? '');
    _recommendedMedicineController =
        TextEditingController(text: widget.patient?.recommendedMedicine ?? '');
    _referredDoctorController =
        TextEditingController(text: widget.patient?.referredDoctor ?? '');
    _precautionsController =
        TextEditingController(text: widget.patient?.precautions ?? '');
    _nextAppointmentController = TextEditingController(
        text: widget.patient?.nextAppointment != null
            ? _formatDate(widget.patient!.nextAppointment!)
            : '');
    if (widget.patient?.imagePath != null) {
      _imageFile = File(widget.patient!.imagePath!);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.patient?.dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != widget.patient?.dateOfBirth) {
      setState(() {
        _dobController.text = _formatDate(picked);
        // Temporarily store the DateTime object, will be used in _handleSave
        // A more robust solution might involve a separate DateTime field in state
        // or parsing _dobController.text in _handleSave.
        // For simplicity, we'll parse it in _handleSave.
      });
    }
  }

  Future<void> _selectAppointmentDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.patient?.nextAppointment ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != widget.patient?.nextAppointment) {
      setState(() {
        _nextAppointmentController.text = _formatDate(picked);
      });
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final patient = Patient(
        id: widget.patient?.id ?? DateTime.now().toIso8601String(),
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        diagnosis: _diagnosisController.text,
        imagePath: _imageFile?.path,
        dateOfBirth: _dobController.text.isNotEmpty
            ? DateTime.tryParse(
                _dobController.text.split('/').reversed.join('-'))
            : null,
        gender: _selectedGender,
        address: _addressController.text,
        email: _emailController.text,
        recommendedMedicine: _recommendedMedicineController.text,
        referredDoctor: _referredDoctorController.text,
        precautions: _precautionsController.text,
        nextAppointment: _nextAppointmentController.text.isNotEmpty
            ? DateTime.tryParse(
                _nextAppointmentController.text.split('/').reversed.join('-'))
            : null,
      );
      widget.onSave(patient);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient == null ? 'Add Patient' : 'Edit Patient'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: _buildAnimatedFormFields(),
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

  List<Widget> _buildAnimatedFormFields() {
    final fields = <Widget>[
      GestureDetector(
        onTap: _pickImage,
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Colors.blue[100],
          backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
          child: _imageFile == null
              ? const Icon(Icons.person_add_alt_1,
                  size: 50, color: Colors.white)
              : null,
        ),
      ),
      TextButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.photo_camera),
        label: const Text('Upload Photo'),
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'Patient Name'),
        validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _phoneController,
        decoration: const InputDecoration(labelText: 'Phone Number'),
        keyboardType: TextInputType.phone,
        validator: (value) =>
            value!.isEmpty ? 'Please enter a phone number' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _diagnosisController,
        decoration: const InputDecoration(labelText: 'Diagnosis'),
        maxLines: 3,
        validator: (value) =>
            value!.isEmpty ? 'Please enter a diagnosis' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _dobController,
        decoration: const InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: () => _selectDate(context),
        validator: (value) =>
            value!.isEmpty ? 'Please select date of birth' : null,
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _selectedGender ?? widget.patient?.gender,
        decoration: const InputDecoration(
          labelText: 'Gender',
          prefixIcon: Icon(Icons.person_outline),
        ),
        items: <String>['Male', 'Female', 'Other']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        validator: (value) => value == null ? 'Please select a gender' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _addressController,
        decoration: const InputDecoration(labelText: 'Address'),
        maxLines: 2,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _emailController,
        decoration: const InputDecoration(labelText: 'Email'),
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _recommendedMedicineController,
        decoration: const InputDecoration(labelText: 'Recommended Medicine'),
        maxLines: 2,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _referredDoctorController,
        decoration: const InputDecoration(labelText: 'Referred Doctor'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _precautionsController,
        decoration: const InputDecoration(labelText: 'Precautions'),
        maxLines: 3,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _nextAppointmentController,
        decoration: const InputDecoration(
          labelText: 'Next Appointment Date',
          prefixIcon: Icon(Icons.event_available),
        ),
        readOnly: true,
        onTap: () => _selectAppointmentDate(context),
      ),
      const SizedBox(height: 30),
      ElevatedButton.icon(
        onPressed: _handleSave,
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text(
          'Save Patient',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ];

    return List.generate(fields.length, (index) {
      return _AnimatedSlideFade(
        delay: Duration(milliseconds: 100 * index),
        child: fields[index],
      );
    });
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
