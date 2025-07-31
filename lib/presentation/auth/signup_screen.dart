import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../splash_screen/widgets/animated_background_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Focus nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  String _selectedRole = '';

  final List<Map<String, dynamic>> _roles = [
    {
      'id': 'user',
      'title': 'Passenger',
      'subtitle': 'Book and manage bus tickets',
      'icon': Icons.person,
      'color': Color(0xFF1a4d3a),
    },
    {
      'id': 'motorboy',
      'title': 'Motor Boy',
      'subtitle': 'Assist with luggage and boarding',
      'icon': Icons.luggage,
      'color': Color(0xFF2d5a3d),
    },
    {
      'id': 'driver',
      'title': 'Driver',
      'subtitle': 'Drive buses and manage routes',
      'icon': Icons.directions_bus,
      'color': Color(0xFF4a7c59),
    },
    {
      'id': 'admin',
      'title': 'Administrator',
      'subtitle': 'Manage system and operations',
      'icon': Icons.admin_panel_settings,
      'color': Color(0xFF0d2921),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  Future<void> _handleSignup() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Account created successfully!');
      Navigator.pushReplacementNamed(context, '/home-dashboard');
    }
  }

  bool _validateForm() {
    if (_selectedRole.isEmpty) {
      _showSnackBar('Please select a role', isError: true);
      return false;
    }

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', isError: true);
      return false;
    }

    if (!_agreeToTerms) {
      _showSnackBar('Please agree to the terms and conditions', isError: true);
      return false;
    }

    return true;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Colors.red[600] 
            : const Color(0xFF1a4d3a),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.how_to_reg,
                  color: Colors.white,
                  size: 8.w,
                ),
              ),
              SizedBox(height: 3.h),
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.8),
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  'Choose Your Role',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Select how you\'ll use our platform',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 6.h),
        
        // Role cards
        Expanded(
          child: ListView.builder(
            itemCount: _roles.length,
            itemBuilder: (context, index) {
              final role = _roles[index];
              final isSelected = _selectedRole == role['id'];
              
              return Container(
                margin: EdgeInsets.only(bottom: 3.h),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRole = role['id'];
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isSelected
                            ? [
                                Colors.white.withValues(alpha: 0.2),
                                Colors.white.withValues(alpha: 0.1),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.05),
                                Colors.white.withValues(alpha: 0.02),
                              ],
                      ),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 15.w,
                          height: 15.w,
                          decoration: BoxDecoration(
                            color: (role['color'] as Color).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            role['icon'],
                            color: Colors.white,
                            size: 7.w,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role['title'],
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                role['subtitle'],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: const Color(0xFF1a4d3a),
                                  size: 4.w,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Continue button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedRole.isNotEmpty ? _nextPage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1a4d3a),
              padding: EdgeInsets.symmetric(vertical: 2.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: isPassword && 
                  (controller == _passwordController ? !_isPasswordVisible : !_isConfirmPasswordVisible),
              keyboardType: keyboardType,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 6.w,
                ),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          controller == _passwordController
                              ? (_isPasswordVisible ? Icons.visibility_off : Icons.visibility)
                              : (_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 6.w,
                        ),
                        onPressed: () {
                          setState(() {
                            if (controller == _passwordController) {
                              _isPasswordVisible = !_isPasswordVisible;
                            } else {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            }
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        GestureDetector(
          onTap: _previousPage,
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 6.w,
            ),
          ),
        ),
        
        SizedBox(height: 4.h),
        
        Center(
          child: Column(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person_add,
                  color: Colors.white,
                  size: 8.w,
                ),
              ),
              SizedBox(height: 3.h),
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.8),
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Join us as ${_roles.firstWhere((r) => r['id'] == _selectedRole)['title']}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 4.h),
        
        // Signup form
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildInputField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    icon: Icons.person_outline,
                  ),
                  
                  _buildInputField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    label: 'Email Address',
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  _buildInputField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  
                  _buildInputField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    label: 'Password',
                    hint: 'Enter your password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  
                  _buildInputField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  
                  // Terms checkbox
                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                          fillColor: WidgetStateProperty.all(
                            Colors.white.withValues(alpha: 0.2),
                          ),
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'I agree to the Terms of Service and Privacy Policy',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Signup button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1a4d3a),
                        padding: EdgeInsets.symmetric(vertical: 2.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 6.w,
                              width: 6.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFF1a4d3a),
                                ),
                              ),
                            )
                          : Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background matching splash screen
          const AnimatedBackgroundWidget(),
          
          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      SizedBox(height: 4.h),
                      
                      // Page indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(2, (index) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 1.w),
                            width: _currentPage == index ? 8.w : 2.w,
                            height: 1.h,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(1.h),
                            ),
                          );
                        }),
                      ),
                      
                      SizedBox(height: 2.h),
                      
                      // Page view
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildRoleSelection(),
                            _buildSignupForm(),
                          ],
                        ),
                      ),
                      
                      // Sign in link
                      if (_currentPage == 0)
                        Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Already have an account? ",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 14.sp,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Sign In',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
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
        ],
      ),
    );
  }
}