import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';

class SignupScreen extends StatefulWidget {
  final String? email;

  const SignupScreen({Key? key, this.email}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idCardController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      emailController.text = widget.email!;
    }
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF008B8B),
      body: Stack(
        children: [
          // Background - sharp cut teal upper 50%, black lower 50%
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF008B8B),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          // Enhanced image with full coverage - outside SafeArea
          Positioned(
            top: 3.h,
            right: 0,
            left: 0,
            child: Container(
              height: 80.h,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(15),
                ),
                child: Image.asset(
                  'assets/images/n.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                // Back button
                Positioned(
                  top: 4.w,
                  left: 4.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Title outside container
                Positioned(
                  left: 6.w,
                  top: 25.h,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Sign up',
                      style: GoogleFonts.poppins(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main content with glassmorphism container
                Positioned(
                  left: 4.w,
                  right: 4.w,
                  top: 35.h,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 8),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 1.h),

                          // Subtitle text
                          Text(
                            'Looks like you don\'t have an account.\nLet\'s create a new account for',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                          Text(
                            emailController.text.isNotEmpty ? emailController.text : 'jane.doe@gmail.com',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: const Color(0xFF20B2AA),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // First Name and Last Name Row
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF20B2AA).withOpacity(0.2),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: firstNameController,
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'First Name',
                                      hintStyle: GoogleFonts.inter(
                                        color: Colors.grey[500],
                                        fontSize: 10.sp,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                        vertical: 1.8.h,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: const Color(0xFF20B2AA),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF20B2AA).withOpacity(0.2),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: lastNameController,
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Last Name',
                                      hintStyle: GoogleFonts.inter(
                                        color: Colors.grey[500],
                                        fontSize: 10.sp,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                        vertical: 1.8.h,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: const Color(0xFF20B2AA),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.5.h),

                          // Phone Input
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF20B2AA).withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Phone Number',
                                hintStyle: GoogleFonts.inter(
                                  color: Colors.grey[500],
                                  fontSize: 10.sp,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                  vertical: 1.8.h,
                                ),
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  color: const Color(0xFF20B2AA),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 1.5.h),

                          // ID Card Input
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF20B2AA).withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: idCardController,
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'ID Card Number',
                                hintStyle: GoogleFonts.inter(
                                  color: Colors.grey[500],
                                  fontSize: 10.sp,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                  vertical: 1.8.h,
                                ),
                                prefixIcon: Icon(
                                  Icons.credit_card_outlined,
                                  color: const Color(0xFF20B2AA),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 1.5.h),

                          // Password Input
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF20B2AA).withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: passwordController,
                              obscureText: !isPasswordVisible,
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: GoogleFonts.inter(
                                  color: Colors.grey[500],
                                  fontSize: 10.sp,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                  vertical: 1.8.h,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: const Color(0xFF20B2AA),
                                  size: 22,
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 4.w),
                                    child: Center(
                                      widthFactor: 0.0,
                                      child: Text(
                                        'View',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.sp,
                                          color: const Color(0xFF20B2AA),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // Terms and Privacy text
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'By selecting Agree and continue below,\nI agree to ',
                                ),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF20B2AA),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF20B2AA),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // Agree and Continue Button
                          Container(
                            width: double.infinity,
                            height: 6.5.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF008B8B),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF008B8B).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleSignup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Agree and continue',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(height: 2.h),

                          // Login Link
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/login'),
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    color: Colors.grey[400],
                                  ),
                                  children: [
                                    const TextSpan(text: "Already have an account? "),
                                    TextSpan(
                                      text: "Log in",
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF20B2AA),
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                        ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignup() async {
    if (firstNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your first name');
      return;
    }

    if (lastNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your last name');
      return;
    }

    if (emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter your email address');
      return;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      _showSnackBar('Please enter a valid email address');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      _showSnackBar('Please enter your phone number');
      return;
    }

    if (idCardController.text.trim().isEmpty) {
      _showSnackBar('Please enter your ID card number');
      return;
    }

    if (passwordController.text.trim().length < 6) {
      _showSnackBar('Password must be at least 6 characters');
      return;
    }

    setState(() => isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() => isLoading = false);

    // Navigate to login screen with user data
    Navigator.pushReplacementNamed(context, '/login', arguments: {
      'email': emailController.text.trim(),
      'name': '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
      'userData': {
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'idCardNumber': idCardController.text.trim(),
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    idCardController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}