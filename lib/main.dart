import 'package:flutter/material.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Selected Junks',
      theme: ThemeData(
        fontFamily: 'Poppins', // Pastikan font sudah didaftarkan di pubspec.yaml
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}