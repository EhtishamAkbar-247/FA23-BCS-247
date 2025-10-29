class MenuItem {
  final String id;
  String name;
  double price;
  String category;
  int quantity; // Only used in the Cart

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.quantity = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'category': category,
      };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num?)?.toDouble() ?? 0.0, // Safeguard
        category: json['category'] as String,
      );
}
