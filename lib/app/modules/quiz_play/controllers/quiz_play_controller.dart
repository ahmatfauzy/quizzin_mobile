import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:quizzin/app/services/api_service.dart';

class QuizPlayController extends GetxController {
  final ApiService _apiService = ApiService();

  final isLoading = true.obs;
  final isSubmitting = false.obs;
  
  int? chapterId;
  final chapterTitle = 'Quiz Sesi'.obs;

  int? attemptId;
  final questions = <Map<String, dynamic>>[].obs;
  final totalQuestions = 0.obs;
  
  final currentIndex = 0.obs;
  final userAnswers = <int, String>{}.obs;

  Timer? _quizTimer;
  final remainingSeconds = 3600.obs; 
  final int totalDurationAllocated = 3600;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      chapterId = Get.arguments['chapter_id'];
      chapterTitle.value = Get.arguments['chapter_title'] ?? 'Quiz';
      String difficulty = Get.arguments['difficulty'] ?? 'medium';
      
      if (chapterId != null) {
        generateQuizFromServer(chapterId!, difficulty);
      } else {
        _handleErrorExit('ID Bab tidak valid.');
      }
    } else {
      _handleErrorExit('Parameter kuis terputus.');
    }
  }

  Future<void> generateQuizFromServer(int chId, String difficulty) async {
    try {
      isLoading.value = true;
      
      final payload = {
        "chapter_id": chId,
        "difficulty": difficulty,
      };

      final response = await _apiService.dio.post('/quizzes/generate', data: payload);
      final data = response.data as Map<String, dynamic>;

      attemptId = data['attempt_id'];
      
      final List rawQuestions = data['questions'] ?? [];
      questions.assignAll(rawQuestions.map((q) => q as Map<String, dynamic>).toList());
      totalQuestions.value = questions.length;

      if (totalQuestions.value > 0) {
        _startCountdownTimer();
      } else {
        _handleErrorExit('AI gagal merumuskan kombinasi soal.');
      }

    } catch (e) {
      debugPrint('Gagal generate kuis: $e');
      _handleErrorExit('Terjadi gangguan koneksi kuis AI.');
    } finally {
      isLoading.value = false;
    }
  }

  void _startCountdownTimer() {
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _quizTimer?.cancel();
        confirmSubmitQuiz();
      }
    });
  }

  void saveAnswer(int questionId, String answerValue) {
    userAnswers[questionId] = answerValue;
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < totalQuestions.value) {
      currentIndex.value = index;
    }
  }

  void confirmSubmitQuiz() {
    int unansweredCount = 0;

    for (var q in questions) {
      int qId = q['id'];
      if (userAnswers[qId] == null || userAnswers[qId]!.trim().isEmpty) {
        unansweredCount++;
      }
    }

    if (unansweredCount > 0) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 28),
              const SizedBox(width: 10),
              const Text('Jawaban Belum Lengkap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Text(
            'Waduh! Masih ada $unansweredCount soal yang belum kamu jawab. Harap periksa kembali daftar soal dan pastikan tidak ada yang kosong ya!',
            style: const TextStyle(color: Colors.black54, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0056FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Periksa Jawaban', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return; 
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Kumpulkan Kuis Sekarang?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Hebat! Semua soal sudah terisi dengan lengkap. Apakah kamu yakin ingin mengumpulkan hasil jawabanmu sekarang?',
          style: TextStyle(color: Colors.black54, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cek Lagi', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),

          ElevatedButton(
            onPressed: () {
              Get.back(); 
              
              Future.delayed(const Duration(milliseconds: 350), () {
                _executeSubmit(); 
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Ya, Kumpulkan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _executeSubmit() async {
    if (attemptId == null || isSubmitting.value) return;

    try {
      _quizTimer?.cancel();
      isSubmitting.value = true;

      int timeTaken = totalDurationAllocated - remainingSeconds.value;
      if (timeTaken <= 0) timeTaken = 1;

      List<Map<String, dynamic>> answersPayload = questions.map((q) {
        int qId = q['id'];
        return {
          "question_id": qId,
          "answer": userAnswers[qId] ?? "" 
        };
      }).toList();

      final payload = {
        "answers": answersPayload,
        "time_taken_seconds": timeTaken
      };

      final response = await _apiService.dio.post('/quizzes/$attemptId/submit', data: payload);
      
      final Map<String, dynamic> resultData = Map<String, dynamic>.from(response.data);
      
      if (resultData['results'] != null) {
        List dynamicResults = resultData['results'];
        
        for (int i = 0; i < dynamicResults.length; i++) {
          Map<String, dynamic> resItem = Map<String, dynamic>.from(dynamicResults[i]);
          
          final matchingQuestion = questions.firstWhere(
            (q) => q['id'] == resItem['question_id'],
            orElse: () => {},
          );
          
          if (matchingQuestion.isNotEmpty && matchingQuestion['options'] != null) {
            resItem['options'] = matchingQuestion['options'];
          }
          
          dynamicResults[i] = resItem;
        }
        resultData['results'] = dynamicResults;
      }

      Get.offNamed('/quiz-result', arguments: resultData);

    } catch (e) {
      debugPrint('Gagal kirim jawaban kuis: $e');
      Get.snackbar(
        'Gagal Mengirim',
        'Koneksi terputus. Mencoba mengirim kembali hasil ujian Anda.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  String get formattedTime {
    int minutes = remainingSeconds.value ~/ 60;
    int seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleErrorExit(String message) {
    Get.back();
    Get.snackbar('Gagal Ujian', message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade50);
  }

  @override
  void onClose() {
    _quizTimer?.cancel();
    super.onClose();
  }
}