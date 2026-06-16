import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/services/api_service.dart';


class HomeController extends GetxController {
  final ApiService _apiService = ApiService();

  final userName = 'Memuat...'.obs;
  final profilePicUrl = 'https://wallpapers.com/images/featured/cool-profile-picture-87h46gcobjl5e4xu.jpg'.obs;
  final streakDays = 0.obs;
  
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

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await _apiService.dio.get('/profile');
      final userData = response.data as Map<String, dynamic>;

      userName.value = userData['full_name'] ?? 'Student';
      profilePicUrl.value = userData['avatar_url'] ?? 
          'https://wallpapers.com/images/featured/cool-profile-picture-87h46gcobjl5e4xu.jpg';
      streakDays.value = userData['streak_days'] ?? 0;
    } catch (e) {
      debugPrint('Gagal memuat data user di Home: $e');
    }
  }

  void selectDay(int index) {
    selectedDayIndex.value = index;
  }

  void openProfile() async {
    await Get.toNamed('/profile');
    
    fetchUserData(); 
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