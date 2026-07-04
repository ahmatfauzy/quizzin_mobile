import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/services/auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio dio;

  ApiService._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://projekagabut.biz.id',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // --- UTAMAKAN BAGIAN INTERCEPTOR INI ---
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        try {
          // Cek apakah AuthService sudah terdaftar di memori GetX
          if (Get.isRegistered<AuthService>()) {
            final authService = Get.find<AuthService>();
            
            // Jika user sudah login dan tokennya ada di SharedPreferences, pasang otomatis ke header
            if (authService.isLoggedIn && authService.token != null) {
              options.headers['Authorization'] = 'Bearer ${authService.token}';
            }
          }
        } catch (e) {
          // Cetak log jika terjadi kegagalan pembacaan token di background
          print('Gagal menginjeksi token otomatis di Interceptor: $e');
        }
        
        // Lanjutkan request ke server
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          try {
            if (Get.isRegistered<AuthService>()) {
              final authService = Get.find<AuthService>();
              authService.clearAuth();
            }
          } catch (e) {
            print('Gagal membersihkan token kedaluwarsa: $e');
          }
          Future.microtask(() {
            if (Get.currentRoute != '/login') {
              Get.offAllNamed('/login');
            }
          });
        }
        handler.next(error);
      },
    ));
  }

  // Tetap pertahankan fungsi ini agar tidak memecah kode lama di LoginController / ProfileController
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }
}