import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController(text: 'Ahmat Putra');
  final emailController = TextEditingController(text: 'digidaw@kampusbanjir.ac.id');
  final levelController = TextEditingController(text: 'Graduate / D4');
  final majorController = TextEditingController(text: 'Teknik Informatika');
  final profilePicUrl = 'https://static.tvtropes.org/pmwiki/pub/images/the_two_faces_of_squidward.png'.obs;

  void updatePhoto() {
    profilePicUrl.value = 'https://static.tvtropes.org/pmwiki/pub/images/the_two_faces_of_squidward.png'; 
    Get.snackbar('Update Photo', 'Foto profil berhasil diubah!', snackPosition: SnackPosition.BOTTOM);
  }

  void saveChanges() {
    Get.snackbar('Success', 'Profil berhasil diperbarui!', snackPosition: SnackPosition.TOP);
  }

  void logout() async {
    final authService = Get.find<AuthService>();
    await authService.clearAuth();
    ApiService().clearAuthToken();
    Get.offAllNamed('/login'); 
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    levelController.dispose();
    majorController.dispose();
    super.onClose();
  }
}