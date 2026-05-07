import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  // State untuk form register manual
  final isLoading = false.obs;
  
  // State khusus untuk tombol Google
  final isGoogleLoading = false.obs;

  void register() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Semua field harus diisi', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    
    // Simulasi proses register ke server/Firebase
    await Future.delayed(const Duration(seconds: 2));
    
    isLoading.value = false;
    
    Get.snackbar('Success', 'Akun berhasil dibuat!', snackPosition: SnackPosition.TOP);
    Get.back(); // Kembali ke halaman login
  }

  // Fungsi baru untuk Register dengan Google
  void registerWithGoogle() async {
    isGoogleLoading.value = true;
    
    // Simulasi proses integrasi Google Sign-In
    await Future.delayed(const Duration(seconds: 2));
    
    isGoogleLoading.value = false;
    
    Get.snackbar('Success', 'Berhasil mendaftar dengan akun Google!', snackPosition: SnackPosition.TOP);
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}