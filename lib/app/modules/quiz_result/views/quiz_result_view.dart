import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/modules/quiz_result/controllers/quiz_result_controller.dart';
import 'package:quizzin/app/modules/quiz_result/widgets/result_widgets.dart';

class QuizResultView extends GetView<QuizResultController> {
  const QuizResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0056FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Hasil Ujian Kamu', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScoreSummaryHeader(
                      score: controller.totalScore,
                      xp: controller.xpGained,
                      mastery: controller.masteryUpdated,
                      time: controller.formattedTimeTaken,
                    ),
                    const SizedBox(height: 28),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBDD4FF)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: primaryColor, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
                                children: [
                                  const TextSpan(text: 'Rekomendasi level tantangan AI kamu selanjutnya: '),
                                  TextSpan(
                                    text: controller.nextDifficultySuggestion.toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                                  )
                                ]
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    const Text('Pembahasan & Koreksi Soal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 14),
                    
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.results.length,
                      itemBuilder: (context, index) {
                        final itemResult = controller.results[index];
                        return QuestionReviewCard(result: itemResult);
                      },
                    )
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5))
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => controller.goToHome(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  ),
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}