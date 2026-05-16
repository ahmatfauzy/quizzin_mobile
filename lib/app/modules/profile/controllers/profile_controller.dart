import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Data dummy yang sudah disesuaikan
  final nameController = TextEditingController(text: 'Ahmat Putra');
  final emailController = TextEditingController(text: 'digidaw@kampusbanjir.ac.id');
  final levelController = TextEditingController(text: 'Graduate / D4');
  final majorController = TextEditingController(text: 'Teknik Informatika');
  final profilePicUrl = 'https://static.tvtropes.org/pmwiki/pub/images/the_two_faces_of_squidward.png'.obs;

  void updatePhoto() {
    // Simulasi ganti foto profil saat tombol diklik 
    profilePicUrl.value = 'https://static.tvtropes.org/pmwiki/pub/images/the_two_faces_of_squidward.png'; 
    Get.snackbar('Update Photo', 'Foto profil berhasil diubah!', snackPosition: SnackPosition.BOTTOM);
  }

  void saveChanges() {
    Get.snackbar('Success', 'Profil berhasil diperbarui!', snackPosition: SnackPosition.TOP);
  }

  void logout() {
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