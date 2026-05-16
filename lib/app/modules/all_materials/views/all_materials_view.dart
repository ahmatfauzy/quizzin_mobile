import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/all_materials_controller.dart';

class AllMaterialsView extends GetView<AllMaterialsController> {
  const AllMaterialsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text('All Materials', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- KOLOM PENCARIAN (SEARCH BAR) ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search documents...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // --- PERUBAHAN: MENGGUNAKAN GRID VIEW ---
          Expanded(
            child: Obx(() => GridView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              // Mengatur grid menjadi 2 kolom
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85, // Mengatur proporsi tinggi vs lebar kartu
              ),
              itemCount: controller.allMaterials.length,
              itemBuilder: (context, index) {
                final material = controller.allMaterials[index];
                
                // Konfigurasi Tema
                IconData iconData;
                Color bgColor;
                Color iconColor;

                switch (material['theme']) {
                  case 'vision':
                    iconData = Icons.remove_red_eye_outlined;
                    bgColor = const Color(0xFFF3E5F5);
                    iconColor = const Color(0xFF8E24AA);
                    break;
                  case 'language':
                    iconData = Icons.translate;
                    bgColor = const Color(0xFFE3F2FD);
                    iconColor = const Color(0xFF1E88E5);
                    break;
                  case 'ml':
                    iconData = Icons.memory;
                    bgColor = const Color(0xFFE8F5E9);
                    iconColor = const Color(0xFF43A047);
                    break;
                  default:
                    iconData = Icons.picture_as_pdf_rounded;
                    bgColor = const Color(0xFFFFEBEE); 
                    iconColor = const Color(0xFFD32F2F); 
                }

                return GestureDetector(
                  onTap: () => controller.openMaterial(),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(20), 
                      border: Border.all(color: Colors.grey.shade200), 
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))]
                    ),
                    // Desain kartu diubah menjadi stack vertikal
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ikon besar di tengah atas
                        Container(
                          padding: const EdgeInsets.all(14), 
                          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), 
                          child: Icon(iconData, color: iconColor, size: 28)
                        ),
                        const SizedBox(height: 16),
                        
                        // Judul Materi
                        Text(
                          material['title'].toString(), 
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87, height: 1.2), 
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        
                        // Teks Waktu
                        Text(
                          material['time'].toString(), 
                          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)
                        ),
                        
                        const Spacer(),
                        
                        // Progress Bar di bagian paling bawah kartu
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${(material['progress'] * 100).toInt()}%', 
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: iconColor)
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: material['progress'] as double, 
                              backgroundColor: Colors.grey.shade200, 
                              valueColor: AlwaysStoppedAnimation<Color>(iconColor), 
                              minHeight: 4, 
                              borderRadius: BorderRadius.circular(2)
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}