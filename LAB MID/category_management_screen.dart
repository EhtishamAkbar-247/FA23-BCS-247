import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mess_pos/category.dart';
import 'package:mess_pos/storage_service.dart';

class CategoryManagementScreen extends StatefulWidget {
  final SharedPreferencesService storageService;
  final List<Category> categories;
  final Function(Category category) onCategoryAdded;
  final Function(List<Category> newCategories) onCategoriesUpdated;

  const CategoryManagementScreen({
    super.key,
    required this.storageService,
    required this.categories,
    required this.onCategoryAdded,
    required this.onCategoriesUpdated,
  });

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _nameController = TextEditingController();
  Category? _editingCategory;

  void _resetForm() {
    _nameController.clear();
    setState(() {
      _editingCategory = null;
    });
  }

  void _startEdit(Category category) {
    setState(() {
      _editingCategory = category;
      _nameController.text = category.name;
    });
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage(context, 'Please enter a valid category name.', Colors.red);
      return;
    }

    if (_editingCategory == null) {
      final newCategory = Category(
        id: Random().nextDouble().toString(),
        name: name,
      );
      widget.onCategoryAdded(newCategory);
      await widget.storageService
          .saveCategories([...widget.categories, newCategory]);
      if (!mounted) return;
      _showMessage(context, 'Category added successfully!', Colors.green);
    } else {
      _editingCategory!.name = name;
      widget.onCategoriesUpdated(widget.categories);
      await widget.storageService.saveCategories(widget.categories);
      if (!mounted) return;
      _showMessage(context, 'Category updated successfully!', Colors.green);
    }
    _resetForm();
  }

  Future<void> _deleteCategory(Category category) async {
    final updatedCategories =
        widget.categories.where((c) => c.id != category.id).toList();
    widget.onCategoriesUpdated(updatedCategories);
    await widget.storageService.saveCategories(updatedCategories);
    if (!mounted) return;
    _showMessage(context, 'Category deleted.', Colors.orange);
  }

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                _editingCategory == null ? 'ADD NEW CATEGORY' : 'EDIT CATEGORY',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 250),
                      child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              labelText: 'Category Name',
                              prefixIcon: Icon(Icons.category))),
                    ),
                    ElevatedButton.icon(
                      onPressed: _handleSave,
                      icon: Icon(
                          _editingCategory == null ? Icons.add : Icons.save,
                          color: Colors.white),
                      label: Text(
                        _editingCategory == null ? 'ADD' : 'SAVE',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _editingCategory == null
                            ? Colors.green
                            : Colors.indigo,
                        minimumSize: const Size(120, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    if (_editingCategory != null)
                      OutlinedButton.icon(
                        onPressed: _resetForm,
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size(100, 55),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 30),
            const Text('CURRENT CATEGORIES',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            ListView.builder(
              itemCount: widget.categories.length,
              shrinkWrap: true,
              primary: false, // Important for nested scrolling
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(category.name[0])),
                    title: Text(category.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.indigo),
                          onPressed: () => _startEdit(category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(category),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ]),
        ));
  }
}
