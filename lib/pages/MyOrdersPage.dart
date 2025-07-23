import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/constants.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt');

      if (jwt == null) {
        setState(() {
          error = 'JWT not found. Please login again.';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/my-orders'),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          orders = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load orders: $e';
        isLoading = false;
      });
    }
  }

  Widget buildOrderCard(dynamic order) {
    final List items = order['items'] ?? [];
    final address = order['address'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order ID: ${order['id']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Status: ${order['orderStatus']}"),
            const SizedBox(height: 8),
            Text("Payment: ${order['paymentMethod']} | Paid: ${order['paid']}"),
            const SizedBox(height: 8),
            Text(
              "Address: ${address?['line1'] ?? ''}, ${address?['city'] ?? ''}",
            ),
            const SizedBox(height: 8),
            const Text(
              "Items:",
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            ...items.map(
              (item) => Text(
                "- ${item['itemname']} x${item['quantity']} = ₹${item['totalprice']}",
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              )
              : orders.isEmpty
              ? const Center(child: Text("You haven't placed any orders yet."))
              : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) => buildOrderCard(orders[index]),
              ),
    );
  }
}
