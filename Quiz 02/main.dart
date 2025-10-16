import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz 2 - SQLite CRUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StudentScreen(),
    );
  }
}

// ---------------- DATABASE HELPER ----------------
class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'students.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        age INTEGER,
        image TEXT
      )
    ''');
  }

  Future<int> insertStudent(Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.insert('students', data);
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    final dbClient = await db;
    return await dbClient.query('students');
  }

  Future<int> updateStudent(Map<String, dynamic> data, int id) async {
    final dbClient = await db;
    return await dbClient.update(
      'students',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final dbClient = await db;
    return await dbClient.delete('students', where: 'id = ?', whereArgs: [id]);
  }
}

// ---------------- MAIN SCREEN ----------------
class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> students = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  File? imageFile;
  int? selectedId;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    final data = await dbHelper.getStudents();
    setState(() => students = data);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  void clearFields() {
    nameController.clear();
    emailController.clear();
    ageController.clear();
    imageFile = null;
    selectedId = null;
  }

  Future<void> addOrUpdateStudent() async {
    final student = {
      'name': nameController.text,
      'email': emailController.text,
      'age': int.tryParse(ageController.text) ?? 0,
      'image': imageFile?.path ?? '',
    };

    if (selectedId == null) {
      await dbHelper.insertStudent(student);
    } else {
      await dbHelper.updateStudent(student, selectedId!);
    }

    clearFields();
    loadStudents();
  }

  Future<void> deleteStudent(int id) async {
    await dbHelper.deleteStudent(id);
    loadStudents();
  }

  void editStudent(Map<String, dynamic> student) {
    setState(() {
      selectedId = student['id'];
      nameController.text = student['name'];
      emailController.text = student['email'];
      ageController.text = student['age'].toString();
      if (student['image'].isNotEmpty) {
        imageFile = File(student['image']);
      } else {
        imageFile = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQLite CRUD Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imageFile != null
                    ? FileImage(imageFile!)
                    : const AssetImage('assets/placeholder.png')
                          as ImageProvider,
              ),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addOrUpdateStudent,
              child: Text(
                selectedId == null ? 'Add Student' : 'Update Student',
              ),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              itemCount: students.length,
              itemBuilder: (context, index) {
                final s = students[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: s['image'] != ''
                          ? FileImage(File(s['image']))
                          : const AssetImage('assets/placeholder.png')
                                as ImageProvider,
                    ),
                    title: Text(s['name']),
                    subtitle: Text("${s['email']} | Age: ${s['age']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editStudent(s),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteStudent(s['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
