import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/modules/quiz_play/controllers/quiz_play_controller.dart';
import 'package:quizzin/app/modules/quiz_play/widgets/quiz_widgets.dart';

class QuizPlayView extends GetView<QuizPlayController> {
  const QuizPlayView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0056FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Obx(
          () => Text(
            controller.chapterTitle.value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.grid_view_rounded, color: primaryColor),
          tooltip: 'Daftar Soal',
          onPressed: () {
            if (controller.isLoading.value) return;
            Get.bottomSheet(
              QuestionGridSheet(
                totalQuestions: controller.totalQuestions.value,
                currentIndex: controller.currentIndex.value,
                userAnswers: controller.userAnswers,
                questions: controller.questions,
                onNodeTap: (index) => controller.jumpToQuestion(index),
              ),
            );
          },
        ),
        actions: [
          // COUNTDOWN LIVE TIMER INDIKATOR
          Center(
            child: Obx(
              () => Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: controller.remainingSeconds.value < 300
                      ? Colors.red.shade50
                      : const Color(0xFFE8F1FF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: controller.remainingSeconds.value < 300
                          ? Colors.red
                          : primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      controller.formattedTime,
                      style: TextStyle(
                        color: controller.remainingSeconds.value < 300
                            ? Colors.red
                            : primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }

        final currentQuestion =
            controller.questions[controller.currentIndex.value];
        final int questionId = currentQuestion['id'];
        final String questionType =
            currentQuestion['question_type'] ?? 'multiple_choice';
        final List options = currentQuestion['options'] ?? [];

        double currentProgress =
            (controller.currentIndex.value + 1) /
            controller.totalQuestions.value;

        return Stack(
          children: [
            Column(
              children: [
                // PROGRESS BAR ATAS
                LinearProgressIndicator(
                  value: currentProgress,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                  minHeight: 5,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                questionType == 'essay'
                                    ? 'ESSAY'
                                    : 'PILIHAN GANDA',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            if (currentQuestion['subject_tag'] != null) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    currentQuestion['subject_tag']
                                        .toString()
                                        .toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow
                                        .ellipsis, // Potong teks menjadi isi '...' jika terlalu panjang
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 20),
                        Text(
                          'PERTANYAAN ${controller.currentIndex.value + 1} DARI ${controller.totalQuestions.value}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Teks Soal Kuis
                        Text(
                          currentQuestion['question_text'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),

                        if (questionType == 'essay')
                          EssayInputField(
                            key: ValueKey('essay_$questionId'),
                            questionId: questionId,
                            initialValue:
                                controller.userAnswers[questionId] ?? '',
                            onAnswerChanged: (value) =>
                                controller.saveAnswer(questionId, value),
                          )
                        else
                          ...options.map((opt) {
                            String optKey = opt['key'] ?? '';
                            return ChoiceOptionCard(
                              optionKey: optKey,
                              optionText: opt['text'] ?? '',
                              isSelected:
                                  controller.userAnswers[questionId] == optKey,
                              onTap: () =>
                                  controller.saveAnswer(questionId, optKey),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03), 
                        blurRadius: 12, 
                        offset: const Offset(0, -4),
                      )
                    ],
                    border: const Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
                  ),
                  child: SafeArea(
                    child: Obx(() {
                      bool isLastQuestion = controller.currentIndex.value == controller.totalQuestions.value - 1;
                      
                      return Row(
                        children: [
                          if (controller.currentIndex.value > 0)
                            Expanded(
                              flex: isLastQuestion ? 3 : 1, 
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: () => controller.jumpToQuestion(controller.currentIndex.value - 1),
                                  icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF475569)),
                                  label: const Text(
                                    'Kembali', 
                                    style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                            ),
                          
                          if (controller.currentIndex.value > 0) const SizedBox(width: 12),
                          
                          Expanded(
                            flex: controller.currentIndex.value > 0 
                                ? (isLastQuestion ? 4 : 1) 
                                : 2, 
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (isLastQuestion) {
                                    controller.confirmSubmitQuiz();
                                  } else {
                                    controller.jumpToQuestion(controller.currentIndex.value + 1);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isLastQuestion ? const Color(0xFF10B981) : primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor: isLastQuestion 
                                      ? const Color(0xFF10B981).withOpacity(0.3) 
                                      : primaryColor.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        isLastQuestion ? 'Kirim Jawaban' : 'Lanjut',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis, 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.3),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      isLastQuestion ? Icons.cloud_upload_rounded : Icons.arrow_forward_rounded, 
                                      size: 16, 
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                )
              ],
            ),

            if (controller.isSubmitting.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Sedang mengkalkulasi nilai ujian...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
