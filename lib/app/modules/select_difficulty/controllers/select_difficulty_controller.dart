import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectDifficultyController extends GetxController {
  final selectedDifficulty = 'medium'.obs; 

  int? chapterId;
  final chapterTitle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      chapterId = Get.arguments['chapter_id'];
      chapterTitle.value = Get.arguments['chapter_title'] ?? 'Quiz';
    } else {
      _handleMissingArgs();
    }
  }

  void selectLevel(String level) {
    selectedDifficulty.value = level;
  }

  void startQuiz() {
    if (chapterId == null) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.gavel_rounded, color: Color(0xFF0056FF)),
            SizedBox(width: 10),
            Text('Apakah Anda Siap?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Kuis untuk bab "${chapterTitle.value}" akan dimulai dengan tingkat kesulitan ${selectedDifficulty.value.toUpperCase()}.\n\nWaktu pengerjaan adalah 60 menit. Pastikan koneksi internet Anda stabil!',
          style: const TextStyle(color: Colors.black54, height: 1.4, fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Belum Siap', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          
          ElevatedButton(
            onPressed: () {
              Get.back(); 
              
              Future.delayed(const Duration(milliseconds: 350), () {
                Get.toNamed('/quiz-play', arguments: {
                  'chapter_id': chapterId,
                  'chapter_title': chapterTitle.value,
                  'difficulty': selectedDifficulty.value,
                });
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0056FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: const Text('Ya, Mulai!', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleMissingArgs() {
    Get.back();
    Get.snackbar(
      'Gagal Mengakses',
      'Informasi identitas bab kuis tidak ditemukan.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade50,
    );
  }
}