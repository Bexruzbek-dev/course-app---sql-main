// cart_page.dart

import 'package:flutter/material.dart';
import 'package:course_app/services/services.dart';
import 'package:course_app/model/model.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CourseService _courseService = CourseService();

  @override
  Widget build(BuildContext context) {
    final cartItems = _courseService.getCartItems();

    return Scaffold(
      appBar: AppBar(
        title: Text('Savatcha'),
      ),
      body: cartItems.isEmpty
          ? Center(child: Text('Savatchada kurslar yo\'q'))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = cartItems[index];
                return ListTile(
                  leading: Image.network(
                    cartItem.course.imageUrl ??
                        'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                    height: 50,
                    width: 50,
                  ),
                  title: Text(cartItem.course.title),
                  subtitle: Text(
                      'Narx: \$${cartItem.course.price} - Miqdor: ${cartItem.quantity}'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle),
                    onPressed: () {
                      setState(() {
                        _courseService.removeFromCart(cartItem.course.id);
                      });
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _courseService.purchaseCartItems();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Kurslar sotib olindi!')),
                  );
                },
                child: Text('Sotib olish'),
              ),
            ),
    );
  }
}
