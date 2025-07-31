import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

import '../../core/app_export.dart';
import '../../utils/page_transitions.dart';
import '../onboarding/onboarding_screen.dart';

class PremiumSplashScreen extends StatefulWidget {
  const PremiumSplashScreen({Key? key}) : super(key: key);

  @override
  State<PremiumSplashScreen> createState() => _PremiumSplashScreenState();
}

class _PremiumSplashScreenState extends State<PremiumSplashScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _primaryController;
  late AnimationController _particleController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _fadeOutController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _rippleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _fadeOutAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Primary animation controller (3 seconds)
    _primaryController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Particle effects controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Fade out controller
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo animations
    _logoScale = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Text animations
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _textSlide = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Ambient effects
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: Curves.easeOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: Curves.easeInOut,
    ));

    // Fade out animation
    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeOutController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    // Set system UI overlay style for dark theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0A0A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Start particle effects immediately
    _particleController.repeat();

    // Start primary animation
    _primaryController.forward();

    // Delay logo animation slightly
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _logoController.forward();

    // Start text animation after logo
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) _textController.forward();

    // Wait for total duration then navigate
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      _fadeOutController.forward();
      await Future.delayed(const Duration(milliseconds: 400));
      _navigateToOnboarding();
    }
  }

  void _navigateToOnboarding() {
    if (mounted) {
      Navigator.of(context).pushReplacementWithTransition(
        const OnboardingScreen(),
        transition: (page) => AppPageTransitions.fadeSlideTransition(page: page),
      );
    }
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _particleController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: FadeTransition(
        opacity: _fadeOutAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                const Color(0xFF1A4A47).withOpacity(0.3),
                const Color(0xFF0A0A0A),
                const Color(0xFF000000),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Animated particles background
              _buildAnimatedParticles(),
              
              // Ripple effects
              _buildRippleEffects(),
              
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo
                    _buildAnimatedLogo(),
                    
                    SizedBox(height: 4.h),
                    
                    // Animated text
                    _buildAnimatedText(),
                    
                    SizedBox(height: 2.h),
                    
                    // Subtitle
                    _buildSubtitle(),
                  ],
                ),
              ),
              
              // Ambient glow effects
              _buildAmbientGlow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(
            animation: _particleController,
            particleCount: 50,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildRippleEffects() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return Center(
          child: Container(
            width: 300 * _rippleAnimation.value,
            height: 300 * _rippleAnimation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFC8E53F).withOpacity(
                  (1 - _rippleAnimation.value) * 0.3,
                ),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoScale, _logoRotation, _logoOpacity]),
      builder: (context, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(
            scale: _logoScale.value,
            child: Transform.rotate(
              angle: _logoRotation.value,
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFC8E53F),
                      const Color(0xFFA3C635),
                      const Color(0xFF1A4A47),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6.w),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC8E53F).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: const Color(0xFFC8E53F).withOpacity(0.3),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.directions_bus,
                  color: Colors.white,
                  size: 12.w,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: Listenable.merge([_textOpacity, _textSlide]),
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _textSlide.value),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  const Color(0xFFC8E53F),
                  Colors.white,
                  const Color(0xFFC8E53F),
                ],
              ).createShader(bounds),
              child: Text(
                'Tease',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFC8E53F).withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _textOpacity,
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacity.value * 0.8,
          child: Text(
            'Premium Bus Travel Experience',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmbientGlow() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  const Color(0xFFC8E53F).withOpacity(
                    _glowAnimation.value * 0.1,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final Animation<double> animation;
  final int particleCount;
  
  ParticlesPainter({
    required this.animation,
    required this.particleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC8E53F).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent particles
    
    for (int i = 0; i < particleCount; i++) {
      final progress = (animation.value + (i / particleCount)) % 1.0;
      final x = random.nextDouble() * size.width;
      final y = size.height * (1 - progress) + random.nextDouble() * 100;
      final radius = random.nextDouble() * 3 + 1;
      
      paint.color = const Color(0xFFC8E53F).withOpacity(
        (1 - progress) * 0.3,
      );
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}