// file main.dart
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
//Đây là điểm khởi chạy của toàn bộ ứng dụng Flutter
Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản Lý Điện Nước Khu Phố',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}