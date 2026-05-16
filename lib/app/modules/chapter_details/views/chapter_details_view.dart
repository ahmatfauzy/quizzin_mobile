import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chapter_details_controller.dart';

class ChapterDetailsView extends GetView<ChapterDetailsController> {
  const ChapterDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87), 
          onPressed: () => Get.back(), // Mengembalikan user ke halaman sebelumnya (Home)
        ),
        title: const Text('Intellect', style: TextStyle(color: Color(0xFF0056FF), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://static.tvtropes.org/pmwiki/pub/images/the_two_faces_of_squidward.png')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source Document Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.picture_as_pdf, size: 14, color: Color(0xFF0056FF)),
                  const SizedBox(width: 6),
                  Obx(() => Text(
                    'SOURCE: ${controller.documentTitle.value}', 
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            const Text('Extracted Chapters', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            const Text(
              "We've processed your document and identified key thematic sections. Select a chapter to engage with interactive concepts and track your mastery.",
              style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 24),
            
            // Loop data chapter dari controller
            ...controller.chapters.map((chapter) => _buildChapterCard(chapter)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterCard(Map<String, dynamic> data) {
    bool isMastered = data['status'] == 'mastered';
    bool isInProgress = data['status'] == 'in_progress';
    bool isLocked = data['status'] == 'locked';

    // Konfigurasi warna & tombol berdasarkan status
    Color buttonColor = isInProgress ? const Color(0xFF0056FF) : Colors.white;
    Color buttonTextColor = isInProgress ? Colors.white : const Color(0xFF0056FF);
    String buttonText = isMastered ? 'Review Concepts' : (isInProgress ? 'Continue Exploring' : 'Explore Concepts');
    IconData? buttonIcon = isMastered ? Icons.refresh : Icons.arrow_forward;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Garis Hijau di atas untuk chapter yang sudah Mastered
          if (isMastered)
            Container(height: 4, decoration: const BoxDecoration(color: Colors.green, borderRadius: BorderRadius.vertical(top: Radius.circular(12)))),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['chapter'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                          const SizedBox(height: 6),
                          Text(data['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                    ),
                    _buildStatusIcon(data['status']),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Indikator Mastery
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mastery', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    Text('${(data['mastery'] * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isMastered ? Colors.green : (isInProgress ? const Color(0xFF0056FF) : Colors.grey))),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: data['mastery'],
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(isMastered ? Colors.green : const Color(0xFF0056FF)),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 20),
                
                // Tombol Aksi
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isLocked ? null : () => controller.goToConceptMap(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonTextColor,
                      elevation: 0,
                      side: isMastered || isLocked ? const BorderSide(color: Color(0xFF0056FF)) : BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Icon(buttonIcon, size: 18),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    if (status == 'mastered') {
      return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20));
    } else if (status == 'in_progress') {
      return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFE8F1FF), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.trending_up, color: Color(0xFF0056FF), size: 20));
    } else {
      return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.lock_outline, color: Colors.grey, size: 20));
    }
  }
}