import 'package:flutter/material.dart';
import 'package:munchly/logic/MenuItem.dart';
import 'package:munchly/logic/MenuItemCard.dart';
import 'package:munchly/logic/MenuService.dart';
import 'package:munchly/pages/MyOrdersPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:munchly/logic/Constants.dart';

class MenuScreen extends StatefulWidget {
  final String time;

  const MenuScreen({super.key, required this.time});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final Map<int, int> cart = {};
  late Future<List<MenuItem>> futureVegMenu;
  late Future<List<MenuItem>> futureNonVegMenu;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    futureVegMenu = MenuService.fetchMenu(widget.time, "VEG");
    futureNonVegMenu = MenuService.fetchMenu(widget.time, "NON_VEG");
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

  Widget buildMenuTab(Future<List<MenuItem>> futureMenu) {
    return FutureBuilder<List<MenuItem>>(
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
    );
  }

  Future<void> placeOrder(
    List<MenuItem> vegItems,
    List<MenuItem> nonVegItems,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    final addressData = prefs.getStringList('user_address');
    final latitude = prefs.getDouble('latitude');
    final longitude = prefs.getDouble('longitude');

    if (token == null ||
        addressData == null ||
        latitude == null ||
        longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing address or login info")),
      );
      return;
    }

    final address = {
      "line1": addressData[0],
      "line2": addressData[1],
      "city": addressData[2],
      "pincode": addressData[3],
      "state": addressData[4],
      "latitude": latitude,
      "longitude": longitude,
    };

    final allItems = [...vegItems, ...nonVegItems];
    final items =
        allItems
            .where((item) => cart.containsKey(item.id))
            .map(
              (item) => {
                "itemname": item.name,
                "price": item.price,
                "quantity": cart[item.id],
                "totalprice": item.price * cart[item.id]!,
                "foodType": item.foodType.toUpperCase(),
                "menuTime": item.timeSlot.toUpperCase(),
              },
            )
            .toList();

    final payload = {
      "address": address,
      "items": items,
      "payment method": "COD",
    };

    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/place-order'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      cart.clear();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyOrdersPage()),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: ${response.body}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.orange.shade50,
        appBar: AppBar(
          title: const Text("Menu"),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          bottom: const TabBar(tabs: [Tab(text: "VEG"), Tab(text: "NON-VEG")]),
        ),
        body: TabBarView(
          children: [
            buildMenuTab(futureVegMenu),
            buildMenuTab(futureNonVegMenu),
          ],
        ),
        floatingActionButton:
            cart.isNotEmpty
                ? FloatingActionButton.extended(
                  onPressed: () async {
                    final vegItems = await futureVegMenu;
                    final nonVegItems = await futureNonVegMenu;
                    await placeOrder(vegItems, nonVegItems);
                  },
                  backgroundColor: Colors.orange,
                  label: const Text("Place Order"),
                  icon: const Icon(Icons.shopping_cart_checkout),
                )
                : null,
      ),
    );
  }
}
