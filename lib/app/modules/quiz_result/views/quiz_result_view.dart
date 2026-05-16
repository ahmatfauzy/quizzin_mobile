import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_result_controller.dart';

class QuizResultView extends GetView<QuizResultController> {
  const QuizResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        automaticallyImplyLeading: false, // Sembunyikan tombol back bawaan
        title: Row(
          children: const [
            CircleAvatar(radius: 14, backgroundImage: NetworkImage('https://static.tvtropes.org/pmwiki/pub/images/the_two_faces_of_squidward.png')),
            SizedBox(width: 12),
            Text('Learning Analytics', style: TextStyle(color: Color(0xFF1A365D), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share, color: Colors.grey), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreCard(),
            const SizedBox(height: 20),
            
            _buildReadinessAssessment(),
            const SizedBox(height: 24),
            
            const Text('Recommended Focus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 12),
            _buildRecommendedFocusList(),
            const SizedBox(height: 24),
            
            const Text('Incorrect Answers &\nRecommendations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 12),
            _buildIncorrectAnswersList(),
            const SizedBox(height: 32),

            // Tombol Kembali ke Dashboard
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => controller.backToDashboard(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0056FF),
                  side: const BorderSide(color: Color(0xFF0056FF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET KOMPONEN ---

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1A73E8), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SizedBox(
            height: 100, width: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: controller.readinessLevel.value, strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Center(child: Obx(() => Text('${controller.score.value}/${controller.totalScore.value}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => Text('Great Job, ${controller.userName.value}!', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          const Text("You've mastered 3 new concepts today. Keep up the momentum to hit your goal.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
          const SizedBox(height: 20),
          
          // Menggunakan Wrap agar aman di layar sempit
          Wrap(
            spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Obx(() => Text('+${controller.xpEarned.value} XP', style: const TextStyle(color: Colors.white, fontSize: 12))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Obx(() => Text('${controller.dayStreak.value} Day Streak', style: const TextStyle(color: Colors.white, fontSize: 12))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessAssessment() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.psychology, color: Color(0xFF1A365D)), SizedBox(width: 8),
              Text('AI Readiness Assessment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
            child: const Text('Ready to Advance', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          const Text('Recommended Action: Advance to Next Level', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 8),
          const Text.rich(
            TextSpan(
              text: 'Note: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
              children: [TextSpan(text: "While you are ready to move forward, reviewing the 'Recommended Focus' areas below will ensure a significantly stronger foundation.", style: TextStyle(fontWeight: FontWeight.normal))],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('READINESS LEVEL', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Obx(() => Text('${(controller.readinessLevel.value * 100).toInt()}%', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 6),
          Obx(() => LinearProgressIndicator(value: controller.readinessLevel.value, backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue), minHeight: 6, borderRadius: BorderRadius.circular(3))),
        ],
      ),
    );
  }

  Widget _buildRecommendedFocusList() {
    return Column(
      children: controller.recommendedFocus.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, decoration: BoxDecoration(color: item['color'], borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(item['icon'], size: 18, color: item['color']), SizedBox(width: 8),
                            Expanded(child: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(item['description'], style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4)),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A365D), side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(item['buttonText'], style: const TextStyle(fontSize: 12)),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIncorrectAnswersList() {
    return Column(
      children: controller.incorrectAnswers.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['question'], style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
                    const SizedBox(height: 6),
                    Text(item['reviewReq'], style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('Review Concept', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}