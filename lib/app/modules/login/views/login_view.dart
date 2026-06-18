import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/modules/login/controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0056FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: HeaderWaveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E60E8), Color(0xFF0A349E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logos/logoblue.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.school,
                                size: 50,
                                color: primaryColor,
                              ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Quizzin",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Continue your advanced learning journey",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.80),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.36),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AnimatedCapsuleInput(
                            controller: controller.emailController,
                            hintText: "Email Address",
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          _AnimatedCapsuleInput(
                            controller: controller.passwordController,
                            hintText: "Password",
                            prefixIcon: Icons.lock_outlined,
                            obscureText: true,
                          ),
                          const SizedBox(height: 6),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Get.toNamed('/forgot-password'),
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.all(4),
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            height: 52,
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor: primaryColor.withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          SizedBox(
                            height: 52,
                            child: Obx(
                              () => OutlinedButton.icon(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.loginWithFace,
                                icon: const Icon(
                                  Icons.face_unlock_rounded,
                                  size: 22,
                                ),
                                label: const Text(
                                  "Login with Face ID",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: const BorderSide(
                                    color: Color(0xFFD2E3FF),
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.toNamed('/register'),
                                child: const Text(
                                  "Register",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCapsuleInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;

  const _AnimatedCapsuleInput({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  State<_AnimatedCapsuleInput> createState() => _AnimatedCapsuleInputState();
}

class _AnimatedCapsuleInputState extends State<_AnimatedCapsuleInput> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0056FF);

    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: _isFocused ? Colors.white : const Color(0xFFF1F5F9),
          border: Border.all(
            color: _isFocused ? primaryColor : Colors.transparent,
            width: 1.8,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),

        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            // Animasi membesar/mengecil pada ikon sisi kiri
            prefixIcon: AnimatedScale(
              scale: _isFocused ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.prefixIcon,
                color: _isFocused ? primaryColor : Colors.grey.shade600,
                size: 22,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            border: InputBorder
                .none, // Dimatikan karena diganti peran oleh AnimatedContainer di atas
          ),
        ),
      ),
    );
  }
}

class HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.82);

    var firstControlPoint = Offset(size.width * 0.29, size.height * 0.92);
    var firstEndPoint = Offset(size.width * 0.54, size.height * 0.86);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.79, size.height * 0.80);
    var secondEndPoint = Offset(size.width, size.height * 0.89);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
