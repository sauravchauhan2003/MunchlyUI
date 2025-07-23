import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  IOWebSocketChannel? _channel;
  int _retryCount = 0;
  final int _maxRetries = 3;
  bool _isConnected = false;

  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get stream => _controller.stream;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permissions
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        debugPrint("Notification permission not granted");
      }
    }
  }

  Future<void> connect() async {
    if (_isConnected) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      debugPrint("JWT not found, cannot connect to WebSocket.");
      return;
    }

    final uri = Uri.parse('wss://munchlybackend.onrender.com/notifications');

    try {
      final socket = await WebSocket.connect(
        uri.toString(),
        headers: {'Authorization': 'Bearer $token'},
      );

      _channel = IOWebSocketChannel(socket);
      _isConnected = true;
      _retryCount = 0;
      debugPrint("WebSocket connected.");

      _channel!.stream.listen(
        (message) {
          debugPrint("WebSocket message received: $message");
          try {
            final decoded = jsonDecode(message);
            if (decoded is Map<String, dynamic>) {
              _controller.add(decoded);
              _showLocalNotification(
                decoded['title'] ?? 'Munchly',
                decoded['body'] ?? 'You have a new message',
              );
            }
          } catch (e) {
            debugPrint("Failed to decode WebSocket message: $e");
          }
        },
        onError: (error) {
          debugPrint("WebSocket error: $error");
          _handleReconnect();
        },
        onDone: () {
          debugPrint("WebSocket connection closed.");
          _handleReconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint("WebSocket connection failed: $e");
      _handleReconnect();
    }
  }

  void _handleReconnect() {
    _isConnected = false;
    if (_retryCount < _maxRetries) {
      _retryCount++;
      Future.delayed(Duration(seconds: 2), () {
        debugPrint("Reconnecting... Attempt $_retryCount");
        connect();
      });
    } else {
      debugPrint("Max retry attempts reached. Giving up.");
    }
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default_channel',
          'Notifications',
          channelDescription: 'Order and system alerts',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: 'notification_payload',
    );
  }

  void disconnect() {
    _isConnected = false;
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  void dispose() {
    _controller.close();
    disconnect();
  }
}
