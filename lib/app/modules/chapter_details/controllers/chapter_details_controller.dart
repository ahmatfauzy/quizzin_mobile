import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:quizzin/app/services/api_service.dart';

class ChapterDetailsController extends GetxController {
  final ApiService _apiService = ApiService();

  final isLoading = true.obs;
  final isDeleting = false.obs; 
  int? documentId;

  // Data dokumen reaktif
  final documentTitle = ''.obs;
  final totalPages = 0.obs;
  final totalChapters = 0.obs;
  final chapters = <Map<String, dynamic>>[].obs;
  final profilePicUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments is int) {
        documentId = Get.arguments;
      } else if (Get.arguments is Map && Get.arguments['id'] != null) {
        documentId = Get.arguments['id'];
      }
      
      if (documentId != null) {
        fetchInitialData(documentId!);
      } else {
        _handleMissingArgs();
      }
    } else {
      _handleMissingArgs();
    }
  }

  Future<void> fetchInitialData(int id) async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchDocumentDetails(id),
        fetchUserProfile(),
      ]);
    } catch (e) {
      debugPrint('Error saat memuat data awal di ChapterDetails: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDocumentDetails(int id) async {
    final response = await _apiService.dio.get('/documents/$id');
    final data = response.data as Map<String, dynamic>;

    documentTitle.value = data['title'] ?? data['original_filename'] ?? 'Untitled Document';
    totalPages.value = data['total_pages'] ?? 0;
    totalChapters.value = data['total_chapters'] ?? 0;

    final List rawChapters = data['chapters'] ?? [];
    final mappedChapters = rawChapters.map((ch) {
      double masteryDouble = (ch['mastery_percentage'] ?? 0) / 100.0;

      String uiStatus = 'not_started';
      if (ch['is_locked'] == true) {
        uiStatus = 'locked';
      } else if (ch['is_completed'] == true) {
        uiStatus = 'mastered';
      } else if (masteryDouble > 0) {
        uiStatus = 'in_progress';
      }

      return {
        'id': ch['id'],
        'chapter': 'CHAPTER ${ch['chapter_number']}',
        'title': ch['title'] ?? 'Untitled Chapter',
        'mastery': masteryDouble,
        'status': uiStatus,
        'is_locked': ch['is_locked'] ?? false,
        'page_range': 'Hal. ${ch['page_start']} - ${ch['page_end']}',
      };
    }).toList();

    chapters.assignAll(mappedChapters);
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await _apiService.dio.get('/profile');
      final userData = response.data as Map<String, dynamic>;
      profilePicUrl.value = userData['avatar_url'] ?? '';
    } catch (e) {
      debugPrint('Gagal mengambil foto profil user: $e');
    }
  }

  void confirmDeleteDocument() {
    if (documentId == null) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Hapus Materi?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus dokumen materi ini? Seluruh riwayat progres kuis dan mastery bab ini akan dihapus permanen dari server.',
          style: TextStyle(color: Colors.black54, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Tutup dialog konfirmasi
              _executeDelete(); // Jalankan fungsi hapus ke backend
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: const Text('Hapus Permanen', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _executeDelete() async {
    try {
      isDeleting.value = true;

      await _apiService.dio.delete('/documents/$documentId');

      Get.snackbar(
        'Berhasil Dihapus',
        'Dokumen materi sukses dibersihkan dari database.',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      Get.offAllNamed('/home');

    } catch (e) {
      debugPrint('Gagal menghapus dokumen materi: $e');
      String errorMsg = 'Gagal menghapus materi dari server.';
      if (e is dio_pkg.DioException) {
        final detail = e.response?.data?['detail'];
        if (detail != null && detail is String) errorMsg = detail;
      }
      Get.snackbar(
        'Gagal Menghapus',
        errorMsg,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  void goToConceptMap(Map<String, dynamic> chapter) {
    if (chapter['is_locked'] == true) {
      Get.snackbar(
        'Materi Terkunci',
        'Selesaikan bab sebelumnya terlebih dahulu untuk membuka bab ini.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade50,
        icon: const Icon(Icons.lock_outline, color: Colors.amber),
      );
      return;
    }

    Get.toNamed('/concept-map', arguments: {
      'document_id': documentId,
      'chapter_id': chapter['id'],
      'chapter_title': chapter['title'],
    });
  }

  void _handleMissingArgs() {
    isLoading.value = false;
    documentTitle.value = "No Document Selected";
    Get.snackbar('Warning', 'Dokumen tidak valid atau tidak ditemukan.', snackPosition: SnackPosition.BOTTOM);
  }
}