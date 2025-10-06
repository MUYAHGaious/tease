import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';

class MultiStepSignupScreen extends StatefulWidget {
  final String? email;

  const MultiStepSignupScreen({Key? key, this.email}) : super(key: key);

  @override
  State<MultiStepSignupScreen> createState() => _MultiStepSignupScreenState();
}

class _MultiStepSignupScreenState extends State<MultiStepSignupScreen>
    with TickerProviderStateMixin {
  // Current step tracking
  int currentStep = 0;

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idCardController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  // Form state
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool agreeToTerms = false;
  bool agreeToPrivacy = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form keys for validation
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      emailController.text = widget.email!;
    }

    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
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

                // Step indicator and title
                Positioned(
                  left: 6.w,
                  top: 20.h,
                  right: 6.w,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 1.w),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: index <= currentStep
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.3),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: index < currentStep
                                        ? Icon(
                                            Icons.check,
                                            color: const Color(0xFF008B8B),
                                            size: 4.w,
                                          )
                                        : Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: GoogleFonts.inter(
                                                color: index <= currentStep
                                                    ? const Color(0xFF008B8B)
                                                    : Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                  ),
                                  if (index < 2)
                                    Container(
                                      width: 15.w,
                                      height: 2,
                                      color: index < currentStep
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.3),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 3.h),

                        // Title
                        Text(
                          _getStepTitle(),
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
                      ],
                    ),
                  ),
                ),

                // Main content with glassmorphism container
                Positioned(
                  left: 4.w,
                  right: 4.w,
                  top: 43.h,
                  child: SlideTransition(
                    position: _slideAnimation,
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
                            child: _buildCurrentStepContent(),
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

  String _getStepTitle() {
    switch (currentStep) {
      case 0:
        return 'Personal\nInfo';
      case 1:
        return 'Contact\nDetails';
      case 2:
        return 'Account\nSetup';
      default:
        return 'Sign Up';
    }
  }

  Widget _buildCurrentStepContent() {
    return Form(
      key: _formKeys[currentStep],
      child: Column(
        children: [
          _buildStepContent(),
          SizedBox(height: 3.h),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildStep1(); // Name, Email, Password
      case 1:
        return _buildStep2(); // Phone, ID Card
      case 2:
        return _buildStep3(); // Username, Terms
      default:
        return Container();
    }
  }

  // Step 1: Personal Information
  Widget _buildStep1() {
    return Column(
      children: [
        // First Name and Last Name Row
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: firstNameController,
                hintText: 'First Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildTextField(
                controller: lastNameController,
                hintText: 'Last Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),

        // Email Input
        _buildTextField(
          controller: emailController,
          hintText: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Email is required';
            }
            if (!_isValidEmail(value!)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),

        // Password Input
        _buildTextField(
          controller: passwordController,
          hintText: 'Password',
          icon: Icons.lock_outline,
          obscureText: !isPasswordVisible,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Password is required';
            }
            if (value!.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
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
                  isPasswordVisible ? 'Hide' : 'Show',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: const Color(0xFF008B8B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Step 2: Contact Details
  Widget _buildStep2() {
    return Column(
      children: [
        // Phone Input
        _buildTextField(
          controller: phoneController,
          hintText: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Phone number is required';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),

        // ID Card Input
        _buildTextField(
          controller: idCardController,
          hintText: 'ID Card Number',
          icon: Icons.credit_card_outlined,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'ID card number is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Step 3: Account Setup
  Widget _buildStep3() {
    return Column(
      children: [
        // Username Input
        _buildTextField(
          controller: usernameController,
          hintText: 'Username (How you want to be called)',
          icon: Icons.alternate_email_outlined,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Username is required';
            }
            if (value!.length < 3) {
              return 'Username must be at least 3 characters';
            }
            return null;
          },
        ),
        SizedBox(height: 3.h),

        // Terms and Privacy Checkboxes
        _buildCheckbox(
          value: agreeToTerms,
          onChanged: (value) {
            setState(() {
              agreeToTerms = value ?? false;
            });
          },
          text: 'I agree to the Terms of Service',
        ),
        SizedBox(height: 1.h),

        _buildCheckbox(
          value: agreeToPrivacy,
          onChanged: (value) {
            setState(() {
              agreeToPrivacy = value ?? false;
            });
          },
          text: 'I agree to the Privacy Policy',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 5.w,
            vertical: 1.8.h,
          ),
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required void Function(bool?) onChanged,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 5.w,
          height: 5.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: value ? const Color(0xFF008B8B) : Colors.white.withOpacity(0.5),
              width: 2,
            ),
            color: value ? const Color(0xFF008B8B) : Colors.transparent,
          ),
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.transparent,
            checkColor: Colors.white,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        // Continue/Next Button
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
            onPressed: isLoading ? null : _handleContinue,
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
                    currentStep == 2 ? 'Create Account' : 'Continue',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),

        if (currentStep > 0) ...[
          SizedBox(height: 2.h),
          // Back Button
          GestureDetector(
            onTap: _handleBack,
            child: Text(
              'Back',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],

        SizedBox(height: 2.h),

        // Login Link
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: Colors.white.withOpacity(0.7),
                ),
                children: [
                  const TextSpan(text: "Already have an account? "),
                  TextSpan(
                    text: "Log in",
                    style: GoogleFonts.inter(
                      color: Colors.white,
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
    );
  }

  void _handleContinue() async {
    if (!_formKeys[currentStep].currentState!.validate()) {
      return;
    }

    if (currentStep == 2) {
      // Final step validation
      if (!agreeToTerms || !agreeToPrivacy) {
        _showSnackBar('Please agree to Terms of Service and Privacy Policy');
        return;
      }

      // Handle signup
      await _handleSignup();
    } else {
      // Move to next step
      _animateToNextStep();
    }
  }

  void _handleBack() {
    if (currentStep > 0) {
      _animateToPreviousStep();
    }
  }

  void _animateToNextStep() {
    _slideController.reset();
    setState(() {
      currentStep++;
    });
    _slideController.forward();
  }

  void _animateToPreviousStep() {
    _slideController.reset();
    setState(() {
      currentStep--;
    });
    _slideController.forward();
  }

  Future<void> _handleSignup() async {
    setState(() => isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 2000));

    setState(() => isLoading = false);

    // Navigate to login screen with user data
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login', arguments: {
        'email': emailController.text.trim(),
        'name': '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
        'userData': {
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
          'username': usernameController.text.trim(),
          'phone': phoneController.text.trim(),
          'idCardNumber': idCardController.text.trim(),
        }
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    idCardController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }
}