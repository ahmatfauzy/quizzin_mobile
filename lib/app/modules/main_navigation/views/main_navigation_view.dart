import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_navigation_controller.dart';
import '../../home/views/home_view.dart';
import '../../all_materials/views/all_materials_view.dart';
import '../../scan/views/scan_view.dart';
import '../../history/views/history_view.dart';
import '../../profile/views/profile_view.dart';

class MainNavigationView extends GetView<MainNavigationController> {
  const MainNavigationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeView(),
              AllMaterialsView(),
              ScanView(),
              HistoryView(),
              ProfileView(),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: SizedBox(
              height: 75, // Total tinggi area (termasuk tombol yang menonjol)
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Background putih bottom bar
                  Container(
                    height: 60, // Tinggi aktual dari bottom bar
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home')),
                        Expanded(child: _buildNavItem(1, Icons.menu_book_outlined, Icons.menu_book, 'Materi')),
                        const SizedBox(width: 72), // Ruang untuk tombol scan
                        Expanded(child: _buildNavItem(3, Icons.history_outlined, Icons.history, 'Riwayat')),
                        Expanded(child: _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile')),
                      ],
                    ),
                  ),
                  // Tombol Scan bulat
                  Positioned(
                    top: 0, // Posisi dari atas area 75px
                    child: GestureDetector(
                      onTap: () => controller.changePage(2),
                      child: Container(
                        height: 66,
                        width: 66,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2FA2F9), // Biru khas referensi
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2FA2F9).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.qr_code_scanner, color: Colors.white, size: 26),
                            SizedBox(height: 2),
                            Text(
                              'Scan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = controller.currentIndex.value == index;
    return InkWell(
      onTap: () => controller.changePage(index),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? const Color(0xFF0056FF) : Colors.black87,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF0056FF) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
