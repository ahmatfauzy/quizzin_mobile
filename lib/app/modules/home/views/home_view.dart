import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/modules/home/controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  Widget _buildPopUpAnimation(Widget child, int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeOutBack,
      builder: (context, value, childWidget) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: childWidget),
        );
      },
      child: child,
    );
  }

  Widget _buildSlideDownAnimation(Widget child, int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        return Transform.translate(
          offset: Offset(0, -30 * (1 - value)),
          child: Opacity(opacity: value, child: childWidget),
        );
      },
      child: child,
    );
  }

  Widget _buildSlideUpAnimation(Widget child, int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delayMs),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _buildSlideDownAnimation(
          const Text(
            'Quizzin',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          0,
        ),
        centerTitle: true,
        actions: [
          _buildSlideDownAnimation(
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () => controller.openProfile(),
                child: Obx(() {
                  if (controller.isProfileLoading.value) {
                    return const SizedBox(
                      width: 32,
                      height: 32,
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 2.5,
                        ),
                      ),
                    );
                  }
                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: NetworkImage(
                      controller.profilePicUrl.value,
                    ),
                  );
                }),
              ),
            ),
            150,
          ),
        ],
      ),

      floatingActionButton: Obx(
        () => controller.recentMaterials.isEmpty
            ? const SizedBox.shrink()
            : _buildPopUpAnimation(
                FloatingActionButton.extended(
                  onPressed: () => controller.addNewMaterial(),
                  backgroundColor: primaryColor,
                  elevation: 4,
                  icon: controller.isUploadingDocument.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    controller.isUploadingDocument.value
                        ? 'Uploading...'
                        : 'New Quiz',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                800,
              ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildPopUpAnimation(_buildWelcomeCard(), 200),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildSlideUpAnimation(_buildWeeklyActivity(), 400),
            ),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildSlideUpAnimation(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Materials',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Obx(
                      () => controller.recentMaterials.isEmpty
                          ? const SizedBox()
                          : TextButton(
                              onPressed: () => controller.openAllMaterials(),
                              child: const Text(
                                'See All',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
                500,
              ),
            ),
            const SizedBox(height: 12),

            Obx(() {
              Widget content = controller.recentMaterials.isEmpty
                  ? _buildEmptyState()
                  : _buildRecentMaterialsVertical();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildSlideUpAnimation(content, 600),
              );
            }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    const primaryColor = Color(0xFF0056FF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E60E8), Color(0xFF0A349E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A349E).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.isProfileLoading.value) {
                    return const Text(
                      'Welcome back,\nMemuat...',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    );
                  }
                  return Text(
                    'Welcome back,\n${controller.userName.value}! 👋',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  );
                }),
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '⚡ ${controller.xpPoints.value} Total XP',
                    style: const TextStyle(
                      color: Color(0xFFA5E08B),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => Text(
              "You're on a ${controller.streakDays.value}-day learning streak. Keep up the momentum in your advanced module.",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Level Progress Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        'Level ${controller.level.value} Scholar',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${controller.xpInCurrentLevel.value} / ${controller.xpPerLevel} XP (${(controller.levelProgress.value * 100).toInt()}%)',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Obx(
                    () => LinearProgressIndicator(
                      value: controller.levelProgress.value,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFA5E08B),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Obx(() {
            final int? lastReadId = controller.lastReadDocumentId.value;
            int? targetId;

            if (lastReadId != null) {
              targetId = lastReadId;
            }
            else if (controller.recentMaterials.isNotEmpty) {
              targetId = controller.recentMaterials.first['id'];
            }

            return SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: targetId != null
                    ? () => controller.goToDocumentDetails(targetId!)
                    : () => controller.openAllMaterials(),
                icon: const Icon(
                  Icons.play_circle_outline,
                  color: Color(0xFF0056FF),
                ),
                label: Text(
                  lastReadId != null ? 'Resume Lesson' : 'Explore Materials',
                  style: const TextStyle(
                    color: Color(0xFF0A349E),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            );
          }),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Weekly Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.show_chart, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 32),
          uiSizedBarGraph(),
        ],
      ),
    );
  }

  Widget uiSizedBarGraph() {
    const primaryColor = Color(0xFF0056FF);

    return SizedBox(
      height: 140,
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(controller.days.length, (index) {
            bool isSelected = controller.selectedDayIndex.value == index;
            double barHeight = controller.weeklyActivityData[index] * 80;
            if (barHeight < 6) barHeight = 6;

            return GestureDetector(
              onTap: () => controller.selectDay(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      '${(controller.weeklyActivityData[index] * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: 32,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor
                          : const Color(0xFFE8F1FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.days[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? primaryColor : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // --- 3. KOMPONEN VERTIKAL LIST MATERI (RECENT MATERIALS) ---
  Widget _buildRecentMaterialsVertical() {
    const primaryColor = Color(0xFF0056FF);

    return Column(
      children: controller.recentMaterials.map((material) {
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

        bool isProcessing = material['status'] == 'processing';
        bool isFailed = material['status'] == 'failed';

        return GestureDetector(
          onTap: isProcessing
              ? () => Get.snackbar(
                  'Mohon Tunggu',
                  'Dokumen masih diproses oleh sistem AI...',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.amber.shade50,
                )
              : () => controller.goToDocumentDetails(material['id']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material['title'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isProcessing
                                ? 'Processing by AI...'
                                : (isFailed
                                      ? 'Failed to process'
                                      : material['type'].toString()),
                            style: TextStyle(
                              fontSize: 11,
                              color: isProcessing
                                  ? Colors.orange.shade700
                                  : (isFailed ? Colors.red : Colors.black54),
                              fontWeight: isProcessing
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Text(
                            material['time'].toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: isProcessing ? null : (isFailed ? 0.0 : 1.0),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isFailed
                              ? Colors.red
                              : (isProcessing ? Colors.orange : iconColor),
                        ),
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(3),
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
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.upload_file,
              color: Color(0xFF0056FF),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Recent Materials',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your first PDF document to start generating smart quizzes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: () => controller.addNewMaterial(),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Upload PDF',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0056FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
