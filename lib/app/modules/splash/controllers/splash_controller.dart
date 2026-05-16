import 'package:get/get.dart';

import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authService = Get.find<AuthService>();
    final apiService = ApiService();

    Future.delayed(const Duration(seconds: 3), () {
      if (authService.isLoggedIn) {
        final token = authService.token;
        if (token != null) {
          apiService.setAuthToken(token);
        }
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    });
  }
}
