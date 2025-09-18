import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';

class HiScreen extends StatefulWidget {
  const HiScreen({super.key});

  @override
  State<HiScreen> createState() => _HiScreenState();
}

class _HiScreenState extends State<HiScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();

  bool _isEmailFocused = false;
  bool _isLoading = false;
  String _emailError = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _setupFocusListeners();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  void _setupFocusListeners() {
    _emailFocus.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_validateEmail()) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    // Simulate API call to check if user exists
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Navigate to appropriate screen based on user existence
      // For now, let's assume user doesn't exist and go to signup
      Navigator.pushReplacementNamed(context, '/signup');
    }
  }

  bool _validateEmail() {
    setState(() {
      _emailError = '';
    });

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      return false;
    } else if (!_isValidEmail(_emailController.text.trim())) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Hero image section (top half)
          _buildHeroSection(),

          // Main content (bottom half)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.h),

                          // Header with back button
                          _buildHeader(),

                          SizedBox(height: 3.h),

                          // Email field
                          _buildEmailField(),

                          SizedBox(height: 4.h),

                          // Continue button
                          _buildContinueButton(),

                          SizedBox(height: 3.h),

                          // Separator
                          _buildSeparator(),

                          SizedBox(height: 3.h),

                          // Social login buttons
                          _buildSocialButtons(),

                          SizedBox(height: 4.h),

                          // Sign up and forgot password links
                          _buildLinks(),

                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: AssetImage(
              'assets/images/NOBG-pexels-homie-visuals-2149299387-30534451.png'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 5.w,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          'Hi!',
          style: GoogleFonts.inter(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        SizedBox(height: 1.h),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            border: Border.all(
              color: _emailError.isNotEmpty
                  ? AppTheme.errorLight
                  : _isEmailFocused
                      ? AppTheme.primaryLight
                      : Colors.white.withValues(alpha: 0.3),
              width: _isEmailFocused ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
            onChanged: (value) {
              setState(() {
                if (value.trim().isEmpty) {
                  _emailError = '';
                } else if (!_isValidEmail(value.trim())) {
                  _emailError = 'Please enter a valid email';
                } else {
                  _emailError = '';
                }
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: GoogleFonts.inter(
                color: Colors.grey.shade400,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: _isEmailFocused
                    ? AppTheme.primaryLight
                    : Colors.grey.shade500,
                size: 5.w,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.5.h,
              ),
            ),
            onTap: () {
              HapticFeedback.selectionClick();
            },
          ),
        ),

        // Error message
        if (_emailError.isNotEmpty) ...[
          SizedBox(height: 0.5.h),
          Padding(
            padding: EdgeInsets.only(left: 1.w),
            child: Text(
              _emailError,
              style: GoogleFonts.inter(
                color: AppTheme.errorLight,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryLight,
              AppTheme.primaryLight.withValues(alpha: 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryLight.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 3.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: _isLoading
              ? SizedBox(
                  height: 6.w,
                  width: 6.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Continue',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Center(
      child: Text(
        'or',
        style: GoogleFonts.inter(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        _buildSocialButton(
          icon: Icons.facebook,
          text: 'Continue with Facebook',
          onTap: () {
            HapticFeedback.lightImpact();
            // Handle Facebook login
          },
        ),
        SizedBox(height: 2.h),
        _buildSocialButton(
          icon: Icons.g_mobiledata,
          text: 'Continue with Google',
          onTap: () {
            HapticFeedback.lightImpact();
            // Handle Google login
          },
        ),
        SizedBox(height: 2.h),
        _buildSocialButton(
          icon: Icons.apple,
          text: 'Continue with Apple',
          onTap: () {
            HapticFeedback.lightImpact();
            // Handle Apple login
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
            padding: EdgeInsets.symmetric(vertical: 2.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 5.w,
                color: Colors.black87,
              ),
              SizedBox(width: 3.w),
              Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinks() {
    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushReplacementNamed(context, '/signup');
            },
            child: RichText(
              text: TextSpan(
                text: 'Don\'t have an account? ',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: 'Sign up',
                    style: GoogleFonts.inter(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Center(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Handle forgot password
            },
            child: Text(
              'Forgot your password?',
              style: GoogleFonts.inter(
                color: AppTheme.primaryLight,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
