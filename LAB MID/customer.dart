class Customer {
  final String id;
  String name;
  String phoneNumber;
  double balance;

  Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.balance,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'balance': balance,
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        name: json['name'] as String,
        phoneNumber: json['phoneNumber'] as String? ?? 'N/A',
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0, // Safeguard
      );

  static Customer walkIn = Customer(
      id: 'walk_in', name: 'Walk-in Customer', phoneNumber: '', balance: 0.0);
}
