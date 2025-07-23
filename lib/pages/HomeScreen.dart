import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:munchly/logic/Notification_service.dart';
import 'package:munchly/pages/MenuScreen.dart';
import 'package:munchly/pages/MyOrdersPage.dart';
import 'package:munchly/pages/LoadingScreen.dart'; // Changed here

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initNotification();
  }

  Future<void> _initNotification() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted) return;
    }

    NotificationService().connect();
  }

  void _navigateToMenu(String time) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MenuScreen(time: time)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _AppDrawer(onSignOut: _handleSignOut),
      appBar: AppBar(
        title: const Text("Munchly"),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What would you like to eat?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _CategoryCard(
                title: 'Breakfast',
                subtitle: 'Start your day fresh',
                icon: Icons.free_breakfast,
                color: Colors.orange.shade100,
                onTap: () => _navigateToMenu('BREAKFAST'),
              ),
              const SizedBox(height: 20),
              _CategoryCard(
                title: 'Lunch',
                subtitle: 'Midday cravings?',
                icon: Icons.lunch_dining,
                color: Colors.orange.shade100,
                onTap: () => _navigateToMenu('LUNCH'),
              ),
              const SizedBox(height: 20),
              _CategoryCard(
                title: 'Dinner',
                subtitle: 'Wind down deliciously',
                icon: Icons.dinner_dining,
                color: Colors.orange.shade100,
                onTap: () => _navigateToMenu('DINNER'),
              ),
              const Spacer(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoadingScreen(),
      ), // 👈 Redirect to LoadingScreen
      (route) => false,
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.orange),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final VoidCallback onSignOut;

  const _AppDrawer({required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.orange),
            child: Text(
              'Munchly Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.orange),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.orange),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyOrdersPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.pop(context);
              onSignOut();
            },
          ),
        ],
      ),
    );
  }
}
