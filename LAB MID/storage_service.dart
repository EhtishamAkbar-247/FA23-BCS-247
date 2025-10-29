import 'dart:convert';

import 'package:mess_pos/category.dart'; // Corrected import
import 'package:mess_pos/customer.dart'; // Corrected import
import 'package:mess_pos/menu_item.dart'; // Corrected import
import 'package:mess_pos/transaction.dart'; // Corrected import
import 'package:mess_pos/user.dart'; // Corrected import

class SharedPreferencesService {
  static const String _menuKey = 'menu_items';
  static const String _customersKey = 'customer_records';
  static const String _usersKey = 'user_accounts';
  static const String _transactionsKey = 'transaction_history';
  static const String _categoriesKey = 'menu_categories';

  static final Map<String, String> _mockStorage = {};

  List<MenuItem> _getInitialMenuItems() => [
        MenuItem(
            id: 'c1',
            name: "Chicken Curry Meal",
            price: 12.50,
            category: 'Main'),
        MenuItem(
            id: 'v1',
            name: "Vegetable Soup",
            price: 4.00,
            category: 'Appetizer'),
        MenuItem(
            id: 'f1', name: "Fruit Salad", price: 3.50, category: 'Dessert'),
        MenuItem(id: 'i1', name: "Iced Tea", price: 2.00, category: 'Beverage'),
      ];

  List<Customer> _getInitialCustomers() => [
        Customer(
            id: 'u1',
            name: "Ahmed Khan",
            phoneNumber: '923001234567',
            balance: 55.75),
        Customer(
            id: 'u2',
            name: "Sara Ali",
            phoneNumber: '923219876543',
            balance: 0.00),
        Customer(
            id: 'u3',
            name: "Usman Tariq",
            phoneNumber: '923455554444',
            balance: 120.50),
      ];

  List<User> _getInitialUsers() => [
        User(id: 'admin_id', username: 'admin', passwordHash: 'pass123'),
      ];

  List<Category> _getInitialCategories() => [
        Category(id: 'cat1', name: 'Main'),
        Category(id: 'cat2', name: 'Appetizer'),
        Category(id: 'cat3', name: 'Dessert'),
        Category(id: 'cat4', name: 'Beverage'),
      ];

  Future<List<T>> _loadData<T>(
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

  Future<void> _saveData<T>(String key, List<T> data) async {
    final jsonString =
        jsonEncode(data.map((e) => (e as dynamic).toJson()).toList());
    _mockStorage[key] = jsonString;
  }

  Future<List<MenuItem>> loadMenu() async =>
      _loadData(_menuKey, MenuItem.fromJson, _getInitialMenuItems);
  Future<void> saveMenu(List<MenuItem> menu) async => _saveData(_menuKey, menu);

  Future<List<Customer>> loadCustomers() async =>
      _loadData(_customersKey, Customer.fromJson, _getInitialCustomers);
  Future<void> saveCustomers(List<Customer> customers) async =>
      _saveData(_customersKey, customers);

  Future<List<User>> loadUsers() async =>
      _loadData(_usersKey, User.fromJson, _getInitialUsers);
  Future<void> saveUsers(List<User> users) async => _saveData(_usersKey, users);

  Future<List<Transaction>> loadTransactions() async =>
      _loadData(_transactionsKey, Transaction.fromJson, () => []);
  Future<void> saveTransactions(List<Transaction> transactions) async =>
      _saveData(_transactionsKey, transactions);

  Future<List<Category>> loadCategories() async =>
      _loadData(_categoriesKey, Category.fromJson, _getInitialCategories);
  Future<void> saveCategories(List<Category> categories) async =>
      _saveData(_categoriesKey, categories);
}
