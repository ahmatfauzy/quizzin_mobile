import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzin/app/modules/register/controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0056FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: ClipPath(
              clipper: RegisterHeaderWaveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.38,
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
                            )
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logos/logoblue.png',
                          width: 55, height: 55,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, size: 45, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Create Account",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Enter your details to start your learning journey",
                        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.80)),
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.33),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // PERBAIKAN: Input Nama Lengkap Beranimasi
                          _AnimatedCapsuleInput(
                            controller: controller.nameController,
                            hintText: "Full Name",
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 16),

                          // PERBAIKAN: Input Email Beranimasi
                          _AnimatedCapsuleInput(
                            controller: controller.emailController,
                            hintText: "Email Address",
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // PERBAIKAN: Input Password Beranimasi
                          _AnimatedCapsuleInput(
                            controller: controller.passwordController,
                            hintText: "Password",
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                          ),
                          const SizedBox(height: 32),

                          // TOMBOL REGISTER / SIGN UP UTAMA
                          SizedBox(
                            height: 52,
                            child: Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value ? null : controller.register,
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
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            )),
                          ),
                          const SizedBox(height: 32),

                          // FOOTER NAVIGASI
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account? ", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: const Text(
                                  "Log in",
                                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
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
                  )
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
            prefixIcon: AnimatedScale(
              scale: _isFocused ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.prefixIcon,
                color: _isFocused ? primaryColor : Colors.grey.shade600,
                size: 22,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class RegisterHeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.82);

    var firstControlPoint = Offset(size.width * 0.29, size.height * 0.92);
    var firstEndPoint = Offset(size.width * 0.54, size.height * 0.86);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * 0.79, size.height * 0.80);
    var secondEndPoint = Offset(size.width, size.height * 0.89);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}