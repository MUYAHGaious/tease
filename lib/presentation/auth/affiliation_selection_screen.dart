import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../theme/adaptive_theme_manager.dart';

// 2025 Design Constants
const Color primaryColor = Color(0xFF008B8B);
const double cardBorderRadius = 16.0;

class AffiliationSelectionScreen extends StatefulWidget {
  final String? startAffiliation; // 'ict_university' or 'agency'
  final int? startStep; // 0: affiliation, 1: role, 2: pin

  const AffiliationSelectionScreen({super.key, this.startAffiliation, this.startStep});

  @override
  State<AffiliationSelectionScreen> createState() =>
      _AffiliationSelectionScreenState();
}

class _AffiliationSelectionScreenState extends State<AffiliationSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _buttonController;
  late AnimationController _typewriterController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<int> _typewriterAnimation;

  String? _selectedAffiliation;
  bool _isLoading = false;
  int _currentStep = 0; // 0: affiliation, 1: role, 2: pin, 3: completion
  bool _isDarkMode = false; // Default to light mode
  late AdaptiveThemeManager _themeManager;

  String _currentText = 'Hello User, how can we help you today?';
  String? _selectedRole;
  String _enteredPin = '';
  String? _selectedAgency;

  // Step-specific data
  List<Map<String, dynamic>> _currentStepOptions = [];

  final List<Map<String, dynamic>> _affiliationOptions = [
    {
      'id': 'regular',
      'title': 'None',
      'subtitle': 'Public Transport',
      'icon': Icons.person,
      'color': primaryColor,
    },
    {
      'id': 'ict_university',
      'title': 'ICT University',
      'subtitle': 'Students & Staff',
      'icon': Icons.school,
      'color': primaryColor,
    },
    {
      'id': 'agency',
      'title': 'Transport Agency',
      'subtitle': 'Operators & Drivers',
      'icon': Icons.business,
      'color': primaryColor,
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _roleOptions = {
    'ict_university': [
      {'id': 'student', 'title': 'Student', 'icon': Icons.school},
      {'id': 'staff', 'title': 'Staff', 'icon': Icons.work},
      {'id': 'bus_driver', 'title': 'Bus Driver', 'icon': Icons.directions_bus},
      {
        'id': 'bus_coordinator',
        'title': 'Bus Coordinator',
        'icon': Icons.admin_panel_settings
      },
    ],
    'agency': [
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

  // Agency selection options
  final List<Map<String, dynamic>> _agencyOptions = const [
    {'id': 'moghamo', 'title': 'Moghamo', 'icon': Icons.directions_bus},
    {'id': 'vatican', 'title': 'Vatican', 'icon': Icons.directions_bus},
    {'id': 'amour_mezam', 'title': 'Amour Mezam', 'icon': Icons.directions_bus},
    {'id': 'nso_boyz', 'title': 'NSO Boyz', 'icon': Icons.directions_bus},
    {'id': 'oasis', 'title': 'Oasis', 'icon': Icons.directions_bus},
  ];

  @override
  void initState() {
    super.initState();
    _themeManager = AdaptiveThemeManager();
    _loadThemePreference();
    _initializeAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyStartParamsIfAny();
  }

  bool _didApplyStartParams = false;

  void _applyStartParamsIfAny() {
    if (_didApplyStartParams) return;
    if (widget.startAffiliation != null) {
      _selectedAffiliation = widget.startAffiliation;
      // Prepare role options for the selected affiliation
      _currentStepOptions = _roleOptions[_selectedAffiliation] ?? [];
      _currentStep = (widget.startStep != null) ? widget.startStep!.clamp(0, 2) : 1;
      // Reset animations for the role grid
      _slideController.reset();
      _fadeController.reset();
      _buttonController.reset();
      _slideController.forward();
      _fadeController.forward();
      _didApplyStartParams = true;
      setState(() {});
    }
  }

  void _initializeAnimations() {
    // Performance-optimized timing
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400), // Faster
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300), // Faster
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 250), // Snappy
      vsync: this,
    );

    _typewriterController = AnimationController(
      duration: const Duration(milliseconds: 800), // Much faster
      vsync: this,
    );

    // Optimized animations with linear interpolation for performance
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // Minimal distance
      end: Offset.zero,
    ).animate(_slideController); // Remove CurvedAnimation for performance

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController); // Direct animation

    _buttonFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_buttonController); // Direct animation

    _typewriterAnimation = IntTween(
      begin: 0,
      end: _currentText.length,
    ).animate(_typewriterController); // Linear for performance

    // Faster sequence
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

  void _handleAffiliationSelection(String affiliationId) {
    setState(() {
      _selectedAffiliation = affiliationId;
    });

    HapticFeedback.selectionClick();

    // Trigger continue button fade-in animation
    _buttonController.forward();
  }

  void _handleRoleSelection(String roleId) {
    setState(() {
      _selectedRole = roleId;
    });

    HapticFeedback.selectionClick();

    // Show continue button if not already visible
    if (_buttonController.status != AnimationStatus.completed) {
      _buttonController.forward();
    }
  }

  Widget _buildCurrentStepContent() {
    final isAgency = _selectedAffiliation == 'agency';
    switch (_currentStep) {
      case 0:
        return _buildAffiliationGrid();
      case 1:
        return isAgency ? _buildAgencyGrid() : _buildRoleGrid();
      case 2:
        return isAgency ? _buildRoleGrid() : _buildPinEntry();
      case 3:
        return _buildPinEntry();
      default:
        return _buildAffiliationGrid();
    }
  }

  Widget _buildAgencyGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 1.h,
        childAspectRatio: 1.3,
      ),
      itemCount: _agencyOptions.length,
      itemBuilder: (context, index) {
        final option = _agencyOptions[index];
        final isSelected = _selectedAgency == option['id'];

        return AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            final staggerDelay = index * 0.1;
            final animationValue =
                (_slideController.value - staggerDelay).clamp(0.0, 1.0);

            if (animationValue <= 0) {
              return const SizedBox.shrink();
            }

            return Transform.translate(
              offset: Offset(0, (1 - animationValue) * 20),
              child: Opacity(
                opacity: animationValue,
                child: _buildAgencyCard(option, isSelected),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAgencyCard(Map<String, dynamic> option, bool isSelected) {
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
          onTap: () => _handleAgencySelection(option['id']),
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
                    alignment: Alignment.center,
                    child: Icon(
                      option['icon'],
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  option['title'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAffiliationGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 1.h,
        childAspectRatio: 1.3,
      ),
      itemCount: _affiliationOptions.length,
      itemBuilder: (context, index) {
        return _buildAnimatedAffiliationCard(_affiliationOptions[index], index);
      },
    );
  }

  Widget _buildRoleGrid() {
    return GridView.builder(
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

        return AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            final staggerDelay = index * 0.1;
            final animationValue =
                (_slideController.value - staggerDelay).clamp(0.0, 1.0);

            if (animationValue <= 0) {
              return const SizedBox.shrink();
            }

            return Transform.translate(
              offset: Offset(0, (1 - animationValue) * 20),
              child: Opacity(
                opacity: animationValue,
                child: _buildRoleCard(option, isSelected),
              ),
            );
          },
        );
      },
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

  Widget _buildPinEntry() {
    return Column(
      children: [
        SizedBox(height: 2.h),

        // PIN Input Field
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          decoration: BoxDecoration(
            color: _isDarkMode ? Colors.white.withOpacity(0.95) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: TextEditingController(text: _enteredPin),
            readOnly: true,
            textAlign: TextAlign.center,
            maxLength: 4,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: primaryColor,
              letterSpacing: 8.w,
            ),
            decoration: InputDecoration(
              hintText: '• • • •',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 24.sp,
                letterSpacing: 8.w,
              ),
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 5.w,
                vertical: 2.h,
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: primaryColor,
                size: 6.w,
              ),
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // Custom number pad
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: _isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isDarkMode
                  ? Colors.white.withOpacity(0.2)
                  : Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 2.h),

              // Row 1: 1, 2, 3
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNumberButton('1'),
                  _buildNumberButton('2'),
                  _buildNumberButton('3'),
                ],
              ),
              SizedBox(height: 2.h),

              // Row 2: 4, 5, 6
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNumberButton('4'),
                  _buildNumberButton('5'),
                  _buildNumberButton('6'),
                ],
              ),
              SizedBox(height: 2.h),

              // Row 3: 7, 8, 9
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNumberButton('7'),
                  _buildNumberButton('8'),
                  _buildNumberButton('9'),
                ],
              ),
              SizedBox(height: 2.h),

              // Row 4: empty, 0, backspace
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(width: 15.w, height: 6.h), // Empty space
                  _buildNumberButton('0'),
                  _buildBackspaceButton(),
                ],
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // PIN hint text
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          style: TextStyle(
            fontSize: 11.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
          child: Text('Enter your 4-digit access PIN'),
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return Container(
      width: 15.w,
      height: 6.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isDarkMode
                    ? [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ]
                    : [
                        Colors.grey[100]!.withOpacity(0.8),
                        Colors.grey[200]!.withOpacity(0.6),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onNumberPressed(number),
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: _textColor(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Container(
      width: 15.w,
      height: 6.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isDarkMode
                    ? [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ]
                    : [
                        Colors.grey[100]!.withOpacity(0.8),
                        Colors.grey[200]!.withOpacity(0.6),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _onBackspacePressed,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Icon(
                    Icons.backspace_outlined,
                    color: _textColor(context),
                    size: 6.w,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
      });

      // Haptic feedback
      HapticFeedback.selectionClick();

      // Auto-proceed when PIN is complete
      if (_enteredPin.length == 4) {
        if (_buttonController.status != AnimationStatus.completed) {
          _buttonController.forward();
        }
        // Small delay before auto-proceeding
        Future.delayed(Duration(milliseconds: 500), () {
          if (_enteredPin.length == 4) {
            _proceedToNextStep();
          }
        });
      }
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
      HapticFeedback.selectionClick();
    }
  }

void _proceedToNextStep() {
    if (_isLoading) return;

    HapticFeedback.mediumImpact();

    final isAgency = _selectedAffiliation == 'agency';

    if (_currentStep == 0) {
      if (_selectedAffiliation == 'regular') {
        _completeFlow();
      } else {
        _transitionToNextStep();
      }
    } else if (_currentStep == 1) {
      if (isAgency) {
        if (_selectedAgency != null) _transitionToNextStep();
      } else {
        if (_selectedRole != null) _transitionToNextStep();
      }
    } else if (_currentStep == 2) {
      if (isAgency) {
        if (_selectedRole != null) _transitionToNextStep();
      } else {
        if (_enteredPin.length >= 4) _completeFlow();
      }
    } else if (_currentStep == 3) {
      if (_enteredPin.length >= 4) _completeFlow();
    }
  }

  void _updateTextForStep() {
    final isAgency = _selectedAffiliation == 'agency';
    switch (_currentStep) {
      case 0:
        _currentText = 'Hello User, how can we help you today?';
        break;
      case 1:
        if (isAgency) {
          _currentText = 'Which agency are you with?';
        } else {
          String affiliationName = _affiliationOptions.firstWhere(
              (option) => option['id'] == _selectedAffiliation)['title'];
          _currentText = 'What is your role at $affiliationName?';
        }
        break;
      case 2:
        if (isAgency) {
          final agencyName = _agencyOptions
              .firstWhere((a) => a['id'] == _selectedAgency)['title'];
          _currentText = 'What is your role at $agencyName?';
        } else {
          _currentText = 'Please enter your access PIN';
        }
        break;
      case 3:
        _currentText = 'Please enter your access PIN';
        break;
      default:
        _currentText = 'Welcome to TEASE!';
    }
  }

  String _getSubtitleForStep() {
    final isAgency = _selectedAffiliation == 'agency';
    switch (_currentStep) {
      case 0:
        return 'Select your affiliation';
      case 1:
        return isAgency ? 'Pick your agency' : 'Choose your role';
      case 2:
        return isAgency ? 'Choose your role' : 'Secure access verification';
      case 3:
        return 'Secure access verification';
      default:
        return 'Welcome to TEASE!';
    }
  }

  void _transitionToNextStep() {
    setState(() {
      _isLoading = true;
    });

    // Animate out current content
    _fadeController.reverse().then((_) {
      setState(() {
        _currentStep++;
        _isLoading = false;

        // Prepare options when entering role selection step
        final isAgency = _selectedAffiliation == 'agency';
        if (!isAgency && _currentStep == 1) {
          _currentStepOptions = _roleOptions[_selectedAffiliation] ?? [];
        } else if (isAgency && _currentStep == 2) {
          _currentStepOptions = _roleOptions['agency'] ?? [];
        }

        // Update text for new step
        _updateTextForStep();

        // Update typewriter animation for new text length
        _typewriterAnimation = IntTween(
          begin: 0,
          end: _currentText.length,
        ).animate(_typewriterController);
      });

      // Restart typewriter animation for new text
      _typewriterController.reset();
      _typewriterController.forward();

      // Animate in new content
      _fadeController.forward();
      _slideController.reset();
      _slideController.forward();
    });
  }

  void _handleAgencySelection(String agencyId) {
    setState(() {
      _selectedAgency = agencyId;
    });
    HapticFeedback.selectionClick();
    if (_buttonController.status != AnimationStatus.completed) {
      _buttonController.forward();
    }
  }

  void _completeFlow() async {
    setState(() {
      _isLoading = true;
    });

    // Save user selections to SharedPreferences for home screen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'user_affiliation', _selectedAffiliation ?? 'regular');
    await prefs.setString('user_role', _selectedRole ?? 'passenger');
    if (_selectedAffiliation == 'agency' && _selectedAgency != null) {
      await prefs.setString('user_agency', _selectedAgency!);
    }

    // Also save the affiliation title for display
    String affiliationTitle = _affiliationOptions.firstWhere(
        (option) => option['id'] == _selectedAffiliation,
        orElse: () => {'title': 'Public Transport'})['title'];
    await prefs.setString('user_affiliation_title', affiliationTitle);

    // Navigate based on final selections
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacementNamed(context, '/home-dashboard');
    });
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode =
          prefs.getBool('isDarkMode') ?? false; // Default to light mode
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

  // Use theme-based colors for smooth transitions
  Color _getThemeColor(BuildContext context,
      {required Color lightColor, required Color darkColor}) {
    return _isDarkMode ? darkColor : lightColor;
  }

  Color _backgroundColor(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color _textColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  Color _appBarIconColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  Color _buttonBackgroundColor(BuildContext context) => _isDarkMode
      ? Theme.of(context).colorScheme.surface.withOpacity(0.95)
      : Theme.of(context).colorScheme.primary;
  Color _buttonTextColor(BuildContext context) => _isDarkMode
      ? Theme.of(context).colorScheme.primary
      : Theme.of(context).colorScheme.onPrimary;
  Color _supportIconColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  // Use existing app theme system for consistency
  ThemeData get _darkTheme => AppTheme.darkTheme;
  ThemeData get _lightTheme => AppTheme.lightTheme;

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Need Help?',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : primaryColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Contact our support team for assistance with your account setup.',
            style: TextStyle(
              color: _isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 14.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedAffiliationCard(Map<String, dynamic> option, int index) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        // Simplified stagger for performance
        final staggerDelay = index * 0.1;
        final animationValue =
            (_slideController.value - staggerDelay).clamp(0.0, 1.0);

        if (animationValue <= 0) {
          return const SizedBox.shrink(); // Don't render until ready
        }

        // Minimal transform for performance
        return Transform.translate(
          offset: Offset(0, (1 - animationValue) * 20), // Reduced distance
          child: Opacity(
            opacity: animationValue,
            child: _buildAffiliationCard(option),
          ),
        );
      },
    );
  }

  Widget _buildAffiliationCard(Map<String, dynamic> option) {
    final bool isSelected = _selectedAffiliation == option['id'];

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
          onTap: () => _handleAffiliationSelection(option['id']),
          borderRadius: BorderRadius.circular(16),
          splashColor: primaryColor.withOpacity(0.2),
          highlightColor: primaryColor.withOpacity(0.1),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with ripple effect
                Material(
                  color: Colors.white.withOpacity(0.2),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => _handleAffiliationSelection(option['id']),
                    customBorder: const CircleBorder(),
                    splashColor: Colors.white.withOpacity(0.3),
                    highlightColor: Colors.white.withOpacity(0.2),
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
                ),

                SizedBox(height: 0.8.h),

                // Title only
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

                // Selection indicator with ripple
                if (isSelected) ...[
                  SizedBox(height: 0.5.h),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => _handleAffiliationSelection(option['id']),
                      customBorder: const CircleBorder(),
                      splashColor: primaryColor.withOpacity(0.3),
                      child: Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: primaryColor,
                          size: 3.w,
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      duration:
          const Duration(milliseconds: 600), // Smoother, longer transition
      curve: Curves.easeInOutCubic, // More natural cubic curve
      data: _isDarkMode ? _darkTheme : _lightTheme,
      onEnd: () {
        // Optional: Trigger haptic feedback when transition completes
        HapticFeedback.lightImpact();
      },
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
              child: Text('Choose Your Access'),
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
          body: Stack(
            children: [
              SafeArea(
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

                          // Welcome text with animation
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutBack,
                            )),
                            child: AnimatedBuilder(
                              animation: _typewriterAnimation,
                              builder: (context, child) {
                                final currentText = _currentText.substring(
                                    0, _typewriterAnimation.value);
                                return RepaintBoundary(
                                  // Prevent unnecessary repaints
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeInOutCubic,
                                    style: TextStyle(
                                      color: _textColor(context),
                                      fontSize: _currentStep == 2
                                          ? 28.sp
                                          : 42.sp, // Smaller for PIN step
                                      fontWeight: FontWeight.w800,
                                    ),
                                    child: Text(currentText),
                                  ),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 0.1.h),

                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: Curves.easeOutBack,
                            )),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOutCubic,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.8),
                                  fontSize: 14.sp,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                child: Text(_getSubtitleForStep()),
                              ),
                            ),
                          ),

                          SizedBox(height: 1.h),

                          // Dynamic content based on current step
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildCurrentStepContent(),
                            ),
                          ),

                          SizedBox(height: 3.h),

                          // Continue button and support icon with glassmorphism
                          AnimatedBuilder(
                            animation: _buttonFadeAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _buttonFadeAnimation.value,
                                child: Transform.translate(
                                  offset: Offset(
                                      0, 20 * (1 - _buttonFadeAnimation.value)),
                                  child: Row(
                                    children: [
                                      // Continue button (3/4 width) with glassmorphism
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          height: 6.h,
                                          margin: EdgeInsets.only(
                                              left: 2.w, right: 1.w),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 18.0, sigmaY: 18.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: _buttonBackgroundColor(
                                                      context),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .outline
                                                        .withOpacity(0.2),
                                                    width: 1.2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Theme.of(context)
                                                          .shadowColor
                                                          .withOpacity(0.1),
                                                      blurRadius: 10,
                                                      offset:
                                                          const Offset(0, 8),
                                                    ),
                                                  ],
                                                ),
                                                child: ElevatedButton(
                                                  onPressed:
                                                      _selectedAffiliation !=
                                                              null
                                                          ? _proceedToNextStep
                                                          : null,
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 4.w,
                                                      vertical: 1.h,
                                                    ),
                                                  ),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'Continue',
                                                      style: TextStyle(
                                                        color: _buttonTextColor(
                                                            context),
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Support icon (1/4 width) with glassmorphism
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 6.h,
                                          margin: EdgeInsets.only(right: 2.w),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 18.0, sigmaY: 18.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Colors.white
                                                          .withOpacity(0.15),
                                                      Colors.white
                                                          .withOpacity(0.05),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    width: 1.2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 10,
                                                      offset:
                                                          const Offset(0, 8),
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: _showSupportDialog,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      child: Icon(
                                                        Icons.support_agent,
                                                        color:
                                                            _supportIconColor(
                                                                context),
                                                        size: 6.w,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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

              // Support icon at bottom

              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.onSurfaceLight.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: primaryColor,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Setting up your account...',
                            style: TextStyle(
                              color: AppTheme.onSurfaceLight,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ), // Builder
      ), // AnimatedTheme
    );
  }
}
