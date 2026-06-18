import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF558EFA), 
              Color(0xFF2D6AE0),
              Color(0xFF1A4596), 
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              left: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08), 
                ),
              ),
            ),

            Positioned(
              bottom: -100,
              right: -80,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // --- 4. KONTEN UTAMA ---
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gunakan Hero widget jika nanti ingin ada animasi transisi logo
                  Image.asset(
                    'assets/images/logos/logowhite.png', 
                    width: 120, 
                    height: 120, 
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    "Quizzin",
                    style: TextStyle(
                      fontSize: 36, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      letterSpacing: 1.2, 
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  const Text(
                    "Your Intellectual Study Partner", 
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3, 
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}