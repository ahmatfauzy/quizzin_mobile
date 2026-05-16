import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  final ApiService _apiService = ApiService();
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.find<AuthService>();
  }

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan Password tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await _apiService.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final accessToken = response.data['access_token'] as String;
      final user = response.data['user'];

      await _authService.saveToken(accessToken);
      _apiService.setAuthToken(accessToken);

      Get.offAllNamed('/home');
    } on Exception catch (e) {
      String message = 'Terjadi kesalahan, coba lagi';
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final detail = e.response?.data?['detail'];
        if (statusCode == 401) {
          message = 'Email atau password salah';
        } else if (statusCode == 403) {
          message = 'Email belum diverifikasi. Silakan cek inbox email Anda.';
        } else if (detail != null && detail is String) {
          message = detail;
        }
      }
      Get.snackbar(
        'Gagal Login',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
