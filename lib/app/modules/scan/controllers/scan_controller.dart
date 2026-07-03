import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'package:quizzin/app/services/api_service.dart';

class ScanController extends GetxController {
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  final isScanning = true.obs;
  final ApiService _apiService = ApiService();

  void onDetect(BarcodeCapture capture) async {
    if (!isScanning.value) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        isScanning.value = false;
        String qrData = barcode.rawValue!;
        
        int? docId = _extractDocId(qrData);
        
        if (docId != null) {
          await _fetchDocumentAndShowPopup(docId);
        } else {
          Get.snackbar(
            'QR Tidak Valid',
            'Format QR Code tidak dikenali: $qrData',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
          );
          _resumeScanning(3);
        }
        break; 
      }
    }
  }

  int? _extractDocId(String data) {
    RegExp regex = RegExp(r'\d+');
    var match = regex.firstMatch(data);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return null;
  }

  Future<void> _fetchDocumentAndShowPopup(int docId) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await _apiService.dio.get('/documents/shared/$docId');
      final data = response.data;
      Get.back(); // Tutup loading

      _showDocumentPopup(docId, data);
    } catch (e) {
      Get.back(); // Tutup loading
      Get.snackbar(
        'Gagal',
        'Dokumen tidak ditemukan atau bersifat privat.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
      );
      _resumeScanning(2);
    }
  }

  void _showDocumentPopup(int docId, Map<String, dynamic> docData) {
    String title = docData['title'] ?? docData['original_filename'] ?? 'Materi Belajar';
    int totalChapters = docData['total_chapters'] ?? 0;
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Dokumen Ditemukan!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0056FF),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description, size: 40, color: Color(0xFF0056FF)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalChapters Bab Kuis',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _importAndStartQuiz(docId),
                child: const Text(
                  'Simpan & Mulai Kuis',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Get.back();
                  _resumeScanning(1);
                },
                child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              ),
            )
          ],
        ),
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }

  Future<void> _importAndStartQuiz(int docId) async {
    Get.back(); // Tutup bottom sheet
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await _apiService.dio.post('/documents/scan/$docId');
      final data = response.data;
      int newDocId = data['id'] ?? docId;
      Get.back(); // Tutup loading
      
      Get.toNamed('/chapter-details', arguments: newDocId)?.then((_) {
        _resumeScanning(1);
      });
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Terjadi kesalahan saat menyimpan dokumen');
      _resumeScanning(2);
    }
  }

  void _resumeScanning(int delaySeconds) {
    Future.delayed(Duration(seconds: delaySeconds), () {
      isScanning.value = true;
    });
  }

  void toggleTorch() {
    cameraController.toggleTorch();
  }
  
  void switchCamera() {
    cameraController.switchCamera();
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}

