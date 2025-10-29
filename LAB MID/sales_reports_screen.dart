import 'package:flutter/material.dart';
import 'package:mess_pos/transaction.dart'; // Corrected import
// ignore: unused_import
import 'package:mess_pos/menu_item.dart'; // Corrected import // Kept for explicit type usage in item lists.

class SalesReportsScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const SalesReportsScreen({super.key, required this.transactions});

  @override
  State<SalesReportsScreen> createState() => _SalesReportsScreenState();
}

class _SalesReportsScreenState extends State<SalesReportsScreen> {
  final TextEditingController _transactionSearchController =
      TextEditingController();
  List<Transaction> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _filteredTransactions = widget.transactions;
    _transactionSearchController.addListener(_filterTransactions);
  }

  @override
  void dispose() {
    _transactionSearchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SalesReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions) {
      _filterTransactions(); // Re-filter if the underlying data changes
    }
  }

  void _filterTransactions() {
    final query = _transactionSearchController.text.toLowerCase();
    setState(() {
      _filteredTransactions = widget.transactions.where((t) {
        return t.customerName.toLowerCase().contains(query) ||
            t.id.toLowerCase().contains(query) ||
            t.operatorName.toLowerCase().contains(query) ||
            t.items.any((item) => item.name.toLowerCase().contains(query));
      }).toList();
    });
  }

  double get _totalSale =>
      _filteredTransactions.fold(0.0, (sum, t) => sum + t.totalAmount);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              color: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text('TOTAL REVENUE (ALL SALES)',
                          style: TextStyle(
                              // Reduced font size
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '\$${_totalSale.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 30, // Reduced font size
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 30),
            TextField(
              controller: _transactionSearchController,
              decoration: const InputDecoration(
                labelText: 'Search Transactions (Customer, ID, Operator, Item)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              onChanged: (_) => _filterTransactions(),
            ),
            const SizedBox(height: 10),
            const Text('TRANSACTION HISTORY (RECEIPTS)',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            widget.transactions.isEmpty
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No transactions recorded yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ))
                : ListView.builder(
                    itemCount: _filteredTransactions.length,
                    shrinkWrap: true,
                    primary: false, // Important for nested scrolling
                    itemBuilder: (context, index) {
                      final t = _filteredTransactions[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading:
                              CircleAvatar(child: Text((index + 1).toString())),
                          title: Text('Sale to: ${t.customerName}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              'ID: ${t.id.substring(0, 8)} | Date: ${t.timestamp.toString().substring(0, 16)}'),
                          trailing: Text(
                            '\$${t.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.indigo),
                          ),
                          onTap: () => _showReceiptDialog(context, t),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _showReceiptDialog(BuildContext context, Transaction t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Column(
            children: [
              const Text('TRANSACTION RECEIPT',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(t.id.substring(0, 15),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        content: SizedBox(
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                _receiptRow('Customer', t.customerName),
                _receiptRow('Operator', t.operatorName),
                _receiptRow('Date', t.timestamp.toString().substring(0, 16)),
                const Divider(),
                const Text('Items:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ...t.items.map((item) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.name} x ${item.quantity}'),
                          Text(
                              '\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                        ],
                      ),
                    )),
                const Divider(color: Colors.black),
                _receiptRow('Subtotal', '\$${t.subtotal.toStringAsFixed(2)}'),
                _receiptRow('Tax (8%)', '\$${t.tax.toStringAsFixed(2)}'),
                _receiptRow(
                    'Total Bill', '\$${t.totalAmount.toStringAsFixed(2)}',
                    isTotal: true),
                _receiptRow(
                    'Amount Paid', '\$${t.amountPaid.toStringAsFixed(2)}',
                    isTotal: true),
                _receiptRow(
                    'Remaining Due', '\$${t.remainingDue.toStringAsFixed(2)}',
                    isTotal: true),
                const Divider(color: Colors.black),
                _receiptRow('Old Balance',
                    '\$${t.customerOldBalance.toStringAsFixed(2)}'),
                _receiptRow('New Balance',
                    '\$${t.customerNewBalance.toStringAsFixed(2)}',
                    isTotal: true),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 16 : 14)),
        ],
      ),
    );
  }
}
