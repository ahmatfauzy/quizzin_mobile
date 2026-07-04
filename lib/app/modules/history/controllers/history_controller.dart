import 'package:get/get.dart';
import 'package:quizzin/app/services/api_service.dart';
import 'package:flutter/material.dart';

class HistoryController extends GetxController {
  final ApiService _apiService = ApiService();
  final isLoading = true.obs;
  final historyList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    try {
      final response = await _apiService.dio.get('/quizzes/history');
      final data = response.data;
      
      if (data is Map && data['attempts'] is List) {
        historyList.assignAll(data['attempts'].cast<Map<String, dynamic>>());
      } else if (data is List) {
        historyList.assignAll(data.cast<Map<String, dynamic>>());
      } else {
        historyList.clear();
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
      historyList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> goToDetail(int attemptId) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF0056FF))),
      barrierDismissible: false,
    );

    try {
      final response = await _apiService.dio.get('/quizzes/attempt/$attemptId');
      Get.back(); // Tutup loading
      
      final data = response.data;
      if (data != null) {
        Get.toNamed('/quiz-result', arguments: data);
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Gagal', 
        'Tidak dapat mengambil detail riwayat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
      );
    }
  }
}
