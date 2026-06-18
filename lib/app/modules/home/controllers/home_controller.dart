import 'dart:async';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:file_picker/file_picker.dart'; // Wajib untuk memilih berkas kuis PDF
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/services/api_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();

  // State loading utama halaman beranda saat pertama kali dibuka
  final isProfileLoading = true.obs;
  // State loading indikator ketika proses upload PDF sedang berjalan
  final isUploadingDocument = false.obs;

  // --- DATA REAKTIF USER ---
  final userName = ''.obs;
  final profilePicUrl = ''.obs;
  final streakDays = 0.obs;
  final xpPoints = 0.obs;

  // --- STATE GAMIFIKASI DINAMIS BERBASIS XP ---
  final level = 1.obs;
  final levelProgress = 0.0.obs;
  final xpInCurrentLevel = 0.obs;
  final xpPerLevel = 500; // Formula: Naik level setiap kelipatan 500 XP

  Timer? _autoRefreshTimer;

  // --- RECENT MATERIALS (SINKRON DENGAN BACKEND /DOCUMENTS) ---
  final recentMaterials = <Map<String, dynamic>>[].obs;

  // --- MOCK DATA GRAFIK AKTIVITAS MINGGUAN ---
  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final weeklyActivityData = <double>[0.4, 0.7, 1.0, 0.3, 0.6, 0.1, 0.0].obs;
  final selectedDayIndex = 2.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData(); // Load data profil dan dokumen secara paralel
    _startPeriodicRefresh(); // Nyalakan background polling tiap 5 detik
  }

  // --- FUNGSI PARALEL LOAD DATA AWAL ---
  Future<void> fetchInitialData() async {
    isProfileLoading.value = true;
    try {
      await Future.wait([fetchUserData(silent: true), fetchRealDocuments()]);
    } catch (e) {
      debugPrint('Error fetchInitialData: $e');
    } finally {
      isProfileLoading.value = false;
    }
  }

  // --- BACKGROUND POLLING (SINKRONISASI TIAP 5 DETIK) ---
  void _startPeriodicRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchUserData(silent: true);
      fetchRealDocuments(); // Otomatis update status 'processing' -> 'completed' dari AI
    });
  }

  // --- AMBIL DATA PROFILE & OPTIMALISASI LEVEL ---
  Future<void> fetchUserData({bool silent = false}) async {
    if (!silent) isProfileLoading.value = true;
    try {
      final response = await _apiService.dio.get('/profile');
      final userData = response.data as Map<String, dynamic>;

      userName.value = userData['full_name'] ?? 'Student';
      profilePicUrl.value =
          userData['avatar_url'] ??
          'https://cdn.pixabay.com/photo/2023/02/18/11/00/icon-7797704_640.png';
      streakDays.value = userData['streak_days'] ?? 0;

      int totalXp = userData['xp_points'] ?? 0;
      xpPoints.value = totalXp;

      // Kalkulasi matematika otomatisasi Level Gamifikasi
      level.value = (totalXp ~/ xpPerLevel) + 1;
      xpInCurrentLevel.value = totalXp % xpPerLevel;
      levelProgress.value = xpInCurrentLevel.value / xpPerLevel;
    } catch (e) {
      debugPrint('Gagal sinkronisasi data user di Home: $e');
      if (!silent) userName.value = 'Student';
    } finally {
      if (!silent) isProfileLoading.value = false;
    }
  }

  // --- AMBIL DAFTAR DOKUMEN REAL (GET /documents) ---
  Future<void> fetchRealDocuments() async {
    try {
      final response = await _apiService.dio.get('/documents/');
      final responseData = response.data as Map<String, dynamic>;
      final List rawDocuments = responseData['documents'] ?? [];

      // Petakan struktur JSON API backend ke dalam struktur reaktif UI View
      recentMaterials.value = rawDocuments.map((doc) {
        return {
          'id': doc['id'],
          'title':
              doc['title'] ?? doc['original_filename'] ?? 'Untitled Document',
          'type': 'PDF Document',
          'theme': _determineTheme(
            doc['title'] ?? doc['original_filename'] ?? '',
          ),
          'progress': doc['status'] == 'completed' ? 1.0 : 0.0,
          'time': _formatTimestamp(doc['created_at'] ?? ''),
          'status':
              doc['status'] ??
              'processing', // pemantau status 'processing', 'completed', atau 'failed'
        };
      }).toList();
    } catch (e) {
      debugPrint('Gagal memuat list dokumen di Home: $e');
    }
  }

  Future<void> addNewMaterial() async {
    if (isUploadingDocument.value) return;

    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return;

      isUploadingDocument.value = true;
      Get.snackbar(
        'Mengunggah', 
        'Sedang mengirim file PDF Anda ke server...', 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.blue.shade50,
        duration: const Duration(seconds: 2)
      );

      String filePath = result.files.single.path!;
      String fileName = result.files.single.name;

      // ====================================================================
      // SOLUSI: Tambahkan key "title" sesuai dengan permintaan validasi API
      // ====================================================================
      dio_pkg.FormData formData = dio_pkg.FormData.fromMap({
        "file": await dio_pkg.MultipartFile.fromFile(
          filePath, 
          filename: fileName,
          contentType: dio_pkg.DioMediaType('application', 'pdf'),
        ),
        // Kita potong akhiran '.pdf' nya agar jadi Judul Dokumen yang bersih
        "title": fileName.replaceAll('.pdf', '').replaceAll('.PDF', ''), 
      });
      // ====================================================================

      await _apiService.dio.post(
        '/documents/upload',
        data: formData,
      );

      Get.snackbar(
        'Berhasil', 
        'Dokumen berhasil diunggah! AI sedang mengekstrak kuis Anda.',
        snackPosition: SnackPosition.TOP, 
        backgroundColor: const Color(0xFF0056FF), 
        colorText: Colors.white
      );
      
      fetchRealDocuments();

    } catch (e) {
      debugPrint('Gagal mengunggah dokumen: $e');
      if (e is dio_pkg.DioException) {
        debugPrint('===================================================');
        debugPrint('DETAIL EROR VALIDASI SERVER (422):');
        debugPrint('${e.response?.data}');
        debugPrint('===================================================');
        
        String serverMessage = e.response?.data?['detail']?.toString() ?? 'Berkas tidak diizinkan oleh server.';
        Get.snackbar(
          'Gagal Mengunggah', 
          serverMessage,
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red.shade100
        );
      } else {
        Get.snackbar(
          'Gagal Mengunggah', 
          'Terjadi kesalahan koneksi atau berkas tidak diizinkan oleh server.',
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red.shade100
        );
      }
    } finally {
      isUploadingDocument.value = false;
    }
  }

  // Helper Cerdas: Memilih tema icon visual otomatis berdasarkan keyword nama file dokumen
  String _determineTheme(String title) {
    String lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('vision') ||
        lowerTitle.contains('mata') ||
        lowerTitle.contains('image'))
      return 'vision';
    if (lowerTitle.contains('nlp') ||
        lowerTitle.contains('bahasa') ||
        lowerTitle.contains('text') ||
        lowerTitle.contains('speech'))
      return 'language';
    return 'ml'; // Default tema Kecerdasan Buatan / Machine Learning
  }

  // Helper Format Jam: Merapikan format waktu buatan ISO Backend agar nyaman dibaca user
  String _formatTimestamp(String isoString) {
    if (isoString.isEmpty) return 'Baru saja';
    try {
      DateTime dt = DateTime.parse(isoString).toLocal();
      return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Baru saja';
    }
  }

  void selectDay(int index) => selectedDayIndex.value = index;

  void openProfile() async {
    await Get.toNamed('/profile');
    fetchInitialData(); // Ambil data ter-update saat user kembali ke beranda dari layar profil
  }

  void openMaterial() => Get.toNamed('/chapter-details');
  void openAllMaterials() => Get.toNamed('/all-materials');

  @override
  void onClose() {
    _autoRefreshTimer
        ?.cancel(); // Mencegah kebocoran memori (memory leak) saat ganti controller
    super.onClose();
  }
}
