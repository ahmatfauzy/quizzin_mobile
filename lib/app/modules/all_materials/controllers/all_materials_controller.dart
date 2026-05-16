import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllMaterialsController extends GetxController {
  final searchController = TextEditingController();

  // Daftar materi yang lebih lengkap
  final allMaterials = <Map<String, dynamic>>[
    {
      'title': 'Computer Vision Chapter 4',
      'type': 'PDF Document',
      'theme': 'vision',
      'progress': 0.6,
      'time': '2h ago',
    },
    {
      'title': 'NLP Midterm Practice',
      'type': 'PDF Document',
      'theme': 'language',
      'progress': 0.25,
      'time': 'Yesterday',
    },
    {
      'title': 'Advanced Machine Learning',
      'type': 'PDF Document',
      'theme': 'ml',
      'progress': 1.0,
      'time': '3d ago',
    },
    {
      'title': 'Deep Learning Basics',
      'type': 'PDF Document',
      'theme': 'ml',
      'progress': 0.0,
      'time': 'Last Week',
    },
    {
      'title': 'Speech Recognition Systems',
      'type': 'PDF Document',
      'theme': 'language',
      'progress': 0.8,
      'time': 'Last Month',
    },
  ].obs;

  void openMaterial() {
    Get.toNamed('/chapter-details');
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}