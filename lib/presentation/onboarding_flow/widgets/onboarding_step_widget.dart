import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/onboarding_models.dart';

class OnboardingStepWidget extends StatefulWidget {
  final OnboardingStep step;
  final Map<String, dynamic> collectedData;
  final bool isLoading;
  final Function(Map<String, dynamic>) onStepCompleted;
  final String sessionType;

  const OnboardingStepWidget({
    super.key,
    required this.step,
    required this.collectedData,
    required this.isLoading,
    required this.onStepCompleted,
    required this.sessionType,
  });

  @override
  State<OnboardingStepWidget> createState() => _OnboardingStepWidgetState();
}

class _OnboardingStepWidgetState extends State<OnboardingStepWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  String? _selectedOptionId;
  final TextEditingController _pinController = TextEditingController();
  String _pinError = '';
  bool _obscurePin = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadExistingData();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleController.forward();
    _fadeController.forward();
  }

  void _loadExistingData() {
    // Pre-fill data from previous steps or cache
    switch (widget.step.type) {
      case OnboardingStepType.position:
      case OnboardingStepType.affiliation:
        _selectedOptionId = widget.collectedData['position'] ?? 
                           widget.collectedData['affiliation'];
        break;
      case OnboardingStepType.pinEntry:
        _pinController.text = widget.collectedData['pin'] ?? '';
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step header
              _buildStepHeader(),
              
              SizedBox(height: 4.h),
              
              // Step content based on type
              Expanded(
                child: _buildStepContent(),
              ),
              
              SizedBox(height: 3.h),
              
              // Action button
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.step.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          widget.step.subtitle,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16.sp,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (widget.step.type) {
      case OnboardingStepType.position:
      case OnboardingStepType.affiliation:
      case OnboardingStepType.feeStatus:
      case OnboardingStepType.selection:
        return _buildOptionsGrid();
      case OnboardingStepType.pinEntry:
        return _buildPinEntryForm();
      case OnboardingStepType.confirmation:
        return _buildConfirmationContent();
      case OnboardingStepType.input:
      default:
        return _buildPinEntryForm(); // Use pin entry form for text input
    }
  }

  Widget _buildOptionsGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.85,
      ),
      itemCount: widget.step.options?.length ?? 0,
      itemBuilder: (context, index) {
        final option = widget.step.options![index];
        final isSelected = _selectedOptionId == option.id;
        
        return _buildOptionCard(option, isSelected);
      },
    );
  }

  Widget _buildOptionCard(OnboardingOption option, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionId = option.id;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? option.color : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: option.color.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ] : [],
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isSelected ? option.color : option.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  option.icon,
                  color: isSelected ? Colors.white : option.color,
                  size: 24.sp,
                ),
              ),
              
              SizedBox(height: 2.h),
              
              // Title
              Text(
                option.title,
                style: TextStyle(
                  color: isSelected ? option.color : Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 1.h),
              
              // Subtitle
              Text(
                option.subtitle,
                style: TextStyle(
                  color: isSelected ? option.color.withOpacity(0.7) : Colors.white70,
                  fontSize: 11.sp,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Recommended badge
              if (option.isRecommended) ...[
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Recommended',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinEntryForm() {
    return Column(
      children: [
        // PIN info card
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.yellow.shade300,
                size: 20.sp,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Enter the Personal Identification Number provided by your institution. This helps verify your eligibility for special services.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 4.h),
        
        // PIN input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _pinError.isNotEmpty 
                  ? Colors.red.shade300 
                  : Colors.white.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: _pinController,
            obscureText: _obscurePin,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your PIN',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16.sp,
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: Colors.white.withOpacity(0.7),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePin ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white.withOpacity(0.7),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePin = !_obscurePin;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
            ),
            onChanged: (value) {
              if (_pinError.isNotEmpty) {
                setState(() {
                  _pinError = '';
                });
              }
            },
          ),
        ),
        
        // Error message
        if (_pinError.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.red.shade900.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.shade300,
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    _pinError,
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // PIN recovery link
        SizedBox(height: 3.h),
        GestureDetector(
          onTap: _showPinRecoveryDialog,
          child: Text(
            'Don\'t remember your PIN?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14.sp,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success animation placeholder
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15.w),
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: Icon(
            Icons.check,
            color: Colors.green,
            size: 15.w,
          ),
        ),
        
        SizedBox(height: 4.h),
        
        Text(
          'Setup Complete!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: 2.h),
        
        Text(
          'Your account has been configured with the appropriate permissions. You can now access all available features.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14.sp,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    final canProceed = _canProceedToNext();
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : (canProceed ? _handleNext : null),
        style: ElevatedButton.styleFrom(
          backgroundColor: canProceed ? Colors.white : Colors.white.withOpacity(0.3),
          foregroundColor: const Color(0xFF1a4d3a),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: canProceed ? 8 : 0,
        ),
        child: widget.isLoading 
            ? SizedBox(
                height: 20.sp,
                width: 20.sp,
                child: CircularProgressIndicator(
                  color: const Color(0xFF1a4d3a),
                  strokeWidth: 2,
                ),
              )
            : Text(
                _getButtonText(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  bool _canProceedToNext() {
    switch (widget.step.type) {
      case OnboardingStepType.position:
      case OnboardingStepType.affiliation:
      case OnboardingStepType.feeStatus:
      case OnboardingStepType.selection:
        return _selectedOptionId != null;
      case OnboardingStepType.pinEntry:
      case OnboardingStepType.input:
        return _pinController.text.isNotEmpty && _pinError.isEmpty;
      case OnboardingStepType.confirmation:
        return true;
      default:
        return false;
    }
  }

  String _getButtonText() {
    switch (widget.step.type) {
      case OnboardingStepType.confirmation:
        return 'Get Started';
      case OnboardingStepType.pinEntry:
        return 'Verify PIN';
      default:
        return 'Continue';
    }
  }

  void _handleNext() {
    Map<String, dynamic> stepData = {};
    
    switch (widget.step.type) {
      case OnboardingStepType.position:
        stepData['position'] = _selectedOptionId;
        break;
      case OnboardingStepType.affiliation:
        stepData['affiliation'] = _selectedOptionId;
        break;
      case OnboardingStepType.pinEntry:
        if (_validatePin()) {
          stepData['pin'] = _pinController.text;
        } else {
          return; // Don't proceed if PIN is invalid
        }
        break;
      case OnboardingStepType.confirmation:
        stepData['completed'] = true;
        break;
      case OnboardingStepType.feeStatus:
        stepData['feeStatus'] = _selectedOptionId;
        break;
      case OnboardingStepType.selection:
      case OnboardingStepType.input:
      default:
        stepData['value'] = _selectedOptionId ?? _pinController.text;
        break;
    }
    
    widget.onStepCompleted(stepData);
  }

  bool _validatePin() {
    final pin = _pinController.text.trim();
    final validation = widget.step.validation ?? {};
    
    if (validation['required'] == true && pin.isEmpty) {
      setState(() {
        _pinError = 'PIN is required';
      });
      return false;
    }
    
    final minLength = validation['minLength'] ?? 0;
    final maxLength = validation['maxLength'] ?? 100;
    
    if (pin.length < minLength) {
      setState(() {
        _pinError = 'PIN must be at least $minLength digits';
      });
      return false;
    }
    
    if (pin.length > maxLength) {
      setState(() {
        _pinError = 'PIN cannot exceed $maxLength digits';
      });
      return false;
    }
    
    // Check if PIN contains only numbers
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      setState(() {
        _pinError = 'PIN must contain only numbers';
      });
      return false;
    }
    
    return true;
  }

  void _showPinRecoveryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a4d3a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'PIN Recovery',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Contact your institution\'s administration office to recover your PIN. You can also request a PIN reset via SMS if your phone number is verified.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement SMS PIN recovery
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1a4d3a),
            ),
            child: Text('Request SMS'),
          ),
        ],
      ),
    );
  }
}