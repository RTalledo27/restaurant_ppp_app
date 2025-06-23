class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final String note;
  final double price;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.note = '',
    required this.price,
  });

  double get total => price * quantity;
}
