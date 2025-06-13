class MenuItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final Map<String, int> stock;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.stock = const {},
  });
}