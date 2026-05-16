import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class FaceRegistrationController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // State untuk Step 1 (Profile Image)
  final currentStep = 0.obs;
  final profileImage = Rx<File?>(null);
  final isLoading = false.obs;

  // State untuk Step 2 (Real-time Face Camera)
  CameraController? cameraController;
  final isCameraInitialized = false.obs;
  final isScanningFace = false.obs;
  final faceRegistered = false.obs;

  @override
  void onClose() {
    cameraController?.dispose(); // Jangan lupa matikan kamera saat halaman ditutup
    super.onClose();
  }

  // --- FUNGSI STEP 1: Mengambil Foto Profil ---
  Future<void> pickProfileImage(ImageSource source) async {
    try {
      isLoading.value = true;
      final XFile? pickedFile = await _picker.pickImage(source: source, maxWidth: 500, imageQuality: 80);
      
      if (pickedFile != null) {
        profileImage.value = File(pickedFile.path);
        goToFaceStep(); // Lanjut ke langkah kamera real-time
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI TRANSISI KE STEP 2 ---
  void goToFaceStep() {
    currentStep.value = 1;
    _initCamera(); // Hidupkan kamera saat masuk step ini
  }

  // --- FUNGSI STEP 2: Inisialisasi Live Camera ---
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      // Cari kamera depan (front-facing)
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false, // Kita tidak butuh suara
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      Get.snackbar('Camera Error', 'Tidak dapat mengakses kamera: $e');
    }
  }

  // --- FUNGSI STEP 2: Simulasi Deteksi ML Kit Real-time ---
  void startRealtimeScan() {
    isScanningFace.value = true;

    // Disini nantinya kamu meletakkan ImageStream untuk Google ML Kit.
    // Untuk saat ini, kita gunakan timer 3 detik untuk mensimulasikan proses deteksi.
    Future.delayed(const Duration(seconds: 3), () {
      isScanningFace.value = false;
      faceRegistered.value = true;

      // Pause kamera agar layar 'membeku' pada wajah yang berhasil ditangkap
      cameraController?.pausePreview();

      Get.snackbar(
        'Face Detected!', 
        'Wajah berhasil dipetakan ke dalam sistem (Simulasi).',
        backgroundColor: const Color(0xFF0056FF),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    });
  }

  // --- TOMBOL KEMBALI & FINISH ---
  void goBackStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      cameraController?.dispose(); // Matikan kamera jika kembali ke step 1
      isCameraInitialized.value = false;
      faceRegistered.value = false;
    } else {
      Get.back();
    }
  }

  void finishRegistration() {
    if (profileImage.value != null && faceRegistered.value) {
      Get.offAllNamed('/home');
    } else {
      Get.snackbar('Incomplete', 'Please complete both steps first.', backgroundColor: Colors.orange.shade100);
    }
  }
}