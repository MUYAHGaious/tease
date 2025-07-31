import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SpecialOffersSectionWidget extends StatefulWidget {
  const SpecialOffersSectionWidget({super.key});

  @override
  State<SpecialOffersSectionWidget> createState() =>
      _SpecialOffersSectionWidgetState();
}

class _SpecialOffersSectionWidgetState extends State<SpecialOffersSectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late PageController _pageController;
  late Timer _autoScrollTimer;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _offers = [
    {
      'title': 'Weekend Special',
      'subtitle': '25% off on all routes',
      'code': 'WEEKEND25',
      'validUntil': 'Valid until Dec 31',
      'gradient': [AppTheme.secondaryLight, const Color(0xFFFF8C00)],
      'image':
          'https://images.pexels.com/photo-1570125909232-eb263c188f7e?w=400',
    },
    {
      'title': 'Student Discount',
      'subtitle': '40% off with student ID',
      'code': 'STUDENT40',
      'validUntil': 'Valid all semester',
      'gradient': [AppTheme.primaryLight, const Color(0xFF4CAF50)],
      'image': 'https://images.pexels.com/photo-1559827260-dc66d52bef19?w=400',
    },
    {
      'title': 'First Ride Free',
      'subtitle': 'New users get first ride free',
      'code': 'NEWUSER',
      'validUntil': 'Valid for 30 days',
      'gradient': [const Color(0xFF9C27B0), const Color(0xFF3F51B5)],
      'image':
          'https://images.pexels.com/photo-1565440962783-f87efdea99ce?w=400',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAutoScroll();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.elasticOut),
    );

    _pageController = PageController();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _rotationController.forward();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _offers.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pageController.dispose();
    _autoScrollTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: (1 - _rotationAnimation.value) * 0.1,
          child: Opacity(
            opacity: _rotationAnimation.value,
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Special Offers',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryLight,
                    ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.errorLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: AppTheme.errorLight,
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Limited Time',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.errorLight,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 22.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _offers.length,
            itemBuilder: (context, index) {
              return _buildOfferCard(_offers[index], index);
            },
          ),
        ),
        SizedBox(height: 2.h),
        _buildPageIndicators(),
      ],
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: offer['gradient'][0].withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.w),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: offer['gradient'],
            ),
          ),
          child: Stack(
            children: [
              _buildBackgroundPattern(),
              _buildOfferContent(offer),
              _buildCountdownTimer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _OfferBackgroundPainter(),
      ),
    );
  }

  Widget _buildOfferContent(Map<String, dynamic> offer) {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  offer['title'],
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 1.h),
                Text(
                  offer['subtitle'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Code: ${offer['code']}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  offer['validUntil'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 12.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.w),
                child: Image.network(
                  offer['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.white.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.local_offer,
                        color: Colors.white,
                        size: 8.w,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return Positioned(
      top: 3.w,
      right: 3.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer,
              color: AppTheme.errorLight,
              size: 3.w,
            ),
            SizedBox(width: 1.w),
            Text(
              '2d 14h',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.errorLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _offers.asMap().entries.map((entry) {
          int index = entry.key;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _currentPage == index ? 8.w : 2.w,
            height: 1.h,
            margin: EdgeInsets.symmetric(horizontal: 1.w),
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? AppTheme.secondaryLight
                  : AppTheme.neutralLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1.w),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OfferBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw decorative circles
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.15,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.7),
      size.width * 0.1,
      paint,
    );

    // Draw decorative lines
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(size.width * 0.7, size.height * (0.1 + i * 0.15)),
        Offset(size.width * 0.95, size.height * (0.1 + i * 0.15)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
