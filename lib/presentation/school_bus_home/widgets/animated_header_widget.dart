import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AnimatedHeaderWidget extends StatefulWidget {
  const AnimatedHeaderWidget({super.key});

  @override
  State<AnimatedHeaderWidget> createState() => _AnimatedHeaderWidgetState();
}

class _AnimatedHeaderWidgetState extends State<AnimatedHeaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _messageController;
  late Animation<double> _messageAnimation;
  late Timer _messageTimer;
  int _currentMessageIndex = 0;

  final List<String> _welcomeMessages = [
    'Book your perfect journey today',
    'Travel smart, travel comfortable',
    'Your next adventure awaits',
    'Premium comfort, reliable service',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startMessageCycle();
  }

  void _initializeAnimations() {
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _messageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _messageController, curve: Curves.easeInOut),
    );

    _messageController.forward();
  }

  void _startMessageCycle() {
    _messageTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        _messageController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _currentMessageIndex =
                  (_currentMessageIndex + 1) % _welcomeMessages.length;
            });
            _messageController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            SizedBox(height: 3.h),
            _buildWelcomeSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.onPrimaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Icon(
              Icons.arrow_back,
              color: AppTheme.onPrimaryLight,
              size: 6.w,
            ),
          ),
        ),
        Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.onPrimaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    color: AppTheme.onPrimaryLight,
                    size: 6.w,
                  ),
                ),
                Positioned(
                  right: 1.w,
                  top: 1.w,
                  child: Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryLight,
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 3.w),
            CircleAvatar(
              radius: 5.w,
              backgroundColor: AppTheme.secondaryLight,
              child: Icon(
                Icons.person,
                color: AppTheme.onSecondaryLight,
                size: 6.w,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.onPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 1.h),
        AnimatedBuilder(
          animation: _messageAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 10 * (1 - _messageAnimation.value)),
              child: Opacity(
                opacity: _messageAnimation.value,
                child: Text(
                  _welcomeMessages[_currentMessageIndex],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.onPrimaryLight.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
