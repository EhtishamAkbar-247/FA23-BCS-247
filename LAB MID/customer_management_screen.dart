import 'dart:math';
import 'package:flutter/material.dart';
import 'customer.dart';
import 'storage_service.dart';

class CustomerManagementScreen extends StatefulWidget {
  final SharedPreferencesService storageService;
  final List<Customer> customers;
  final Function(Customer customer) onCustomerAdded;
  final Function(Customer customer) onCustomerUpdated;

  const CustomerManagementScreen({
    super.key,
    required this.storageService,
    required this.customers,
    required this.onCustomerAdded,
    required this.onCustomerUpdated,
  });

  @override
  State<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _balanceController = TextEditingController(text: '0.00');
  final _searchController = TextEditingController();
  List<Customer> _filteredCustomers = [];

  Future<void> _addCustomer() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final initialBalance = double.tryParse(_balanceController.text) ?? 0.0;

    if (name.isEmpty || phone.isEmpty) {
      if (mounted) {
        _showMessage(
          context,
          'Please enter valid name and phone number.',
          Colors.red,
        );
      }
      return;
    }

    final newCustomer = Customer(
      id: Random().nextDouble().toString(),
      name: name,
      phoneNumber: phone,
      balance: initialBalance,
    );

    widget.onCustomerAdded(newCustomer);

    await widget.storageService.saveCustomers([
      ...widget.customers,
      newCustomer,
    ]);

    if (!mounted) return;

    _nameController.clear();
    _phoneController.clear();
    _balanceController.text = '0.00';

    _showMessage(
      context,
      'Customer registered successfully!',
      Colors.green,
    );
  }

  @override
  void initState() {
    super.initState();
    _filteredCustomers = widget.customers;
    _searchController.addListener(_filterCustomers);
  }

  @override
  void didUpdateWidget(covariant CustomerManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customers != widget.customers) {
      _filterCustomers(); // Re-filter if the underlying data changes
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = widget.customers.where((customer) {
        return customer.name.toLowerCase().contains(query) ||
            customer.phoneNumber.toLowerCase().contains(query) ||
            customer.balance.toStringAsFixed(2).contains(query);
      }).toList();
    });
  }

  Future<void> _payDues(Customer customer) async {
    final payAmountController = TextEditingController();
    double? paidAmount;

    await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Pay Dues for ${customer.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Balance: \$${customer.balance.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: payAmountController,
              decoration: const InputDecoration(
                labelText: 'Amount to Pay',
                prefixIcon: Icon(Icons.money),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final input = double.tryParse(payAmountController.text);
              if (input != null && input > 0 && input <= customer.balance) {
                paidAmount = input;
                Navigator.pop(dialogContext, paidAmount);
              } else if (input != null && input > customer.balance) {
                _showMessage(dialogContext,
                    'Amount paid cannot exceed pending dues.', Colors.red);
              } else {
                _showMessage(
                    dialogContext, 'Please enter a valid amount.', Colors.red);
              }
            },
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );

    if (paidAmount != null && mounted) {
      final updatedBalance = customer.balance - paidAmount!;
      customer.balance = double.parse(updatedBalance.toStringAsFixed(2));

      widget.onCustomerUpdated(customer);
      await widget.storageService.saveCustomers(widget.customers);

      if (mounted) {
        _showMessage(
          context,
          'Dues of \$${paidAmount.toString()} paid for ${customer.name}. '
          'New balance: \$${customer.balance.toStringAsFixed(2)}',
          Colors.green,
        );
      }
    }
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
            const Text('REGISTER NEW CUSTOMER',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                              labelText: 'Customer Name',
                              prefixIcon: Icon(Icons.person_add))),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 200),
                      child: TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone)),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 180),
                      child: TextField(
                        controller: _balanceController,
                        decoration: const InputDecoration(
                            labelText: 'Initial Balance (\$)',
                            prefixIcon: Icon(Icons.account_balance_wallet)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addCustomer,
                      icon: const Icon(Icons.person_add_alt_1,
                          color: Colors.white),
                      label: const Text(
                        'REGISTER',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        minimumSize: const Size(120, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 30),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Customers (Name, Phone, Balance)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              onChanged: (_) => _filterCustomers(),
            ),
            const SizedBox(height: 10),
            const Text('REGISTERED CUSTOMERS',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            ListView.builder(
              itemCount: _filteredCustomers.length,
              shrinkWrap: true,
              primary: false, // Important for nested scrolling
              itemBuilder: (context, index) {
                final customer = _filteredCustomers[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(customer.name[0])),
                    title: Text(customer.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Phone: ${customer.phoneNumber}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Balance: \$${customer.balance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: customer.balance > 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        if (customer.balance > 0)
                          IconButton(
                            icon: const Icon(Icons.payment, color: Colors.blue),
                            onPressed: () => _payDues(customer),
                            tooltip: 'Pay Dues',
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
