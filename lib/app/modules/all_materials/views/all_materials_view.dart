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
          
          // --- KONTEN GRID UTAMA (DENGAN COBA CEK STATE REAKTIF) ---
          Expanded(
            child: Obx(() {
              // 1. Tampilan Loading Spinner saat fetch awal dari API
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0056FF)),
                );
              }

              // 2. Tampilan Empty State jika hasil filter pencarian kosong
              if (controller.filteredMaterials.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                        child: Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No materials found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Coba cari dengan kata kunci lain.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              // 3. Render Grid View Berdasarkan Data Hasil Saringan (filteredMaterials)
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.82, // Sedikit disesuaikan agar teks status muat dengan aman
                ),
                itemCount: controller.filteredMaterials.length,
                itemBuilder: (context, index) {
                  final material = controller.filteredMaterials[index];
                  
                  // Deteksi status dari backend kuis
                  bool isProcessing = material['status'] == 'processing';
                  bool isFailed = material['status'] == 'failed';

                  // Konfigurasi Tema Warna & Icon Visual Kartu
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
                    // Mengunci aksi tap jika AI kuis sedang membedah materi di background
                    onTap: isProcessing
                        ? () => Get.snackbar('Mohon Tunggu', 'Dokumen masih diproses oleh sistem AI...', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.amber.shade50)
                        : () => controller.openMaterial(),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(20), 
                        border: Border.all(color: Colors.grey.shade200), 
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ikon besar di tengah atas kartu grid
                          Container(
                            padding: const EdgeInsets.all(14), 
                            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), 
                            child: Icon(iconData, color: isProcessing ? Colors.orange : iconColor, size: 28)
                          ),
                          const SizedBox(height: 12),
                          
                          // Judul Materi Utama
                          Text(
                            material['title'].toString(), 
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87, height: 1.2), 
                            maxLines: 2, 
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          
                          // Teks Informasi Waktu / Status AI
                          Text(
                            isProcessing ? 'Processing...' : (isFailed ? 'Failed' : material['time'].toString()), 
                            style: TextStyle(
                              fontSize: 10, 
                              color: isProcessing ? Colors.orange.shade700 : (isFailed ? Colors.red : Colors.grey), 
                              fontWeight: isProcessing ? FontWeight.bold : FontWeight.w500
                            )
                          ),
                          
                          const Spacer(),
                          
                          // Progress Bar Komponen di bagian paling bawah grid item
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    isProcessing ? 'AI...' : (isFailed ? '0%' : '${(material['progress'] * 100).toInt()}%'), 
                                    style: TextStyle(
                                      fontSize: 10, 
                                      fontWeight: FontWeight.bold, 
                                      color: isFailed ? Colors.red : (isProcessing ? Colors.orange : iconColor)
                                    )
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                // Jika processing, buat nilainya null agar memicu animasi geser konstan
                                value: isProcessing ? null : (isFailed ? 0.0 : material['progress'] as double), 
                                backgroundColor: Colors.grey.shade200, 
                                valueColor: AlwaysStoppedAnimation<Color>(isFailed ? Colors.red : (isProcessing ? Colors.orange : iconColor)), 
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
              );
            })
          ),
        ],
      ),
    );
  }
}