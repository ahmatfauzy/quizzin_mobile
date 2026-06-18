import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizzin/app/modules/face_registration/controllers/face_registration_controller.dart';

class FaceRegistrationView extends GetView<FaceRegistrationController> {
  const FaceRegistrationView({Key? key}) : super(key: key);

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
          onPressed: () => controller.goBackStep(),
        ),
        title: const Text('Setup Identity', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Obx(() {
        return Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Indikator tahapan pengisian identitas
                    _buildStepper(controller.currentStep.value),
                    const SizedBox(height: 40),

                    // Transisi animasi antar tahapan langkah
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: controller.currentStep.value == 0
                          ? _buildProfilePicStep(controller, primaryColor)
                          : _buildFaceIdStep(controller, primaryColor),
                    ),
                    
                    const SizedBox(height: 50),
                    _buildMainActionButton(controller, primaryColor),
                  ],
                ),
              ),
            ),
            
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: primaryColor, strokeWidth: 4),
                ),
              )
          ],
        );
      }),
    );
  }

  Widget _buildStepper(int currentStep) {
    return Row(
      children: [
        _buildStepIndicator(0, 'Photo', currentStep >= 0),
        Expanded(child: Container(height: 2, color: currentStep >= 1 ? const Color(0xFF0056FF) : Colors.grey.shade300)),
        _buildStepIndicator(1, 'Face ID', currentStep >= 1),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    final color = isActive ? const Color(0xFF0056FF) : Colors.grey.shade400;
    return Column(
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: isActive ? color : Colors.white, shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
          child: Center(child: Text('${step + 1}', style: TextStyle(color: isActive ? Colors.white : color, fontWeight: FontWeight.bold, fontSize: 12))),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildProfilePicStep(FaceRegistrationController controller, Color primaryColor) {
    return Column(
      key: const ValueKey(0),
      children: [
        const Text('Add Profile Photo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 10),
        const Text('This will be visible to your partners and on the leaderboard.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4)),
        const SizedBox(height: 40),
        
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: controller.profileImage.value != null ? FileImage(controller.profileImage.value!) : null,
                child: controller.profileImage.value == null ? Icon(Icons.person, size: 70, color: Colors.grey.shade400) : null,
              ),
            ),
            GestureDetector(
              onTap: () => _showImagePickerBottomSheet(controller, primaryColor),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            )
          ],
        ),
      ],
    );
  }

  void _showImagePickerBottomSheet(FaceRegistrationController controller, Color primaryColor) async {
    final ImageSource? source = await Get.bottomSheet<ImageSource>(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pick Profile Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: primaryColor),
              title: const Text('Take from Camera'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: primaryColor),
              title: const Text('Choose from Gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
    if (source != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      controller.pickProfileImage(source);
    }
  }

  Widget _buildFaceIdStep(FaceRegistrationController controller, Color primaryColor) {
    // Menghapus Obx internal karena fungsi pemanggil di tingkat atas (body) sudah reactive
    Color borderColor = controller.faceRegistered.value ? Colors.green : primaryColor;

    return Column(
      key: const ValueKey(1),
      children: [
        const Text('Register Your Face', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 10),
        const Text('Position your face within the frame to enable smart recognition features.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4)),
        const SizedBox(height: 40),
        
        Container(
          width: 220, height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle, 
            border: Border.all(color: borderColor, width: 5),
            boxShadow: [BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 20)],
          ),
          child: ClipOval(
            child: !controller.isCameraInitialized.value 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF0056FF)))
              : Stack(
                  children: [
                    Positioned.fill(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller.cameraController!.value.previewSize?.height ?? 1,
                          height: controller.cameraController!.value.previewSize?.width ?? 1,
                          child: CameraPreview(controller.cameraController!),
                        ),
                      ),
                    ),

                    if (controller.isScanningFace.value)
                      Positioned.fill(
                        child: Container(
                          color: primaryColor.withOpacity(0.3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.face_retouching_natural, color: Colors.white, size: 50),
                              SizedBox(height: 8),
                              Text('Detecting, Dont move!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2)),
                            ],
                          ),
                        ),
                      ),

                    if (controller.faceRegistered.value)
                      Positioned.fill(
                        child: Container(
                          color: Colors.green.withOpacity(0.5),
                          child: const Icon(Icons.check_circle, color: Colors.white, size: 80),
                        ),
                      ),
                  ],
                ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        OutlinedButton.icon(
          onPressed: controller.faceRegistered.value || controller.isScanningFace.value 
              ? null 
              : () => controller.startRealtimeScan(),
          icon: Icon(controller.faceRegistered.value ? Icons.check : Icons.document_scanner),
          label: Text(controller.faceRegistered.value ? 'Face Registered' : 'Start Scan'),
          style: OutlinedButton.styleFrom(
            foregroundColor: controller.faceRegistered.value ? Colors.green : primaryColor, 
            side: BorderSide(color: controller.faceRegistered.value ? Colors.green : primaryColor, width: 2), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
          ),
        ),
        
        const SizedBox(height: 32),
        Text(
          'Face recognition model by MCarlomagno\nLicensed under BSD-3-Clause',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildMainActionButton(FaceRegistrationController controller, Color primaryColor) {
    bool isCompleted = controller.profileImage.value != null && controller.faceRegistered.value;
    
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton(
        onPressed: isCompleted ? () => controller.finishRegistration() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300, 
          disabledForegroundColor: Colors.grey.shade500,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
          elevation: 0,
        ),
        child: const Text('Complete Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}