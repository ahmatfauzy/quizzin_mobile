import 'package:get/get.dart';

import '../modules/all_materials/bindings/all_materials_binding.dart';
import '../modules/all_materials/views/all_materials_view.dart';
import '../modules/chapter_details/bindings/chapter_details_binding.dart';
import '../modules/chapter_details/views/chapter_details_view.dart';
import '../modules/concept_map/bindings/concept_map_binding.dart';
import '../modules/concept_map/views/concept_map_view.dart';
import '../modules/face_registration/bindings/face_registration_binding.dart';
import '../modules/face_registration/views/face_registration_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/quiz_play/bindings/quiz_play_binding.dart';
import '../modules/quiz_play/views/quiz_play_view.dart';
import '../modules/quiz_result/bindings/quiz_result_binding.dart';
import '../modules/quiz_result/views/quiz_result_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/select_difficulty/bindings/select_difficulty_binding.dart';
import '../modules/select_difficulty/views/select_difficulty_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      children: [
        GetPage(
          name: _Paths.HOME,
          page: () => const HomeView(),
          binding: HomeBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.CHAPTER_DETAILS,
      page: () => const ChapterDetailsView(),
      binding: ChapterDetailsBinding(),
    ),
    GetPage(
      name: _Paths.SELECT_DIFFICULTY,
      page: () => const SelectDifficultyView(),
      binding: SelectDifficultyBinding(),
    ),
    GetPage(
      name: _Paths.CONCEPT_MAP,
      page: () => const ConceptMapView(),
      binding: ConceptMapBinding(),
    ),
    GetPage(
      name: _Paths.QUIZ_PLAY,
      page: () => const QuizPlayView(),
      binding: QuizPlayBinding(),
    ),
    GetPage(
      name: _Paths.QUIZ_RESULT,
      page: () => const QuizResultView(),
      binding: QuizResultBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.ALL_MATERIALS,
      page: () => const AllMaterialsView(),
      binding: AllMaterialsBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.FACE_REGISTRATION,
      page: () => const FaceRegistrationView(),
      binding: FaceRegistrationBinding(),
    ),
  ];
}
