import 'package:mess_pos/menu_item.dart'; // Corrected import

class Transaction {
  final String id;
  final DateTime timestamp;
  final String customerName;
  final double totalAmount;
  final double tax;
  final double subtotal;
  final List<MenuItem> items;
  final double customerOldBalance;
  final double customerNewBalance;
  final String operatorName;
  final double amountPaid;
  final double remainingDue;

  Transaction({
    required this.id,
    required this.timestamp,
    required this.customerName,
    required this.totalAmount,
    required this.tax,
    required this.subtotal,
    required this.items,
    required this.customerOldBalance,
    required this.customerNewBalance,
    required this.operatorName,
    required this.amountPaid,
    required this.remainingDue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'customerName': customerName,
        'totalAmount': totalAmount,
        'tax': tax,
        'subtotal': subtotal,
        'items': items.map((e) => e.toJson()).toList(),
        'customerOldBalance': customerOldBalance,
        'customerNewBalance': customerNewBalance,
        'amountPaid': amountPaid,
        'remainingDue': remainingDue,
        'operatorName': operatorName,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        customerName: json['customerName'] as String,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
        items: (json['items'] as List<dynamic>)
            .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        customerOldBalance:
            (json['customerOldBalance'] as num?)?.toDouble() ?? 0.0,
        customerNewBalance:
            (json['customerNewBalance'] as num?)?.toDouble() ?? 0.0,
        operatorName: json['operatorName'] as String? ?? 'Unknown',
        amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
        remainingDue: (json['remainingDue'] as num?)?.toDouble() ?? 0.0,
      );
}
