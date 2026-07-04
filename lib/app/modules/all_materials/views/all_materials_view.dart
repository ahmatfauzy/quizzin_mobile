import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/modules/all_materials/controllers/all_materials_controller.dart';

class AllMaterialsView extends GetView<AllMaterialsController> {
  const AllMaterialsView({Key? key}) : super(key: key);

  Widget _buildGridItemAnimation(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 450 + ((index % 6) * 100)),
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

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0056FF);
    const backgroundColor = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context) ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ) : null,
        title: const Text(
          'All Materials',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
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

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchAllDocuments(),
              color: primaryColor,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (controller.hasError.value) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 400,
                        child: _buildErrorState(),
                      ),
                    ],
                  );
                }

                if (controller.filteredMaterials.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 400,
                        child: Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1.0),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutBack,
                            builder: (context, val, childWidget) =>
                                Transform.scale(scale: val, child: childWidget),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.search_off_rounded,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No materials found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Coba cari dengan kata kunci lain.',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: controller.filteredMaterials.length,
                  itemBuilder: (context, index) {
                    final material = controller.filteredMaterials[index];

                    bool isProcessing = material['status'] == 'processing';
                    bool isFailed = material['status'] == 'failed';

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

                    return _buildGridItemAnimation(
                      GestureDetector(
                        onTap: isProcessing
                            ? () => Get.snackbar(
                                'Mohon Tunggu',
                                'Dokumen masih diproses oleh sistem AI...',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.amber.shade50,
                              )
                            : () =>
                                  controller.goToDocumentDetails(material['id']),
                        child: Container(
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  iconData,
                                  color: isProcessing ? Colors.orange : iconColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Text(
                                material['title'].toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),

                              Text(
                                isProcessing
                                    ? 'Processing...'
                                    : (isFailed
                                          ? 'Failed'
                                          : material['time'].toString()),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isProcessing
                                      ? Colors.orange.shade700
                                      : (isFailed ? Colors.red : Colors.grey),
                                  fontWeight: isProcessing
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),

                              const Spacer(),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        isProcessing
                                            ? 'AI...'
                                            : (isFailed
                                                  ? '0%'
                                                  : '${(material['progress'] * 100).toInt()}%'),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isFailed
                                              ? Colors.red
                                              : (isProcessing
                                                    ? Colors.orange
                                                    : iconColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: isProcessing
                                        ? null
                                        : (isFailed
                                              ? 0.0
                                              : material['progress'] as double),
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isFailed
                                          ? Colors.red
                                          : (isProcessing
                                                ? Colors.orange
                                                : iconColor),
                                    ),
                                    minHeight: 4,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      index,
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Koneksi Bermasalah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Gagal terhubung ke server. Silakan periksa internetmu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.fetchAllDocuments(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text(
              'Muat Ulang',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0056FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
