import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final userName = 'Ahmat Putra'.obs;
  final streakDays = 5.obs;
  final level = 12.obs;
  final levelProgress = 0.75.obs;
  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final weeklyActivityData = <double>[0.4, 0.7, 1.0, 0.3, 0.6, 0.1, 0.0].obs;
  final selectedDayIndex = 2.obs; 

  final recentMaterials = <Map<String, dynamic>>[
    {
      'title': 'Computer Vision Chapter 4',
      'type': 'PDF Document',
      'theme': 'vision',
      'progress': 0.6,
      'time': '2h ago',
    },
    {
      'title': 'NLP Midterm Practice',
      'type': 'PDF Document',
      'theme': 'language',
      'progress': 0.25,
      'time': 'Yesterday',
    },
    {
      'title': 'Advanced Machine Learning',
      'type': 'PDF Document',
      'theme': 'ml',
      'progress': 1.0,
      'time': '3d ago',
    },
  ].obs; 

  void selectDay(int index) {
    selectedDayIndex.value = index;
  }

  void openProfile() {
    Get.toNamed('/profile');
  }

  void openMaterial() {
    Get.toNamed('/chapter-details');
  }

  void addNewMaterial() {
    Get.snackbar(
      'Upload PDF', 
      'Membuka file manager untuk memilih dokumen PDF...', 
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0056FF),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void openAllMaterials() {
    Get.toNamed('/all-materials');
  }
}