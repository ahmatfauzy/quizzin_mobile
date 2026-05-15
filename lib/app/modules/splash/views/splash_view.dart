import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/modules/splash/controllers/splash_controller.dart';


class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Image.asset(
              'assets/images/logos/logo1.png', 
              width: 220, 
              height: 220,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 24),
            const Text(
              "Quizzin",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              "Loading intellectual partner...",
              style: TextStyle(color: Colors.blueAccent, fontSize: 16),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(color: Color(0xFF0056FF)),
          ],
        ),
      ),
    );
  }
}