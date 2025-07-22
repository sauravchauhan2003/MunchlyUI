import 'package:flutter/material.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text("Orders will be displayed here.")),
    );
  }
}
