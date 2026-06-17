import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/services/api_service.dart';


class HomeController extends GetxController {
  final ApiService _apiService = ApiService();

  final isProfileLoading = true.obs;

  final userName = ''.obs;
  final profilePicUrl = ''.obs;
  final streakDays = 0.obs;
  final xpPoints = 0.obs;
  
  final level = 1.obs;
  final levelProgress = 0.0.obs;
  final xpInCurrentLevel = 0.obs;
  final xpPerLevel = 500; 
  
  Timer? _autoRefreshTimer;

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
    _startPeriodicRefresh(); 
  }

  void _startPeriodicRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchUserData(silent: true);
    });
  }

  Future<void> fetchUserData({bool silent = false}) async {
    if (!silent) isProfileLoading.value = true; 
    
    try {
      final response = await _apiService.dio.get('/profile');
      final userData = response.data as Map<String, dynamic>;

      userName.value = userData['full_name'] ?? 'Student';
      profilePicUrl.value = userData['avatar_url'] ?? 
          'https://cdn.pixabay.com/photo/2023/02/18/11/00/icon-7797704_640.png';
      streakDays.value = userData['streak_days'] ?? 0;
      
      int totalXp = userData['xp_points'] ?? 0;
      xpPoints.value = totalXp; 

      level.value = (totalXp ~/ xpPerLevel) + 1;
      xpInCurrentLevel.value = totalXp % xpPerLevel; 
      levelProgress.value = xpInCurrentLevel.value / xpPerLevel; 

    } catch (e) {
      debugPrint('Gagal mengambil data gamifikasi di Home: $e');
      if (!silent) userName.value = 'Student';
    } finally {
      if (!silent) isProfileLoading.value = false;
    }
  }

  void selectDay(int index) {
    selectedDayIndex.value = index;
  }

  void openProfile() async {
    await Get.toNamed('/profile');
    fetchUserData(silent: true); 
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

  @override
  void onClose() {
    _autoRefreshTimer?.cancel(); 
    super.onClose();
  }
}