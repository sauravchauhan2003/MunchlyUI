import 'package:flutter/material.dart';
import 'package:munchly/logic/MenuItem.dart';
import 'package:munchly/logic/MenuItemCard.dart';
import 'package:munchly/logic/MenuService.dart';
import 'package:munchly/pages/MyOrdersPage.dart';

class MenuScreen extends StatefulWidget {
  final String time;
  final String type;

  const MenuScreen({super.key, required this.time, this.type = "VEG"});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<MenuItem>> futureMenu;
  final Map<int, int> cart = {};

  @override
  void initState() {
    super.initState();
    futureMenu = MenuService.fetchMenu(widget.time, widget.type);
  }

  void addToCart(int id) {
    setState(() {
      cart[id] = 1;
    });
  }

  void updateQuantity(int id, int change) {
    setState(() {
      final newQty = (cart[id] ?? 0) + change;
      if (newQty <= 0) {
        cart.remove(id);
      } else {
        cart[id] = newQty;
      }
    });
  }

  // ⚠️ Placeholder for placing order
  Future<void> placeOrder() async {
    // Example payload structure:
    /*
    {
      "address": { ... },
      "items": [
        { "itemId": 1, "quantity": 2 },
        ...
      ],
      "payment method": "COD"
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text("Menu"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<MenuItem>>(
        future: futureMenu,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final menuItems = snapshot.data!;
          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return MenuItemCard(
                item: item,
                trailing:
                    cart.containsKey(item.id)
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.orange,
                              ),
                              onPressed: () => updateQuantity(item.id, -1),
                            ),
                            Text(
                              cart[item.id].toString(),
                              style: const TextStyle(color: Colors.black),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.orange),
                              onPressed: () => updateQuantity(item.id, 1),
                            ),
                          ],
                        )
                        : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => addToCart(item.id),
                          child: const Text('Add'),
                        ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          cart.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyOrdersPage()),
                  );
                },
                backgroundColor: Colors.orange,
                label: const Text("Place Order"),
                icon: const Icon(Icons.shopping_cart_checkout),
              )
              : null,
    );
  }
}
