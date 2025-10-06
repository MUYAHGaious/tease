import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../theme/adaptive_theme_manager.dart';

const Color primaryColor = Color(0xFF008B8B);

class RoleSelectionScreen extends StatefulWidget {
  final String selectedAgency;

  const RoleSelectionScreen({Key? key, required this.selectedAgency})
      : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _buttonController;
  late AnimationController _typewriterController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<int> _typewriterAnimation;

  String? _selectedRole;
  String _currentText = 'What is your role?';
  bool _isLoading = false;
  bool _isDarkMode = false;
  late AdaptiveThemeManager _themeManager;

  final Map<String, List<Map<String, dynamic>>> _roleOptions = {
    'moghamo': [
      {
        'id': 'booking_clerk',
        'title': 'Booking Clerk',
        'icon': Icons.receipt_long
      },
      {
        'id': 'schedule_manager',
        'title': 'Schedule Manager',
        'icon': Icons.schedule
      },
      {'id': 'bus_conductor', 'title': 'Bus Conductor', 'icon': Icons.people},
      {'id': 'bus_driver', 'title': 'Bus Driver', 'icon': Icons.directions_bus},
    ],
    'amour_mezam': [
      {
        'id': 'booking_clerk',
        'title': 'Booking Clerk',
        'icon': Icons.receipt_long
      },
      {
        'id': 'schedule_manager',
        'title': 'Schedule Manager',
        'icon': Icons.schedule
      },
      {'id': 'bus_conductor', 'title': 'Bus Conductor', 'icon': Icons.people},
      {'id': 'bus_driver', 'title': 'Bus Driver', 'icon': Icons.directions_bus},
    ],
    'vatican': [
      {
        'id': 'booking_clerk',
        'title': 'Booking Clerk',
        'icon': Icons.receipt_long
      },
      {
        'id': 'schedule_manager',
        'title': 'Schedule Manager',
        'icon': Icons.schedule
      },
      {'id': 'bus_conductor', 'title': 'Bus Conductor', 'icon': Icons.people},
      {'id': 'bus_driver', 'title': 'Bus Driver', 'icon': Icons.directions_bus},
    ],
  };

  List<Map<String, dynamic>> _currentStepOptions = [];

  @override
  void initState() {
    super.initState();
    _themeManager = AdaptiveThemeManager();
    _loadThemePreference();
    _initializeAnimations();
    _currentStepOptions = _roleOptions[widget.selectedAgency] ?? [];
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _typewriterController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(_slideController);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    _buttonFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_buttonController);

    _typewriterAnimation = IntTween(
      begin: 0,
      end: _currentText.length,
    ).animate(_typewriterController);

    // Start typewriter animation first
    _typewriterController.forward();

    Future.delayed(const Duration(milliseconds: 400), () {
      _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _buttonController.dispose();
    _typewriterController.dispose();
    super.dispose();
  }

  void _handleRoleSelection(String roleId) {
    setState(() {
      _selectedRole = roleId;
    });

    HapticFeedback.selectionClick();
    _buttonController.forward();
  }

  void _proceedToNextStep() async {
    if (_isLoading) return;

    HapticFeedback.mediumImpact();

    if (_selectedRole != null) {
      setState(() {
        _isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_affiliation', 'agency');
      await prefs.setString('user_agency', widget.selectedAgency);
      await prefs.setString('user_role', _selectedRole!);

      setState(() {
        _isLoading = false;
      });

      Navigator.pushNamedAndRemoveUntil(
          context, '/home-dashboard', (route) => false);
    }
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _saveThemePreference();
  }

  ThemeData get _darkTheme => AppTheme.darkTheme;
  ThemeData get _lightTheme => AppTheme.lightTheme;

  Color _appBarIconColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  Color _textColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  Color _buttonBackgroundColor(BuildContext context) => _isDarkMode
      ? Theme.of(context).colorScheme.surface.withOpacity(0.95)
      : Theme.of(context).colorScheme.primary;
  Color _buttonTextColor(BuildContext context) => _isDarkMode
      ? Theme.of(context).colorScheme.primary
      : Theme.of(context).colorScheme.onPrimary;

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      data: _isDarkMode ? _darkTheme : _lightTheme,
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.arrow_back,
                  key: ValueKey(_isDarkMode),
                  color: _appBarIconColor(context),
                  size: 6.w,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              style: TextStyle(
                color: _textColor(context),
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
              child: Text('Select Your Role'),
            ),
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5).animate(
                          CurvedAnimation(
                              parent: animation, curve: Curves.easeInOutCubic)),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    key: ValueKey(_isDarkMode),
                    color: _appBarIconColor(context),
                    size: 6.w,
                  ),
                ),
                onPressed: _toggleTheme,
              ),
            ],
            centerTitle: true,
          ),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      AnimatedBuilder(
                        animation: _typewriterAnimation,
                        builder: (context, child) {
                          final currentText = _currentText.substring(
                              0, _typewriterAnimation.value);
                          return RepaintBoundary(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOutCubic,
                              style: TextStyle(
                                color: _textColor(context),
                                fontSize: 42.sp, // Same as first slide
                                fontWeight: FontWeight.w800,
                              ),
                              child: Text(currentText),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Select your role at the agency.',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.8),
                          fontSize: 14.sp,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 2.w,
                          mainAxisSpacing: 1.h,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: _currentStepOptions.length,
                        itemBuilder: (context, index) {
                          final option = _currentStepOptions[index];
                          final isSelected = _selectedRole == option['id'];
                          return _buildRoleCard(option, isSelected);
                        },
                      ),
                      SizedBox(height: 3.h),
                      AnimatedBuilder(
                        animation: _buttonFadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _buttonFadeAnimation.value,
                            child: Transform.translate(
                              offset: Offset(
                                  0, 20 * (1 - _buttonFadeAnimation.value)),
                              child: Container(
                                height: 6.h,
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(horizontal: 2.w),
                                child: ElevatedButton(
                                  onPressed: _selectedRole != null
                                      ? _proceedToNextStep
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _buttonBackgroundColor(context),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        )
                                      : Text(
                                          'Continue',
                                          style: TextStyle(
                                            color: _buttonTextColor(context),
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> option, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.white.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleRoleSelection(option['id']),
          borderRadius: BorderRadius.circular(16),
          splashColor: primaryColor.withOpacity(0.2),
          highlightColor: primaryColor.withOpacity(0.1),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.white.withOpacity(0.2),
                  shape: const CircleBorder(),
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      option['icon'],
                      color: Colors.white,
                      size: 5.w,
                    ),
                  ),
                ),
                SizedBox(height: 0.8.h),
                Flexible(
                  child: Text(
                    option['title'],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(height: 0.5.h),
                  Container(
                    width: 4.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: primaryColor,
                      size: 2.5.w,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
