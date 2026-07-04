import 'dart:async';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizzin/app/services/api_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();

  final isProfileLoading = true.obs;
  final isUploadingDocument = false.obs;
  final hasError = false.obs;

  final userName = ''.obs;
  final profilePicUrl = ''.obs;
  final streakDays = 0.obs;
  final xpPoints = 0.obs;

  final level = 1.obs;
  final levelProgress = 0.0.obs;
  final xpInCurrentLevel = 0.obs;
  final xpPerLevel = 500;

  Timer? _autoRefreshTimer;
  final recentMaterials = <Map<String, dynamic>>[].obs;

  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final weeklyActivityData = <double>[0.4, 0.7, 1.0, 0.3, 0.6, 0.1, 0.0].obs;
  final selectedDayIndex = 2.obs;

  final lastReadDocumentId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
    loadLastReadDocument();
    _startPeriodicRefresh();
  }

  Future<void> fetchInitialData() async {
    isProfileLoading.value = true;
    hasError.value = false;
    try {
      await Future.wait([
        fetchUserData(silent: false),
        fetchRealDocuments(),
        fetchWeeklyActivity(),
      ]);
    } catch (e) {
      debugPrint('Error fetchInitialData: $e');
      hasError.value = true;
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<void> loadLastReadDocument() async {
    final prefs = await SharedPreferences.getInstance();
    final int? savedId = prefs.getInt('last_doc_id');
    lastReadDocumentId.value = savedId;
  }

  Future<void> saveLastReadDocument(int docId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_doc_id', docId);
    lastReadDocumentId.value = docId;

    // Menyimpan id dokumen ke list 3 dokumen terakhir dibuka
    List<String> openedIds = prefs.getStringList('last_opened_docs') ?? [];
    String docIdStr = docId.toString();
    openedIds.remove(docIdStr);
    openedIds.insert(0, docIdStr);
    if (openedIds.length > 3) {
      openedIds = openedIds.sublist(0, 3);
    }
    await prefs.setStringList('last_opened_docs', openedIds);
  }

  void _startPeriodicRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchUserData(silent: true).catchError((e) {});
      fetchRealDocuments().catchError((e) {});
      fetchWeeklyActivity().catchError((e) {});
    });
  }

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

      level.value = (totalXp ~/ xpPerLevel) + 1;
      xpInCurrentLevel.value = totalXp % xpPerLevel;
      levelProgress.value = xpInCurrentLevel.value / xpPerLevel;
    } catch (e) {
      debugPrint('Gagal sinkronisasi data user di Home: $e');
      if (!silent) {
        userName.value = 'Student';
        rethrow;
      }
    } finally {
      if (!silent) isProfileLoading.value = false;
    }
  }

  Future<void> fetchRealDocuments() async {
    try {
      final response = await _apiService.dio.get('/documents/');
      final responseData = response.data as Map<String, dynamic>;
      final List rawDocuments = responseData['documents'] ?? [];

      final prefs = await SharedPreferences.getInstance();
      final List<String> openedIds = prefs.getStringList('last_opened_docs') ?? [];

      final mappedDocs = rawDocuments.map((doc) {
        return {
          'id': doc['id'],
          'title': doc['title'] ?? doc['original_filename'] ?? 'Untitled Document',
          'type': 'PDF Document',
          'theme': _determineTheme(
            doc['title'] ?? doc['original_filename'] ?? '',
          ),
          'progress': doc['status'] == 'completed' ? 1.0 : 0.0,
          'time': _formatTimestamp(doc['created_at'] ?? ''),
          'status': doc['status'] ?? 'processing',
        };
      }).toList();

      List<Map<String, dynamic>> sortedDocs = [];
      if (openedIds.isNotEmpty) {
        for (String idStr in openedIds) {
          int? id = int.tryParse(idStr);
          if (id != null) {
            Map<String, dynamic>? foundDoc;
            for (var doc in mappedDocs) {
              if (doc['id'] == id) {
                foundDoc = doc;
                break;
              }
            }
            if (foundDoc != null) {
              sortedDocs.add(foundDoc);
            }
          }
        }
        if (sortedDocs.length < 3) {
          final remainingDocs = mappedDocs.where((doc) => !openedIds.contains(doc['id'].toString())).toList();
          remainingDocs.sort((a, b) => b['id'].compareTo(a['id']));
          sortedDocs.addAll(remainingDocs);
        }
      } else {
        mappedDocs.sort((a, b) => b['id'].compareTo(a['id']));
        sortedDocs = mappedDocs;
      }

      recentMaterials.value = sortedDocs.take(3).toList();
    } catch (e) {
      debugPrint('Gagal memuat list dokumen di Home: $e');
      rethrow;
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
        duration: const Duration(seconds: 2),
      );

      String filePath = result.files.single.path!;
      String fileName = result.files.single.name;

      dio_pkg.FormData formData = dio_pkg.FormData.fromMap({
        "file": await dio_pkg.MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: dio_pkg.DioMediaType('application', 'pdf'),
        ),

        "title": fileName.replaceAll('.pdf', '').replaceAll('.PDF', ''),
      });

      await _apiService.dio.post('/documents/upload', data: formData);

      Get.snackbar(
        'Berhasil',
        'Dokumen berhasil diunggah! AI sedang mengekstrak kuis Anda.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF0056FF),
        colorText: Colors.white,
      );

      fetchRealDocuments();
    } catch (e) {
      debugPrint('Gagal mengunggah dokumen: $e');
    } finally {
      isUploadingDocument.value = false;
    }
  }

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

  void selectDay(int index) => selectedDayIndex.value = index;

  void openProfile() async {
    await Get.toNamed('/profile');
    fetchInitialData();
  }

  void goToDocumentDetails(int docId) async {
    await saveLastReadDocument(docId);

    Get.toNamed('/chapter-details', arguments: docId)?.then((_) {
      loadLastReadDocument();
      fetchRealDocuments();
    });
  }

  void openAllMaterials() {
    Get.toNamed('/all-materials')?.then((_) {
      loadLastReadDocument();
      fetchRealDocuments();
    });
  }

  Future<void> fetchWeeklyActivity() async {
    try {
      final response = await _apiService.dio.get('/quizzes/history');
      final data = response.data;
      List<dynamic> attempts = [];
      if (data is Map && data['attempts'] is List) {
        attempts = data['attempts'];
      } else if (data is List) {
        attempts = data;
      }

      final activityCounts = List<int>.filled(7, 0);
      final now = DateTime.now();
      final mondayOffset = now.weekday - 1;
      final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: mondayOffset));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      for (var attempt in attempts) {
        final completedAtStr = attempt['completed_at'];
        if (completedAtStr != null && completedAtStr.toString().isNotEmpty) {
          try {
            final completedAt = DateTime.parse(completedAtStr.toString()).toLocal();
            if (completedAt.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && 
                completedAt.isBefore(endOfWeek)) {
              int dayIndex = completedAt.weekday - 1;
              if (dayIndex >= 0 && dayIndex < 7) {
                activityCounts[dayIndex]++;
              }
            }
          } catch (e) {
            debugPrint('Gagal parse tanggal completed_at: $e');
          }
        }
      }

      const dailyTarget = 2;
      for (int i = 0; i < 7; i++) {
        weeklyActivityData[i] = (activityCounts[i] / dailyTarget).clamp(0.0, 1.0);
      }

      selectedDayIndex.value = now.weekday - 1;
    } catch (e) {
      debugPrint('Gagal memuat weekly activity: $e');
    }
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel();
    super.onClose();
  }
}
