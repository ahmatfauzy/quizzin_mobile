import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void register() {
    // Validasi dinonaktifkan sementara untuk kemudahan testing UI 
    
    /* // Kode validasi asli
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Error', 'Semua kolom harus diisi!', backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Error', 'Password tidak cocok!', backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    */

    // Simulasi Loading & Sukses (Langsung tereksekusi tanpa mengecek isi form)
    isLoading.value = true;
    
    // Waktu tunggu saya percepat menjadi 1 detik agar testing lebih cepat
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
      
      Get.snackbar(
        'Simulasi UI', 'Bypass validasi aktif. Melanjutkan ke Setup Identity...',
        backgroundColor: const Color(0xFF0056FF),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      // --- NAVIGASI KE HALAMAN FACE REGISTRATION ---
      Get.offNamed('/face-registration'); 
    });
  }

  void goToLogin() {
    Get.back(); 
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}