import 'package:get/get.dart';

import '../controllers/main_navigation_controller.dart';
import '../../home/bindings/home_binding.dart';
import '../../all_materials/bindings/all_materials_binding.dart';
import '../../scan/bindings/scan_binding.dart';
import '../../history/bindings/history_binding.dart';
import '../../profile/bindings/profile_binding.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(
      () => MainNavigationController(),
    );
    HomeBinding().dependencies();
    AllMaterialsBinding().dependencies();
    ScanBinding().dependencies();
    HistoryBinding().dependencies();
    ProfileBinding().dependencies();
  }
}
