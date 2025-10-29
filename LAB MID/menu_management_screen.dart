import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mess_pos/menu_item.dart';
import 'package:mess_pos/category.dart';
import 'package:mess_pos/storage_service.dart';

class MenuManagementScreen extends StatefulWidget {
  final SharedPreferencesService storageService;
  final List<MenuItem> menuItems;
  final List<Category> categories;
  final Function(MenuItem item) onMenuItemAdded;
  final Function(List<MenuItem> newMenu) onMenuUpdated;

  const MenuManagementScreen({
    super.key,
    required this.storageService,
    required this.menuItems,
    required this.categories,
    required this.onMenuItemAdded,
    required this.onMenuUpdated,
  });

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  MenuItem? _editingItem;
  final _searchController = TextEditingController();
  List<MenuItem> _filteredMenuItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first.name;
    }
    _filteredMenuItems = widget.menuItems; // Initialize with all items
    _searchController.addListener(_filterMenuItems);
  }

  @override
  void didUpdateWidget(covariant MenuManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.menuItems != widget.menuItems ||
        oldWidget.categories != widget.categories) {
      // Re-filter if the underlying data changes
      _filterMenuItems();
    }
    // Ensure selected category is still valid if categories change
    if (!widget.categories.any((cat) => cat.name == _selectedCategory)) {
      _selectedCategory =
          widget.categories.isNotEmpty ? widget.categories.first.name : null;
    }
  }

  void _resetForm() {
    _nameController.clear();
    _priceController.clear();
    setState(() {
      _editingItem = null;
      _selectedCategory =
          widget.categories.isNotEmpty ? widget.categories.first.name : null;
    });
    _filterMenuItems(); // Re-filter after form reset
  }

  void _filterMenuItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMenuItems = widget.menuItems.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query) ||
            item.price.toString().contains(query);
      }).toList();
    });
  }

  void _startEdit(MenuItem item) {
    setState(() {
      _editingItem = item;
      _nameController.text = item.name;
      _priceController.text = item.price.toString();
      _selectedCategory = item.category;
    });
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final category = _selectedCategory;

    if (name.isEmpty || price <= 0 || category == null || category.isEmpty) {
      _showMessage(context,
          'Please enter valid name, price, and select a category.', Colors.red);
      return;
    }

    if (_editingItem == null) {
      final newItem = MenuItem(
        id: Random().nextDouble().toString(),
        name: name,
        price: price,
        category: category,
      );
      widget.onMenuItemAdded(newItem);
      await widget.storageService.saveMenu([...widget.menuItems, newItem]);
      if (!mounted) return;
      _showMessage(context, 'Menu Item added successfully!', Colors.green);
    } else {
      _editingItem!.name = name;
      _editingItem!.price = price;
      _editingItem!.category = category;
      widget.onMenuUpdated(widget.menuItems);
      await widget.storageService.saveMenu(widget.menuItems);
      if (!mounted) return;
      _showMessage(context, 'Menu Item updated successfully!', Colors.green);
    }
    _resetForm();
  }

  Future<void> _deleteItem(MenuItem item) async {
    final updatedMenu = widget.menuItems.where((i) => i.id != item.id).toList();
    widget.onMenuUpdated(updatedMenu);
    await widget.storageService.saveMenu(updatedMenu);
    if (!mounted) return;
    _showMessage(context, 'Item deleted.', Colors.orange);
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
            Text(_editingItem == null ? 'ADD NEW MENU ITEM' : 'EDIT MENU ITEM',
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
                      constraints: const BoxConstraints(minWidth: 200),
                      child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(Icons.food_bank))),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: TextField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                            labelText: 'Price (\$)',
                            prefixIcon: Icon(Icons.attach_money)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 200),
                      child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category),
                          ),
                          value: _selectedCategory,
                          items: widget.categories.map((Category cat) {
                            return DropdownMenuItem<String>(
                              value: cat.name,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Select a category' : null),
                    ),
                    ElevatedButton.icon(
                      onPressed: _handleSave,
                      icon: Icon(_editingItem == null ? Icons.add : Icons.save,
                          color: Colors.white),
                      label: Text(
                        _editingItem == null ? 'ADD' : 'SAVE',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _editingItem == null ? Colors.green : Colors.indigo,
                        minimumSize: const Size(120, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    if (_editingItem != null)
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
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Menu Items (Name, Category, Price)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              onChanged: (_) => _filterMenuItems(),
            ),
            const SizedBox(height: 10),
            const Text('CURRENT MENU ITEMS',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            ListView.builder(
              itemCount: _filteredMenuItems.length,
              shrinkWrap: true,
              primary: false, // Important for nested scrolling
              itemBuilder: (context, index) {
                final item = _filteredMenuItems[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(item.category[0])),
                    title: Text(item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Category: ${item.category}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green)),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.indigo),
                          onPressed: () => _startEdit(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteItem(item),
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
