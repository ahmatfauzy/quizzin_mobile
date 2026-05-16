import 'package:get/get.dart';

import '../controllers/all_materials_controller.dart';

class AllMaterialsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllMaterialsController>(
      () => AllMaterialsController(),
    );
  }
}
