import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/services/api_service.dart';

class ConceptMapController extends GetxController {
  final ApiService _apiService = ApiService();

  final isLoading = true.obs;

  int? chapterId;
  final chapterTitle = ''.obs;

  final coreConcept = <String, dynamic>{}.obs;
  final modules = <Map<String, dynamic>>[].obs;
  final entities = <String>[].obs;
  final relations = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      chapterId = Get.arguments['chapter_id'];
      chapterTitle.value = Get.arguments['chapter_title'] ?? 'Concept Map';

      if (chapterId != null) {
        fetchChapterGraphData(chapterId!);
      } else {
        _handleInvalidArgs();
      }
    } else {
      _handleInvalidArgs();
    }
  }

  Future<void> fetchChapterGraphData(int id) async {
    try {
      isLoading.value = true;
      
      final response = await _apiService.dio.get('/chapters/$id');
      final data = response.data as Map<String, dynamic>;

      // Ambil objek raksasa knowledge_graph dari FastAPI
      final graph = data['knowledge_graph'] as Map<String, dynamic>?;

      if (graph != null) {
        coreConcept.value = graph['core_concept'] ?? {};

        final List rawModules = graph['modules'] ?? [];
        modules.assignAll(rawModules.map((m) => m as Map<String, dynamic>).toList());

        final List rawEntities = graph['entities'] ?? [];
        entities.assignAll(rawEntities.map((e) => e.toString()).toList());

        final List rawRelations = graph['relations'] ?? [];
        relations.assignAll(rawRelations.map((r) => r as Map<String, dynamic>).toList());
      }

    } catch (e) {
      debugPrint('Gagal memuat peta konsep bab: $e');
      Get.snackbar(
        'Gagal Memuat Graph',
        'Terjadi kendala saat mengunduh peta pikiran dari AI.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void continueToQuiz() {
    if (chapterId == null) return;
    
    Get.toNamed('/select-difficulty', arguments: {
      'chapter_id': chapterId,
      'chapter_title': chapterTitle.value,
    });
  }

  void _handleInvalidArgs() {
    isLoading.value = false;
    Get.back();
    Get.snackbar(
      'Gagal Membuka Peta',
      'Parameter data bab kuis tidak ditemukan.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}