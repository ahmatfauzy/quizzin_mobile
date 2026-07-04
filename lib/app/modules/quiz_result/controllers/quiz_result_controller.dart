import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizResultController extends GetxController {
  final isLoading = true.obs;

  int attemptId = 0;
  String chapterTitle = '';
  String difficulty = '';
  int totalScore = 0;
  int xpGained = 0;
  int masteryUpdated = 0;
  int timeTakenSeconds = 0;
  String nextDifficultySuggestion = '';
  
  final results = <Map<String, dynamic>>[].obs;

  @override
  void onReady() {
    super.onReady();
    if (Get.arguments != null && Get.arguments is Map) {
      _parseResultData(Get.arguments);
    } else {
      _handleEmptyData();
    }
  }

  void _parseResultData(Map<String, dynamic> data) {
    try {
      attemptId = (data['attempt_id'] as num?)?.toInt() ?? 0;
      chapterTitle = data['chapter_title'] ?? 'Evaluasi Bab';
      difficulty = data['difficulty'] ?? 'medium';
      totalScore = (data['total_score'] as num?)?.toInt() ?? 0;
      xpGained = (data['xp_gained'] as num?)?.toInt() ?? 0;
      masteryUpdated = (data['mastery_updated'] as num?)?.toInt() ?? 0;
      timeTakenSeconds = (data['time_taken_seconds'] as num?)?.toInt() ?? 0;
      // ====================================================================

      nextDifficultySuggestion = data['next_difficulty_suggestion'] ?? 'medium';

      final List rawResults = data['results'] ?? [];
      results.assignAll(rawResults.map((r) {
        final Map<String, dynamic> item = Map<String, dynamic>.from(r);
        
        if (item['score'] != null) {
          item['score'] = (item['score'] as num).toInt();
        }
        return item;
      }).toList());
      
      isLoading.value = false;
    } catch (e) {
      debugPrint('Eror parsing data kuis: $e');
      _handleEmptyData();
    }
  }

  void _handleEmptyData() {
    isLoading.value = false;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute == '/quiz-result') {
        Get.offAllNamed('/main-navigation');
        Get.snackbar(
          'Data Kosong', 
          'Gagal memuat riwayat hasil kuis dari server.', 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade50,
        );
      }
    });
  }

  String get formattedTimeTaken {
    int minutes = timeTakenSeconds ~/ 60;
    int seconds = timeTakenSeconds % 60;
    if (minutes == 0) return '$seconds detik';
    return '$minutes m $seconds s';
  }

  void goToHome() {
    Get.offAllNamed('/main-navigation');
  }
}