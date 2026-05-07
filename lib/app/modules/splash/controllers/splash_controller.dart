import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    // Simulasi inisialisasi aplikasi selama 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      // Ganti '/login' dengan Routes.LOGIN jika file app_routes.dart sudah di-import
      Get.offAllNamed('/login'); 
    });
  }
}