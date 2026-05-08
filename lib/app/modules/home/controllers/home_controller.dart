import 'package:get/get.dart';

class HomeController extends GetxController {
  // --- Data Profil & Progress ---
  final userName = 'Bale'.obs;
  final progress = 0.75.obs; // 75%
  final knowledgePoints = '1,250'.obs;
  final subjectsMastered = 12.obs;

  // --- Data Weekly Activity (Tinggi Bar Chart) ---
  final List<Map<String, dynamic>> weeklyData = [
    {'day': 'M', 'height': 40.0, 'isToday': false},
    {'day': 'T', 'height': 70.0, 'isToday': false},
    {'day': 'W', 'height': 90.0, 'isToday': true},
    {'day': 'T', 'height': 30.0, 'isToday': false},
    {'day': 'F', 'height': 50.0, 'isToday': false},
  ];

  // --- Data Recent Documents ---
  final recentDocuments = [
    {
      'title': 'Computer_Vision_Basics.pdf',
      'meta': 'Uploaded 2 days ago • 14 pages',
    },
    {
      'title': 'SakuSelamat_Requirements.pdf',
      'meta': 'Uploaded 5 days ago • 32 pages',
    }
  ];
}