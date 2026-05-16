import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: const Text('Quizzin', style: TextStyle(color: Color(0xFF0056FF), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => controller.openProfile(),
              child: const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://static.tvtropes.org/pmwiki/pub/images/the_two_faces_of_squidward.png')),
            ),
          ),
        ],
      ),
      
      // perkondisian apabila tidak ada riwayat materi, maka tombol floating action button tidak muncul
      floatingActionButton: Obx(() => controller.recentMaterials.isEmpty 
        ? const SizedBox.shrink() // Widget kosong jika tidak ada materi
        : FloatingActionButton.extended(
            onPressed: () => controller.addNewMaterial(),
            backgroundColor: const Color(0xFF0056FF),
            elevation: 4,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('New Quiz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: _buildWelcomeCard()),
            const SizedBox(height: 24),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: _buildWeeklyActivity()),
            const SizedBox(height: 32),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Materials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Obx(() => controller.recentMaterials.isEmpty 
                    ? const SizedBox() 
                    : TextButton(onPressed: () {}, child: const Text('See All', style: TextStyle(color: Color(0xFF0056FF), fontWeight: FontWeight.w600)))
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            Obx(() {
              if (controller.recentMaterials.isEmpty) {
                return _buildEmptyState();
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildRecentMaterialsVertical(),
                );
              }
            }),
            
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E60E8), Color(0xFF0A349E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF0A349E).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text('Welcome back,\n${controller.userName.value}! 👋', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2))),
          const SizedBox(height: 12),
          Obx(() => Text("You're on a ${controller.streakDays.value}-day learning streak. Keep up the momentum in your advanced module.", style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4))),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text('Level ${controller.level.value} Scholar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                    Obx(() => Text('${(controller.levelProgress.value * 100).toInt()}% to Level ${controller.level.value + 1}', style: const TextStyle(color: Colors.white70, fontSize: 10))),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Obx(() => LinearProgressIndicator(value: controller.levelProgress.value, backgroundColor: Colors.white.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA5E08B)), minHeight: 8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton.icon(
              onPressed: () => controller.openMaterial(),
              icon: const Icon(Icons.play_circle_outline, color: Color(0xFF0A349E)),
              label: const Text('Resume Lesson', style: TextStyle(color: Color(0xFF0A349E), fontWeight: FontWeight.bold, fontSize: 15)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWeeklyActivity() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Weekly Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)), 
              Icon(Icons.show_chart, color: Colors.grey)
            ],
          ),
          const SizedBox(height: 32),
          
          // Area Grafik Bar (Bar Chart)
          SizedBox(
            height: 140, // Tinggi keseluruhan area grafik
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(controller.days.length, (index) {
                
                bool isSelected = controller.selectedDayIndex.value == index;
                // Tinggi maksimal bar adalah 80 pixel
                double barHeight = controller.weeklyActivityData[index] * 80; 
                // Jika nilai 0, tetap berikan sedikit tinggi (misal 6) agar bar tetap terlihat
                if (barHeight < 6) barHeight = 6; 

                return GestureDetector(
                  onTap: () => controller.selectDay(index),
                  behavior: HitTestBehavior.opaque, // Memastikan seluruh kolom bisa diklik
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Tooltip Angka Persentase (Muncul jika hari diklik)
                      AnimatedOpacity(
                        opacity: isSelected ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          '${(controller.weeklyActivityData[index] * 100).toInt()}%',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF0056FF), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // Grafik Batang (Bar)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic, // Animasi memantul halus
                        width: 32, // Lebar batang
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0056FF) : const Color(0xFFE8F1FF), // Biru tua vs Biru muda
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Label Hari di Bawah
                      Text(
                        controller.days[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF0056FF) : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMaterialsVertical() {
    return Column(
      children: controller.recentMaterials.map((material) {
        
        IconData iconData;
        Color bgColor;
        Color iconColor;

        // Mengubah warna dan ikon berdasarkan tema materi
        switch (material['theme']) {
          case 'vision':
            iconData = Icons.remove_red_eye_outlined; // Ikon mata untuk Computer Vision
            bgColor = const Color(0xFFF3E5F5); // Ungu pudar
            iconColor = const Color(0xFF8E24AA); // Ungu pekat
            break;
          case 'language':
            iconData = Icons.translate; // Ikon bahasa untuk NLP
            bgColor = const Color(0xFFE3F2FD); // Biru pudar
            iconColor = const Color(0xFF1E88E5); // Biru pekat
            break;
          case 'ml':
            iconData = Icons.memory; // Ikon chip AI untuk Machine Learning
            bgColor = const Color(0xFFE8F5E9); // Hijau pudar
            iconColor = const Color(0xFF43A047); // Hijau pekat
            break;
          default:
            iconData = Icons.picture_as_pdf_rounded;
            bgColor = const Color(0xFFFFEBEE); 
            iconColor = const Color(0xFFD32F2F); 
        }

        return GestureDetector(
          onTap: () => controller.openMaterial(),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(20), 
              border: Border.all(color: Colors.grey.shade200), 
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))]
            ),
            child: Row(
              children: [
                // Ikon dengan tema
                Container(
                  padding: const EdgeInsets.all(12), 
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)), 
                  child: Icon(iconData, color: iconColor, size: 24)
                ),
                const SizedBox(width: 16),
                
                // Konten Teks & Progress Bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(material['title'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(material['type'].toString(), style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          Text(material['time'].toString(), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: material['progress'] as double, 
                        backgroundColor: Colors.grey.shade200, 
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor), 
                        minHeight: 5, 
                        borderRadius: BorderRadius.circular(3)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF), 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFB9D5FF)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.upload_file, color: Color(0xFF0056FF), size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No Recent Materials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A365D))),
          const SizedBox(height: 8),
          const Text('Upload your first PDF document to start generating smart quizzes.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: () => controller.addNewMaterial(),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Upload PDF', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0056FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }
}