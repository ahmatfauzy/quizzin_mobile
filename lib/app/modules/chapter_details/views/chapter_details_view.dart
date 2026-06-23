import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chapter_details_controller.dart';

class ChapterDetailsView extends GetView<ChapterDetailsController> {
  const ChapterDetailsView({Key? key}) : super(key: key);

  // ANIMASI: Staggered Slide Up Effect
  Widget _buildStaggeredSlideAnimation(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 150)),
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Intellect',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Obx(() {
              final url = controller.profilePicUrl.value;
              return CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
                child: url.isEmpty
                    ? const Icon(Icons.person, size: 16, color: Colors.grey)
                    : null,
              );
            }),
          ),
        ],
      ),
      body: Obx(() {
        return Stack(
          children: [
            // Konten Utama Screen
            if (!controller.isLoading.value)
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row Judul Dokumen & Tombol Hapus Materi
                    _buildStaggeredSlideAnimation(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Source Document Chip Info
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf,
                                    size: 14,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'SOURCE: ${controller.documentTitle.value}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Tombol (Hapus Materi) di Sebelah Chip Judul
                          TextButton.icon(
                            onPressed: () => controller.confirmDeleteDocument(),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              size: 16,
                            ),
                            label: const Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      0,
                    ),
                    const SizedBox(height: 20),

                    _buildStaggeredSlideAnimation(
                      const Text(
                        'Extracted Chapters',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      1,
                    ),
                    const SizedBox(height: 12),

                    _buildStaggeredSlideAnimation(
                      const Text(
                        "We've processed your document and identified key thematic sections. Select a chapter to engage with interactive concepts and track your mastery.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      2,
                    ),
                    const SizedBox(height: 24),

                    // Render List Card Bab
                    Column(
                      children: List.generate(controller.chapters.length, (
                        index,
                      ) {
                        final chapter = controller.chapters[index];
                        return _buildStaggeredSlideAnimation(
                          _buildChapterCard(chapter),
                          index + 3,
                        );
                      }),
                    ),
                  ],
                ),
              ),

            // LOADING OVERLAY UTAMA
            if (controller.isLoading.value)
              const Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),

            // LOADING OVERLAY PENGHAPUSAN
            if (controller.isDeleting.value)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Sedang menghapus materi...',
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

  Widget _buildChapterCard(Map<String, dynamic> data) {
    bool isMastered = data['status'] == 'mastered';
    bool isInProgress = data['status'] == 'in_progress';
    bool isLocked = data['status'] == 'locked';

    double masteryValue = 0.0;
    if (data['mastery'] != null) {
      masteryValue = (data['mastery'] as num).toDouble();
    }

    Color buttonColor = isInProgress ? const Color(0xFF0056FF) : Colors.white;
    Color buttonTextColor = isInProgress
        ? Colors.white
        : const Color(0xFF0056FF);
    String buttonText = isMastered
        ? 'Review Concepts'
        : (isInProgress ? 'Continue Exploring' : 'Explore Concepts');
    IconData? buttonIcon = isMastered ? Icons.refresh : Icons.arrow_forward;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isMastered)
            Container(
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),

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
                          Row(
                            children: [
                              Text(
                                data['chapter'] ?? 'CHAPTER',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (data['page_range'] != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '•  ${data['page_range']}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data['title'] ?? 'Untitled',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusIcon(data['status'] ?? 'locked'),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mastery',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      '${(masteryValue * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isMastered
                            ? Colors.green
                            : (isInProgress
                                  ? const Color(0xFF0056FF)
                                  : Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: masteryValue,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isMastered ? Colors.green : const Color(0xFF0056FF),
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isLocked
                        ? null
                        : () => controller.goToConceptMap(data),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLocked
                          ? Colors.grey.shade100
                          : buttonColor,
                      foregroundColor: isLocked
                          ? Colors.grey.shade400
                          : buttonTextColor,
                      elevation: 0,
                      side: isLocked
                          ? BorderSide(color: Colors.grey.shade300)
                          : const BorderSide(color: Color(0xFF0056FF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLocked ? Icons.lock_outline : buttonIcon,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // PERBAIKAN: Pemisahan Icon Status Dinamis (Anti Gembok Tertukar)
  // ====================================================================
  Widget _buildStatusIcon(String status) {
    if (status == 'mastered') {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 20,
        ),
      );
    } else if (status == 'in_progress') {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.trending_up,
          color: Color(0xFF0056FF),
          size: 20,
        ),
      );
    } else if (status == 'not_started') {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.book,
          color: Color(0xFF0056FF),
          size: 20,
        ),
      );
    } else {
      // True Locked state
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
      );
    }
  }
}
