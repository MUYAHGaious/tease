import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';

class EnhancedSignupScreen extends StatefulWidget {
  const EnhancedSignupScreen({super.key});

  @override
  State<EnhancedSignupScreen> createState() => _EnhancedSignupScreenState();
}

class _EnhancedSignupScreenState extends State<EnhancedSignupScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _idCardFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  // Field error states
  String _nameError = '';
  String _emailError = '';
  String _phoneError = '';
  String _idCardError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  // Password strength animation states
  List<bool> _passwordRequirements = [false, false, false, false];

  // Focus states
  bool _isNameFocused = false;
  bool _isEmailFocused = false;
  bool _isPhoneFocused = false;
  bool _isIdCardFocused = false;
  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;

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
    _nameFocus.addListener(() {
      setState(() {
        _isNameFocused = _nameFocus.hasFocus;
      });
    });
    _emailFocus.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocus.hasFocus;
      });
    });
    _phoneFocus.addListener(() {
      setState(() {
        _isPhoneFocused = _phoneFocus.hasFocus;
      });
    });
    _idCardFocus.addListener(() {
      setState(() {
        _isIdCardFocused = _idCardFocus.hasFocus;
      });
    });
    _passwordFocus.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocus.hasFocus;
      });
    });
    _confirmPasswordFocus.addListener(() {
      setState(() {
        _isConfirmPasswordFocused = _confirmPasswordFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _idCardController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _idCardFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_validateAllFields()) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    // Simulate registration for frontend demo
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _showSuccessSnackBar('Registration successful! (Demo)');
      // Navigate to demo screen instead of real login
      Navigator.pushReplacementNamed(context, '/auth-demo');
    }
  }

  bool _validateAllFields() {
    bool isValid = true;

    setState(() {
      _nameError = '';
      _emailError = '';
      _phoneError = '';
      c _idCardError = '';
      _passwordError = '';
      _confirmPasswordError = '';
    });

    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = 'Full name is required';
      });
      isValid = false;
    } else if (_nameController.text.trim().split(' ').length < 2) {
      setState(() {
        _nameError = 'Please enter your first and last name';
      });
      isValid = false;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      isValid = false;
    } else if (!_isValidEmail(_emailController.text.trim())) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      isValid = false;
    }

    if (_phoneController.text.trim().isEmpty) {
      setState(() {
        _phoneError = 'Phone number is required';
      });
      isValid = false;
    } else if (!_isValidPhone(_phoneController.text.trim())) {
      setState(() {
        _phoneError = 'Please enter a valid phone number';
      });
      isValid = false;
    }

    if (_idCardController.text.trim().isEmpty) {
      setState(() {
        _idCardError = 'ID card number is required';
      });
      isValid = false;
    } else if (!_isValidIdCard(_idCardController.text.trim())) {
      setState(() {
        _idCardError = 'ID card must be exactly 9 digits';
      });
      isValid = false;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      isValid = false;
    } else if (_passwordController.text.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters';
      });
      isValid = false;
    }

    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Please confirm your password';
      });
      isValid = false;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      isValid = false;
    }

    if (!_agreeToTerms) {
      _showErrorSnackBar('Please agree to the terms and conditions');
      isValid = false;
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanPhone.startsWith('237')) {
      return RegExp(r'^237[678][0-9]{8}$').hasMatch(cleanPhone);
    } else if (cleanPhone.startsWith('6') ||
        cleanPhone.startsWith('7') ||
        cleanPhone.startsWith('8')) {
      return RegExp(r'^[678][0-9]{8}$').hasMatch(cleanPhone);
    }
    return false;
  }

  bool _isValidIdCard(String idCard) {
    return RegExp(r'^[0-9]{9}$').hasMatch(idCard.trim());
  }

  String _formatPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanPhone.startsWith('6') ||
        cleanPhone.startsWith('7') ||
        cleanPhone.startsWith('8')) {
      return '237$cleanPhone';
    }
    return cleanPhone;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 4),
      ),
    );
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

                          // Form fields
                          _buildForm(),

                          SizedBox(height: 4.h),

                          // Sign up button
                          _buildSignupButton(),

                          SizedBox(height: 3.h),

                          // Login link
                          _buildLoginLink(),

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
          'Sign up',
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

  Widget _buildForm() {
    return Column(
      children: [
        // Introductory text
        Text(
          'Looks like you don\'t have an account. Let\'s create a new account for you.',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),

        SizedBox(height: 4.h),

        // Form fields
        _buildInputField(
          controller: _nameController,
          focusNode: _nameFocus,
          label: 'Name',
          hint: 'Enter your full name',
          icon: Icons.person_outline,
          isFocused: _isNameFocused,
          error: _nameError,
          onChanged: (value) {
            setState(() {
              if (value.trim().isEmpty) {
                _nameError = '';
              } else if (value.trim().split(' ').length < 2) {
                _nameError = 'Please enter first and last name';
              } else {
                _nameError = '';
              }
            });
          },
        ),

        SizedBox(height: 2.h),

        _buildInputField(
          controller: _emailController,
          focusNode: _emailFocus,
          label: 'Email',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          isFocused: _isEmailFocused,
          error: _emailError,
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
        ),

        SizedBox(height: 2.h),

        _buildInputField(
          controller: _phoneController,
          focusNode: _phoneFocus,
          label: 'Phone',
          hint: 'Enter your phone number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          isFocused: _isPhoneFocused,
          error: _phoneError,
          onChanged: (value) {
            setState(() {
              if (value.trim().isEmpty) {
                _phoneError = '';
              } else if (!_isValidPhone(value.trim())) {
                _phoneError = 'Please enter a valid phone number';
              } else {
                _phoneError = '';
              }
            });
          },
        ),

        SizedBox(height: 2.h),

        _buildInputField(
          controller: _idCardController,
          focusNode: _idCardFocus,
          label: 'ID Card Number',
          hint: 'Enter your ID card number',
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
          isFocused: _isIdCardFocused,
          error: _idCardError,
          onChanged: (value) {
            setState(() {
              if (value.trim().isEmpty) {
                _idCardError = '';
              } else if (!_isValidIdCard(value.trim())) {
                _idCardError = 'Must be exactly 9 digits';
              } else {
                _idCardError = '';
              }
            });
          },
        ),

        SizedBox(height: 2.h),

        _buildPasswordField(),

        SizedBox(height: 2.h),

        _buildInputField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocus,
          label: 'Confirm Password',
          hint: 'Confirm your password',
          icon: Icons.lock_outline,
          isPassword: true,
          isPasswordVisible: _isConfirmPasswordVisible,
          isFocused: _isConfirmPasswordFocused,
          error: _confirmPasswordError,
          onTogglePasswordVisibility: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                _confirmPasswordError = '';
              } else if (_passwordController.text != value) {
                _confirmPasswordError = 'Passwords do not match';
              } else {
                _confirmPasswordError = '';
              }
            });
          },
        ),

        SizedBox(height: 3.h),

        // Terms and conditions
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                  HapticFeedback.lightImpact();
                },
                fillColor: WidgetStateProperty.all(
                  _agreeToTerms ? AppTheme.primaryLight : Colors.transparent,
                ),
                checkColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'By selecting Agree and continue below, I agree to ',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms of Service and Privacy Policy',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
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
              color: _passwordError.isNotEmpty
                  ? AppTheme.errorLight
                  : _isPasswordFocused
                      ? AppTheme.primaryLight
                      : Colors.white.withValues(alpha: 0.3),
              width: _isPasswordFocused ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: !_isPasswordVisible,
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
            onChanged: (value) {
              setState(() {
                _passwordRequirements[0] = value.length >= 8;
                _passwordRequirements[1] = value.contains(RegExp(r'[A-Z]'));
                _passwordRequirements[2] = value.contains(RegExp(r'[a-z]'));
                _passwordRequirements[3] = value.contains(RegExp(r'[0-9]'));

                if (value.isEmpty) {
                  _passwordError = '';
                } else if (value.length < 8) {
                  _passwordError = 'Password must be at least 8 characters';
                } else if (!_passwordRequirements.every((req) => req)) {
                  _passwordError =
                      'Password must include uppercase, lowercase, and number';
                } else {
                  _passwordError = '';
                }
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: GoogleFonts.inter(
                color: Colors.grey.shade400,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: _isPasswordFocused
                    ? AppTheme.primaryLight
                    : Colors.grey.shade500,
                size: 5.w,
              ),
              suffixIcon: IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    key: ValueKey(_isPasswordVisible),
                    color: _isPasswordFocused
                        ? AppTheme.primaryLight
                        : Colors.grey.shade500,
                    size: 5.w,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                  HapticFeedback.lightImpact();
                },
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

        // Password strength indicators
        if (_isPasswordFocused || _passwordController.text.isNotEmpty) ...[
          SizedBox(height: 1.h),
          ...List.generate(4, (index) {
            final requirements = [
              '8+ characters',
              'Uppercase letter',
              'Lowercase letter',
              'Number'
            ];
            final isValid = _passwordRequirements[index];
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 50)),
              margin: EdgeInsets.only(bottom: 0.5.h),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200 + (index * 50)),
                    width: 4.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isValid
                          ? AppTheme.successLight
                          : Colors.grey.shade300,
                    ),
                    child: isValid
                        ? Icon(Icons.check, size: 2.5.w, color: Colors.white)
                        : Icon(Icons.circle_outlined,
                            size: 2.5.w, color: Colors.grey.shade500),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    requirements[index],
                    style: GoogleFonts.inter(
                      color: isValid
                          ? AppTheme.successLight
                          : Colors.white.withValues(alpha: 0.7),
                      fontSize: 11.sp,
                      fontWeight: isValid ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        // Error message
        if (_passwordError.isNotEmpty) ...[
          SizedBox(height: 0.5.h),
          Padding(
            padding: EdgeInsets.only(left: 1.w),
            child: Text(
              _passwordError,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onTogglePasswordVisibility,
    TextInputType keyboardType = TextInputType.text,
    required bool isFocused,
    required String error,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
              color: error.isNotEmpty
                  ? AppTheme.errorLight
                  : isFocused
                      ? AppTheme.primaryLight
                      : Colors.white.withValues(alpha: 0.3),
              width: isFocused ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: isPassword && !(isPasswordVisible ?? false),
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                color: Colors.grey.shade400,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                icon,
                color: isFocused ? AppTheme.primaryLight : Colors.grey.shade500,
                size: 5.w,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isPasswordVisible ?? false
                              ? Icons.visibility_off
                              : Icons.visibility,
                          key: ValueKey(isPasswordVisible),
                          color: isFocused
                              ? AppTheme.primaryLight
                              : Colors.grey.shade500,
                          size: 5.w,
                        ),
                      ),
                      onPressed: onTogglePasswordVisibility,
                    )
                  : null,
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
        if (error.isNotEmpty) ...[
          SizedBox(height: 0.5.h),
          Padding(
            padding: EdgeInsets.only(left: 1.w),
            child: Text(
              error,
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

  Widget _buildSignupButton() {
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
          onPressed: _isLoading ? null : _handleSignup,
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
                  'Agree and continue',
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

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pushReplacementNamed(context, '/login');
        },
        child: RichText(
          text: TextSpan(
            text: 'Already have an account? ',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
            children: [
              TextSpan(
                text: 'Sign In',
                style: GoogleFonts.inter(
                  color: AppTheme.primaryLight,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
