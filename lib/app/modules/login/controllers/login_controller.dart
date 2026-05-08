// KODE LAMA
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class LoginController extends GetxController {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
  
//   // State reaktif untuk efek loading
//   final isLoading = false.obs;

//   void login() async {
//     if (emailController.text.isEmpty || passwordController.text.isEmpty) {
//       Get.snackbar('Error', 'Email dan Password tidak boleh kosong', 
//           snackPosition: SnackPosition.BOTTOM);
//       return;
//     }

//     isLoading.value = true;
    
//     // Simulasi proses pemanggilan API / Firebase
//     await Future.delayed(const Duration(seconds: 2));
    
//     isLoading.value = false;
    
//     // Lanjut ke halaman utama setelah sukses
//     // Get.offAllNamed('/home');
//     Get.snackbar('Success', 'Login Berhasil!', snackPosition: SnackPosition.TOP);
//   }

//   @override
//   void onClose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  // State reaktif untuk efek loading 
  final isLoading = false.obs;

  void login() {
    Get.offAllNamed('/home'); 
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}