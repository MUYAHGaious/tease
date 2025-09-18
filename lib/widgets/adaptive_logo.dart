import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import '../theme/adaptive_theme_manager.dart';

enum LogoVariant {
  primary,    // Main logo for headers/auth screens
  compact,    // Smaller version for app bars
  icon,       // Icon-only version
  monochrome, // Single color version
}

class AdaptiveLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final LogoVariant variant;
  final bool animated;
  final Duration animationDuration;
  final Color? overrideColor;

  const AdaptiveLogo({
    Key? key,
    this.width,
    this.height,
    this.variant = LogoVariant.primary,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.overrideColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (animated) {
      return AnimatedBuilder(
        animation: ValueNotifier(Theme.of(context).brightness),
        builder: (context, child) {
          return _buildLogoContent(context);
        },
      );
    }
    return _buildLogoContent(context);
  }

  Widget _buildLogoContent(BuildContext context) {
    final themeManager = AdaptiveThemeManager();
    final isDark = themeManager.isDarkMode(context);
    final surfaceColors = themeManager.getSurfaceColors(context);
    
    // Determine logo properties based on theme and variant
    final logoConfig = _getLogoConfig(isDark, surfaceColors, context);
    
    Widget logoWidget;

    // Try to use SVG first (more scalable and theme-friendly)
    try {
      logoWidget = SvgPicture.asset(
        logoConfig.assetPath,
        width: width ?? _getDefaultWidth(),
        height: height ?? _getDefaultHeight(),
        colorFilter: logoConfig.color != null 
            ? ColorFilter.mode(logoConfig.color!, BlendMode.srcIn)
            : null,
        fit: BoxFit.contain,
      );
    } catch (e) {
      // Fallback to PNG with color overlay
      logoWidget = Image.asset(
        'assets/White.png', // Fallback to existing PNG
        width: width ?? _getDefaultWidth(),
        height: height ?? _getDefaultHeight(),
        fit: BoxFit.contain,
        color: overrideColor ?? logoConfig.color,
        colorBlendMode: logoConfig.color != null ? BlendMode.srcIn : null,
      );
    }

    // Apply animation if enabled
    if (animated) {
      return AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeInOut,
        child: TweenAnimationBuilder<double>(
          duration: animationDuration,
          tween: Tween(begin: 0.8, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: logoWidget,
            );
          },
        ),
      );
    }

    return logoWidget;
  }

  LogoConfiguration _getLogoConfig(bool isDark, AdaptiveSurfaceColors colors, BuildContext context) {
    switch (variant) {
      case LogoVariant.primary:
        return LogoConfiguration(
          assetPath: 'assets/app_icon.svg',
          color: overrideColor ?? _getPrimaryLogoColor(isDark, colors),
          scale: 1.0,
        );
        
      case LogoVariant.compact:
        return LogoConfiguration(
          assetPath: 'assets/app_icon.svg',
          color: overrideColor ?? colors.onSurface,
          scale: 0.8,
        );
        
      case LogoVariant.icon:
        return LogoConfiguration(
          assetPath: 'assets/app_icon.svg',
          color: overrideColor ?? colors.primary,
          scale: 0.6,
        );
        
      case LogoVariant.monochrome:
        return LogoConfiguration(
          assetPath: 'assets/app_icon.svg',
          color: overrideColor ?? (isDark ? Colors.white : Colors.black87),
          scale: 1.0,
        );
    }
  }

  Color _getPrimaryLogoColor(bool isDark, AdaptiveSurfaceColors colors) {
    if (isDark) {
      // In dark mode, use white or light accent color
      return Colors.white;
    } else {
      // In light mode, use the brand color or dark accent
      return colors.primary;
    }
  }

  double _getDefaultWidth() {
    switch (variant) {
      case LogoVariant.primary:
        return 35.w;
      case LogoVariant.compact:
        return 12.w;
      case LogoVariant.icon:
        return 8.w;
      case LogoVariant.monochrome:
        return 30.w;
    }
  }

  double _getDefaultHeight() {
    switch (variant) {
      case LogoVariant.primary:
        return 35.w; // Square aspect ratio for primary
      case LogoVariant.compact:
        return 12.w;
      case LogoVariant.icon:
        return 8.w;
      case LogoVariant.monochrome:
        return 30.w;
    }
  }
}

// Enhanced logo widget with more customization options
class AdaptiveLogoWithEffects extends StatefulWidget {
  final double? width;
  final double? height;
  final LogoVariant variant;
  final bool pulseAnimation;
  final bool glowEffect;
  final Duration animationDuration;
  final Color? overrideColor;
  final VoidCallback? onTap;

  const AdaptiveLogoWithEffects({
    Key? key,
    this.width,
    this.height,
    this.variant = LogoVariant.primary,
    this.pulseAnimation = false,
    this.glowEffect = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.overrideColor,
    this.onTap,
  }) : super(key: key);

  @override
  State<AdaptiveLogoWithEffects> createState() => _AdaptiveLogoWithEffectsState();
}

class _AdaptiveLogoWithEffectsState extends State<AdaptiveLogoWithEffects>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.pulseAnimation) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget logo = AdaptiveLogo(
      width: widget.width,
      height: widget.height,
      variant: widget.variant,
      animationDuration: widget.animationDuration,
      overrideColor: widget.overrideColor,
    );

    // Apply pulse animation
    if (widget.pulseAnimation) {
      logo = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: logo,
          );
        },
      );
    }

    // Apply glow effect
    if (widget.glowEffect) {
      final themeManager = AdaptiveThemeManager();
      final colors = themeManager.getSurfaceColors(context);
      
      logo = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: logo,
      );
    }

    // Make tappable if onTap is provided
    if (widget.onTap != null) {
      logo = GestureDetector(
        onTap: widget.onTap,
        child: logo,
      );
    }

    return logo;
  }
}

// Configuration class for logo properties
class LogoConfiguration {
  final String assetPath;
  final Color? color;
  final double scale;

  const LogoConfiguration({
    required this.assetPath,
    this.color,
    required this.scale,
  });
}

// Logo theme data provider
class LogoTheme {
  static LogoThemeData light() {
    return LogoThemeData(
      primaryColor: const Color(0xFF1a4d3a),
      secondaryColor: Colors.black87,
      backgroundColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
    );
  }

  static LogoThemeData dark() {
    return LogoThemeData(
      primaryColor: Colors.white,
      secondaryColor: Colors.white70,
      backgroundColor: const Color(0xFF1C1C1E),
      shadowColor: Colors.white.withOpacity(0.1),
    );
  }

  static LogoThemeData tinted(Color accentColor, bool isDark) {
    return LogoThemeData(
      primaryColor: accentColor,
      secondaryColor: isDark ? Colors.white70 : Colors.black87,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shadowColor: accentColor.withOpacity(0.3),
    );
  }
}

class LogoThemeData {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color shadowColor;

  const LogoThemeData({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.shadowColor,
  });
}