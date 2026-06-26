import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/modules/select_difficulty/controllers/select_difficulty_controller.dart';
import 'package:quizzin/app/modules/select_difficulty/widgets/difficulty_card.dart';


class SelectDifficultyView extends GetView<SelectDifficultyController> {
  const SelectDifficultyView({Key? key}) : super(key: key);

  Widget _buildSlideAnimation(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 120)),
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(opacity: value, child: childWidget),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0056FF);
    const backgroundColor = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Center(
              child: Text(
                'Intellect',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildSlideAnimation(
                      const Text('Select Difficulty', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                      0,
                    ),
                    const SizedBox(height: 12),
                    _buildSlideAnimation(
                      const Text(
                        'Choose the challenge level that best matches your current academic goals for this module.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
                      ),
                      1,
                    ),
                    const SizedBox(height: 32),
                    
                    Obx(() {
                      final currentSelection = controller.selectedDifficulty.value;

                      return Column(
                        children: [
                          _buildSlideAnimation(
                            DifficultyCard(
                              title: 'Easy',
                              description: 'Focuses on foundational concepts and straightforward recall. Ideal for warming up.',
                              icon: Icons.sentiment_satisfied_alt_rounded,
                              iconBgColor: const Color(0xFFE8F1FF),
                              iconColor: primaryColor,
                              isSelected: currentSelection == 'easy',
                              onTap: () => controller.selectLevel('easy'),
                            ),
                            2,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildSlideAnimation(
                            DifficultyCard(
                              title: 'Medium',
                              description: 'Requires applying concepts to standard problems. Balances speed and accuracy.',
                              icon: Icons.bar_chart_rounded,
                              iconBgColor: const Color(0xFFE8F1FF),
                              iconColor: primaryColor,
                              isSelected: currentSelection == 'medium',
                              onTap: () => controller.selectLevel('medium'),
                            ),
                            3,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildSlideAnimation(
                            DifficultyCard(
                              title: 'HOTS',
                              description: 'Higher Order Thinking Skills. Complex problem solving, synthesis, and critical analysis.',
                              icon: Icons.psychology_rounded,
                              iconBgColor: const Color(0xFFFFEBEE), 
                              iconColor: const Color(0xFFD32F2F), 
                              isSelected: currentSelection == 'hots',
                              onTap: () => controller.selectLevel('hots'),
                            ),
                            4,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => controller.startQuiz(),
                  icon: const Text('Start Quiz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  label: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 2,
                    shadowColor: primaryColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), 
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}