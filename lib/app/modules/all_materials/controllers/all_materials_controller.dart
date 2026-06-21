import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/services/api_service.dart';

class AllMaterialsController extends GetxController {
  final ApiService _apiService = ApiService();
  final searchController = TextEditingController();

  final isLoading = true.obs;

  final allMaterials = <Map<String, dynamic>>[].obs;
  
  final filteredMaterials = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllDocuments();

    searchController.addListener(() {
      filterMaterials(searchController.text);
    });
  }

  Future<void> fetchAllDocuments() async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.get('/documents/');
      final responseData = response.data as Map<String, dynamic>;
      final List rawDocuments = responseData['documents'] ?? [];

      final mappedData = rawDocuments.map((doc) {
        return {
          'id': doc['id'], // ID unik fisik database aman tersimpan di sini
          'title': doc['title'] ?? doc['original_filename'] ?? 'Untitled Document',
          'type': 'PDF Document',
          'theme': _determineTheme(doc['title'] ?? doc['original_filename'] ?? ''),
          'progress': doc['status'] == 'completed' ? 1.0 : 0.0,
          'time': _formatTimestamp(doc['created_at'] ?? ''),
          'status': doc['status'] ?? 'processing',
        };
      }).toList();

      allMaterials.assignAll(mappedData);
      
      filterMaterials(searchController.text);

    } catch (e) {
      debugPrint('Gagal memuat seluruh dokumen di AllMaterials: $e');
      Get.snackbar(
        'Gagal Memuat', 
        'Terjadi kesalahan saat mengambil daftar dokumen.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterMaterials(String query) {
    if (query.trim().isEmpty) {
      filteredMaterials.assignAll(allMaterials);
    } else {
      final lowercaseQuery = query.toLowerCase();
      final result = allMaterials.where((material) {
        final title = material['title'].toString().toLowerCase();
        return title.contains(lowercaseQuery);
      }).toList();
      
      filteredMaterials.assignAll(result);
    }
  }

  String _determineTheme(String title) {
    String lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('vision') || lowerTitle.contains('mata') || lowerTitle.contains('image')) return 'vision';
    if (lowerTitle.contains('nlp') || lowerTitle.contains('bahasa') || lowerTitle.contains('text') || lowerTitle.contains('speech')) return 'language';
    return 'ml';
  }

  String _formatTimestamp(String isoString) {
    if (isoString.isEmpty) return 'Baru saja';
    try {
      DateTime dt = DateTime.parse(isoString).toLocal();
      return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Baru saja';
    }
  }

  void goToDocumentDetails(int docId) {
    Get.toNamed('/chapter-details', arguments: docId);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}