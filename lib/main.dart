import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/guess_screen.dart';

void main() {
  runApp(const BildirgecApp());
}

class BildirgecApp extends StatelessWidget {
  const BildirgecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      home: GuessScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
