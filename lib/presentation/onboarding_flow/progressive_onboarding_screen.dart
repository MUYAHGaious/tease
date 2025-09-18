import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/onboarding_models.dart';
import '../../services/onboarding_cache_service.dart';
import '../../services/auth_service.dart';
import '../../core/app_state.dart';
import 'widgets/onboarding_step_widget.dart';
import 'widgets/progress_indicator_widget.dart';

class ProgressiveOnboardingScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const ProgressiveOnboardingScreen({
    super.key,
    required this.arguments,
  });

  @override
  State<ProgressiveOnboardingScreen> createState() => _ProgressiveOnboardingScreenState();
}

class _ProgressiveOnboardingScreenState extends State<ProgressiveOnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late PageController _pageController;
  
  String _sessionType = '';
  int _currentStep = 1;
  Map<String, dynamic> _collectedData = {};
  bool _isLoading = false;
  bool _isResuming = false;
  
  List<OnboardingStep> _steps = [];
  OnboardingProgress? _cachedProgress;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _parseArguments();
    _initializeOnboarding();
  }

  void _parseArguments() {
    final args = widget.arguments;
    _sessionType = args['sessionType'] ?? 'ict_university';
    
    if (args['resumeFrom'] != null) {
      _currentStep = args['resumeFrom'];
      _collectedData = Map<String, dynamic>.from(args['cachedData'] ?? {});
      _isResuming = true;
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _initializeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      // Check for cached progress first
      if (!_isResuming) {
        _cachedProgress = await OnboardingCacheService.getProgress(_sessionType);
        
        if (_cachedProgress != null && _cachedProgress!.isValid) {
          _currentStep = _cachedProgress!.currentStep;
          _collectedData = Map<String, dynamic>.from(_cachedProgress!.collectedData);
          _isResuming = true;
        }
      }

      // Load appropriate steps based on session type
      _loadStepsForSessionType();
      
      // Initialize page controller
      _pageController = PageController(initialPage: _currentStep - 1);

      if (_isResuming) {
        _showResumeDialog();
      }

    } catch (e) {
      _showErrorDialog('Failed to initialize onboarding. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadStepsForSessionType() {
    switch (_sessionType) {
      case 'ict_university':
        _steps = _getICTUniversitySteps();
        break;
      case 'agency':
        _steps = _getAgencySteps();
        break;
      case 'school_bus_onboarding':
        _steps = _getSchoolBusOnboardingSteps();
        break;
      default:
        _steps = _getDefaultSteps();
    }
  }

  List<OnboardingStep> _getICTUniversitySteps() {
    return [
      OnboardingStep(
        stepNumber: 1,
        title: 'ICT University Access',
        subtitle: 'Verify your affiliation with ICT University',
        type: OnboardingStepType.position,
        options: [
          OnboardingOption(
            id: 'student',
            title: 'Student',
            subtitle: 'Currently enrolled at ICT University',
            icon: Icons.school,
            color: const Color(0xFF1a4d3a),
            isRecommended: true,
          ),
          OnboardingOption(
            id: 'staff',
            title: 'Staff Member',
            subtitle: 'Faculty or administrative staff',
            icon: Icons.badge,
            color: const Color(0xFF2d5a3d),
          ),
          OnboardingOption(
            id: 'driver',
            title: 'University Driver',
            subtitle: 'Authorized university bus driver',
            icon: Icons.directions_bus,
            color: const Color(0xFF0d2921),
          ),
          OnboardingOption(
            id: 'conductor',
            title: 'Bus Conductor',
            subtitle: 'University bus conductor',
            icon: Icons.confirmation_number,
            color: const Color(0xFF0d2921),
          ),
        ],
      ),
      OnboardingStep(
        stepNumber: 2,
        title: 'Fee Verification',
        subtitle: 'Enter your Personal Identification Number (PIN)',
        type: OnboardingStepType.pinEntry,
        validation: {
          'minLength': 4,
          'maxLength': 8,
          'required': true,
        },
      ),
      OnboardingStep(
        stepNumber: 3,
        title: 'Access Granted',
        subtitle: 'Welcome to ICT University services',
        type: OnboardingStepType.confirmation,
      ),
    ];
  }

  List<OnboardingStep> _getAgencySteps() {
    return [
      OnboardingStep(
        stepNumber: 1,
        title: 'Agency Affiliation',
        subtitle: 'What is your position at the transport agency?',
        type: OnboardingStepType.position,
        options: [
          OnboardingOption(
            id: 'schedule_manager',
            title: 'Schedule Manager',
            subtitle: 'Manage routes and schedules',
            icon: Icons.admin_panel_settings,
            color: const Color(0xFF1a4d3a),
          ),
          OnboardingOption(
            id: 'driver',
            title: 'Driver',
            subtitle: 'Licensed bus driver',
            icon: Icons.directions_bus,
            color: const Color(0xFF2d5a3d),
          ),
          OnboardingOption(
            id: 'conductor',
            title: 'Bus Conductor',
            subtitle: 'Ticket verification and passenger assistance',
            icon: Icons.confirmation_number,
            color: const Color(0xFF0d2921),
          ),
          OnboardingOption(
            id: 'booking_clerk',
            title: 'Booking Clerk',
            subtitle: 'Process bookings and reservations',
            icon: Icons.book,
            color: const Color(0xFF4a6741),
          ),
        ],
      ),
      OnboardingStep(
        stepNumber: 2,
        title: 'Employee Verification',
        subtitle: 'Enter your employee identification PIN',
        type: OnboardingStepType.pinEntry,
        validation: {
          'minLength': 4,
          'maxLength': 8,
          'required': true,
        },
      ),
      OnboardingStep(
        stepNumber: 3,
        title: 'Access Granted',
        subtitle: 'Welcome to your agency dashboard',
        type: OnboardingStepType.confirmation,
      ),
    ];
  }

  List<OnboardingStep> _getSchoolBusOnboardingSteps() {
    // Shortened flow for accessing school bus from menu
    return [
      OnboardingStep(
        stepNumber: 1,
        title: 'School Bus Access',
        subtitle: 'Are you affiliated with ICT University?',
        type: OnboardingStepType.affiliation,
        options: [
          OnboardingOption(
            id: 'yes',
            title: 'Yes, I am affiliated',
            subtitle: 'I am a student, staff, or university employee',
            icon: Icons.check_circle,
            color: const Color(0xFF1a4d3a),
            isRecommended: true,
          ),
          OnboardingOption(
            id: 'no',
            title: 'No, I am not affiliated',
            subtitle: 'I want to use regular bus services',
            icon: Icons.cancel,
            color: const Color(0xFF757575),
          ),
        ],
      ),
    ];
  }

  List<OnboardingStep> _getDefaultSteps() {
    return [
      OnboardingStep(
        stepNumber: 1,
        title: 'Get Started',
        subtitle: 'Complete your profile setup',
        type: OnboardingStepType.confirmation,
      ),
    ];
  }

  void _showResumeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Resume Setup'),
        content: Text(
          'We found your previous setup progress. Would you like to continue from where you left off?'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startFresh();
            },
            child: Text('Start Over'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _startFresh() {
    setState(() {
      _currentStep = 1;
      _collectedData.clear();
      _isResuming = false;
    });
    _pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    OnboardingCacheService.clearProgress(_sessionType);
  }

  Future<void> _handleStepCompleted(int stepNumber, Map<String, dynamic> stepData) async {
    setState(() => _isLoading = true);

    try {
      // Update collected data
      _collectedData.addAll(stepData);

      // Save progress to cache
      final progress = OnboardingProgress(
        sessionType: _sessionType,
        currentStep: stepNumber + 1,
        collectedData: _collectedData,
        createdAt: DateTime.now(),
      );

      await OnboardingCacheService.saveProgress(progress);

      // Move to next step or complete
      if (stepNumber < _steps.length) {
        setState(() {
          _currentStep = stepNumber + 1;
        });
        
        await _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        await _completeOnboarding();
      }

    } catch (e) {
      _showErrorDialog('Failed to save progress. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      // Process final data based on session type
      await _processFinalData();

      // Clear cached progress
      await OnboardingCacheService.clearProgress(_sessionType);

      // Refresh app state
      await AppState().refreshUserData();

      // Navigate to appropriate screen
      _navigatePostOnboarding();

    } catch (e) {
      _showErrorDialog('Failed to complete setup. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processFinalData() async {
    switch (_sessionType) {
      case 'ict_university':
      case 'school_bus_onboarding':
        await _processUniversityData();
        break;
      case 'agency':
        await _processAgencyData();
        break;
    }
  }

  Future<void> _processUniversityData() async {
    if (_sessionType == 'school_bus_onboarding' && 
        _collectedData['affiliation'] == 'no') {
      // User declined university affiliation, just navigate to regular dashboard
      return;
    }

    final position = _collectedData['position'] ?? 'student';
    final pin = _collectedData['pin'] ?? '';

    if (pin.isNotEmpty) {
      final result = await AuthService.verifyPinAndUpdateRole(
        affiliation: 'ict_university',
        position: position,
        pin: pin,
      );

      if (!result.success) {
        throw Exception(result.message);
      }
    } else {
      // Update role without PIN for basic affiliation
      final result = await AuthService.updateUserRole(
        affiliation: 'ict_university',
        position: position,
      );

      if (!result.success) {
        throw Exception(result.message);
      }
    }
  }

  Future<void> _processAgencyData() async {
    final position = _collectedData['position'] ?? '';
    final pin = _collectedData['pin'] ?? '';

    final result = await AuthService.verifyPinAndUpdateRole(
      affiliation: 'agency',
      position: position,
      pin: pin,
    );

    if (!result.success) {
      throw Exception(result.message);
    }
  }

  void _navigatePostOnboarding() {
    final user = AppState().currentUser;
    
    if (_sessionType == 'school_bus_onboarding') {
      if (_collectedData['affiliation'] == 'no') {
        Navigator.pushReplacementNamed(context, '/home-dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/school-dashboard');
      }
    } else if (user?.isConductor == true || user?.isDriver == true) {
      Navigator.pushReplacementNamed(context, '/conductor-dashboard');
    } else if (user?.isScheduleManager == true) {
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else if (user?.isUniversityAffiliated == true) {
      Navigator.pushReplacementNamed(context, '/school-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/home-dashboard');
    }
  }

  void _handleBack() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _steps.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1a4d3a),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 2.h),
              Text(
                'Preparing your setup...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1a4d3a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _handleBack,
        ),
        title: Text(
          _getScreenTitle(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1a4d3a),
                  const Color(0xFF0d2921),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Progress indicator
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: ProgressIndicatorWidget(
                    currentStep: _currentStep,
                    totalSteps: _steps.length,
                    isResuming: _isResuming,
                  ),
                ),

                // Onboarding steps
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: OnboardingStepWidget(
                            step: _steps[index],
                            collectedData: _collectedData,
                            isLoading: _isLoading,
                            onStepCompleted: (stepData) => 
                                _handleStepCompleted(index + 1, stepData),
                            sessionType: _sessionType,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getScreenTitle() {
    switch (_sessionType) {
      case 'ict_university':
        return 'ICT University Setup';
      case 'agency':
        return 'Agency Setup';
      case 'school_bus_onboarding':
        return 'School Bus Access';
      default:
        return 'Setup';
    }
  }
}