import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart' as dio_pkg; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizzin/app/services/api_service.dart';
import 'package:quizzin/app/services/face_service.dart';


class FaceRegistrationController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  FaceService? _faceService;

  final currentStep = 0.obs;
  final profileImage = Rx<File?>(null);
  final isLoading = false.obs;

  CameraController? cameraController;
  CameraDescription? _camera;
  final isCameraInitialized = false.obs;
  final isScanningFace = false.obs;
  final faceRegistered = false.obs;

  @override
  void onInit() {
    super.onInit();
    _faceService = FaceService();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    _faceService?.dispose();
    super.onClose();
  }

  Future<void> pickProfileImage(ImageSource source) async {
    try {
      isLoading.value = true;
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        String filePath = pickedFile.path;
        String fileName = filePath.split('/').last;

        dio_pkg.FormData formData = dio_pkg.FormData.fromMap({
          "file": await dio_pkg.MultipartFile.fromFile(
            filePath,
            filename: fileName,
            contentType: dio_pkg.DioMediaType('image', 'jpeg'),
          ),
        });

        await _apiService.dio.put(
          '/profile/avatar',
          data: formData,
        );

        profileImage.value = File(filePath);

        Get.snackbar(
          'Upload Berhasil',
          'Foto profil Anda telah sukses disimpan ke database.',
          backgroundColor: const Color(0xFF0056FF),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // Lanjut otomatis ke langkah cetak Face ID
        goToFaceStep();
      }
    } catch (e) {
      debugPrint('Gagal mengunggah foto profil: $e');
      String errorMessage = 'Gagal menyimpan foto profil ke database.';

      if (e is dio_pkg.DioException) {
        final detail = e.response?.data?['detail'];
        if (detail != null && detail is String) errorMessage = detail;
      }

      Get.snackbar(
        'Gagal Menyimpan',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> goToFaceStep() async {
    currentStep.value = 1;
    await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      isCameraInitialized.value = false;

      final cameras = await availableCameras();
      _camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        _camera!,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;

      await _faceService!.initialize();
    } catch (e) {
      Get.snackbar('Camera Error', 'Tidak dapat mengakses kamera: $e');
    }
  }

  Future<void> startRealtimeScan() async {
    if (isScanningFace.value || faceRegistered.value) return;
    if (_faceService == null || !_faceService!.isInitialized) return;

    isScanningFace.value = true;

    try {
      final photoFile = await cameraController!.takePicture();
      await cameraController?.pausePreview();
      await _processFacePhoto(photoFile.path);
    } catch (e) {
      isScanningFace.value = false;
      Get.snackbar(
        'Error',
        'Gagal memproses wajah: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> _processFacePhoto(String photoPath) async {
    try {
      final faceRect = await _faceService!.detectFaceInFile(photoPath);

      if (faceRect == null) {
        isScanningFace.value = false;
        cameraController?.resumePreview(); 
        Get.snackbar(
          'Face Not Detected',
          'Wajah tidak terdeteksi, silakan coba lagi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return;
      }

      final croppedFace = await _faceService!.cropFaceFromFile(
        photoPath,
        faceRect,
      );
      final embedding = _faceService!.generateEmbedding(croppedFace);

      await _apiService.dio.post(
        '/auth/register-face',
        data: {'embedding': embedding},
      );

      isScanningFace.value = false;
      faceRegistered.value = true;

      Get.snackbar(
        'Face Registered!',
        'Wajah berhasil didaftarkan.',
        backgroundColor: const Color(0xFF0056FF),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      isScanningFace.value = false;
      cameraController?.resumePreview();
      String message = 'Gagal memproses wajah';
      if (e is dio_pkg.DioException) {
        final detail = e.response?.data?['detail'];
        if (detail != null && detail is String) {
          message = detail;
        }
      }
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void goBackStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      cameraController?.dispose();
      cameraController = null;
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
      Get.snackbar(
        'Incomplete',
        'Harap selesaikan kedua langkah terlebih dahulu.',
        backgroundColor: Colors.orange.shade100,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
