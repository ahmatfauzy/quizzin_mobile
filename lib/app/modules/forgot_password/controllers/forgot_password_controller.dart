import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();

  void sendResetLink() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar(
        'Email Required', 
        'Please enter your email address first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Jika berhasil
    Get.snackbar(
      'Link Sent!', 
      'Password reset instructions have been sent to $email.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0056FF),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );

    // Kembali ke halaman Login setelah 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}