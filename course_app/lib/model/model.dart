// model.dart

class Course {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite; // New attribute to track if the course is in favorites

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavorite = false,
  });
}

class CartItem {
  final String id;
  final Course course;
  int quantity;

  CartItem({
    required this.id,
    required this.course,
    this.quantity = 1,
  });
}

class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime dateTime;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.dateTime,
  });
}
