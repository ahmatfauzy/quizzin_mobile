import 'dart:async';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizzin/app/services/api_service.dart';
import 'package:quizzin/app/services/auth_service.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final levelController = TextEditingController();
  final majorController = TextEditingController();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isFetchingProfile = true.obs;
  final hasError = false.obs;
  final isLoading = false.obs;

  final profilePicUrl = ''.obs;
  final userData = <String, dynamic>{}.obs;

  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.find<AuthService>();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isFetchingProfile.value = true;
    hasError.value = false;

    try {
      final response = await _apiService.dio
          .get('/profile')
          .timeout(const Duration(seconds: 5));
      userData.value = response.data as Map<String, dynamic>;

      nameController.text = userData['full_name'] ?? '';
      emailController.text = userData['email'] ?? '';
      levelController.text = userData['academic_level'] ?? '';
      majorController.text = userData['major'] ?? '';

      profilePicUrl.value =
          userData['avatar_url'] ??
          'https://cdn.pixabay.com/photo/2023/02/18/11/00/icon-7797704_640.png';
    } catch (e) {
      hasError.value = true;
      if (e is TimeoutException) {
        Get.snackbar(
          'Waktu Habis',
          'Server terlalu lama merespons. Silakan coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
        );
      } else if (e is dio_pkg.DioException) {
        _showErrorSnackbar('Gagal Memuat Profil', e);
      }
    } finally {
      isFetchingProfile.value = false;
    }
  }

  Future<void> saveChanges() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Nama lengkap tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(
      const Duration(milliseconds: 100),
    ); 

    isLoading.value = true;
    try {
      await _apiService.dio.put(
        '/profile',
        data: {
          "full_name": nameController.text.trim(),
          "academic_level": levelController.text.trim(),
          "major": majorController.text.trim(),
        },
      );

      Get.snackbar(
        'Berhasil',
        'Profil Anda berhasil diperbarui!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF0056FF),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(milliseconds: 1200));

      if (Get.isSnackbarOpen) {
        
        Get.offAllNamed(
          '/home',
        ); 
      } else {
        Get.back();
      }
    } on dio_pkg.DioException catch (e) {
      _showErrorSnackbar('Gagal Memperbarui Profil', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword() async {
    final currentPw = currentPasswordController.text;
    final newPw = newPasswordController.text;
    final confirmPw = confirmPasswordController.text;

    if (currentPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Semua kolom password wajib diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
      );
      return;
    }

    if (newPw != confirmPw) {
      Get.snackbar(
        'Validasi Gagal',
        'Password baru dan konfirmasi tidak cocok',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
      );
      return;
    }

    isLoading.value = true;
    try {
      await _apiService.dio.put(
        '/profile/change-password',
        data: {"current_password": currentPw, "new_password": newPw},
      );

      clearPasswordFields();
      if (Get.isDialogOpen ?? false) Get.back();

      Get.snackbar(
        'Berhasil',
        'Password Anda berhasil diperbarui!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF0056FF),
        colorText: Colors.white,
      );
    } on dio_pkg.DioException catch (e) {
      _showErrorSnackbar('Gagal Mengubah Password', e);
    } finally {
      isLoading.value = false;
    }
  }

  void clearPasswordFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  Future<void> updatePhoto(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        imageQuality: 80,
      );
      if (pickedFile == null) return;

      isLoading.value = true;
      String fileName = pickedFile.path.split('/').last;
      dio_pkg.FormData formData = dio_pkg.FormData.fromMap({
        "file": await dio_pkg.MultipartFile.fromFile(
          pickedFile.path,
          filename: fileName,
        ),
      });

      await _apiService.dio.put('/profile/avatar', data: formData);
      Get.snackbar(
        'Foto Diperbarui',
        'Foto profil baru berhasil diunggah!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0056FF),
        colorText: Colors.white,
      );

      fetchProfile();
    } on dio_pkg.DioException catch (e) {
      _showErrorSnackbar('Gagal Mengunggah Foto', e);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _authService.clearAuth();
    _apiService.clearAuthToken();
    Get.offAllNamed('/login');
  }

  void _showErrorSnackbar(String title, dio_pkg.DioException error) {
    String message =
        error.response?.data?['detail'] ??
        'Terjadi kesalahan jaringan, silakan coba lagi';
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    levelController.dispose();
    majorController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
