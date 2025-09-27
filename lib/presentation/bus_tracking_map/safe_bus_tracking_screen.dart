import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';
import 'dart:math' as math;

// 2025 Premium Design Constants
const Color primaryColor = Color(0xFF008B8B);
const Color premiumGlass = Color(0x1AFFFFFF);
const Color premiumBorder = Color(0x33FFFFFF);
const double cardBorderRadius = 20.0;
const double glassBlur = 10.0;

/// Premium 2025 bus tracking with sophisticated glassmorphism design
class SafeBusTrackingScreen extends StatefulWidget {
  const SafeBusTrackingScreen({super.key});

  @override
  State<SafeBusTrackingScreen> createState() => _SafeBusTrackingScreenState();
}

class _SafeBusTrackingScreenState extends State<SafeBusTrackingScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Controllers with proper disposal tracking
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Timer with safe cancellation
  Timer? _updateTimer;

  // State management with null safety
  bool _isTracking = false;
  bool _isDisposed = false;
  String _selectedBusId = 'bus_1';

  // Mock data - simplified for mobile performance
  final Map<String, Map<String, dynamic>> _buses = {
    'bus_1': {
      'id': 'bus_1',
      'name': 'School Bus A',
      'driver': 'John Smith',
      'route': 'Route 1 - North District',
      'speed': 25.0,
      'status': 'active',
      'students': 12,
    },
    'bus_2': {
      'id': 'bus_2',
      'name': 'School Bus B',
      'driver': 'Sarah Johnson',
      'route': 'Route 2 - South District',
      'speed': 18.0,
      'status': 'active',
      'students': 8,
    },
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize controllers with safe disposal
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Safe async initialization
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // Check mounted before any async operations
    if (!mounted || _isDisposed) return;

    try {
      await _fadeController.forward();

      // Start tracking after UI settles
      if (mounted && !_isDisposed) {
        _startSafeTracking();
      }
    } catch (e) {
      debugPrint('Screen initialization error: $e');
      // Fail gracefully without crashing
    }
  }

  void _startSafeTracking() {
    if (_isDisposed || !mounted) return;

    _setStateIfMounted(() {
      _isTracking = true;
    });

    // Cancel any existing timer
    _updateTimer?.cancel();

    // Conservative update frequency for mobile stability
    _updateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => _performSafeUpdate(),
    );
  }

  void _performSafeUpdate() {
    // Multiple safety checks
    if (_isDisposed || !mounted || !_isTracking) {
      _updateTimer?.cancel();
      return;
    }

    try {
      _setStateIfMounted(() {
        // Minimal updates to prevent performance issues
        final selectedBus = _buses[_selectedBusId];
        if (selectedBus != null) {
          final random = math.Random();
          final currentSpeed = selectedBus['speed'] as double;

          // Very conservative speed changes
          if (random.nextDouble() < 0.2) {
            selectedBus['speed'] =
                (currentSpeed + (random.nextDouble() - 0.5) * 2)
                    .clamp(15.0, 35.0);
          }
        }
      });
    } catch (e) {
      debugPrint('Update error: $e');
      // Continue gracefully
    }
  }

  /// Safe setState that checks mounted status (Flutter 3.27 best practice)
  void _setStateIfMounted(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      setState(fn);
    }
  }

  void _stopTracking() {
    _setStateIfMounted(() {
      _isTracking = false;
    });
    _updateTimer?.cancel();
  }

  void _selectBus(String busId) {
    HapticFeedback.selectionClick();
    _setStateIfMounted(() {
      _selectedBusId = busId;
    });
  }

  /// Safe navigation helper
  void _navigateBack() async {
    if (!mounted || _isDisposed) return;

    try {
      HapticFeedback.lightImpact();

      // Check context validity before navigation (Flutter 3.27)
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Pause tracking when app goes to background
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _stopTracking();
        break;
      case AppLifecycleState.resumed:
        if (mounted && !_isDisposed) {
          _startSafeTracking();
        }
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    // Proper resource cleanup order (Flutter 2025 best practice)
    WidgetsBinding.instance.removeObserver(this);
    _updateTimer?.cancel();
    _fadeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Early return if disposed
    if (_isDisposed) {
      return const Scaffold(
        body: Center(child: Text('Loading...')),
      );
    }

    final selectedBus = _buses[_selectedBusId];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        title: Text(
          'Bus Tracking',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: _navigateBack,
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 4.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                _isTracking ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 6.w,
              ),
              onPressed: _isTracking ? _stopTracking : _startSafeTracking,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // Premium status header with glassmorphism
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.9),
                      primaryColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(cardBorderRadius),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.5.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _isTracking ? Colors.green : Colors.orange,
                                (_isTracking ? Colors.green : Colors.orange)
                                    .withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_isTracking ? Colors.green : Colors.orange)
                                        .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isTracking ? Icons.gps_fixed : Icons.gps_off,
                            color: Colors.white,
                            size: 5.w,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          _isTracking ? 'Tracking Active' : 'Tracking Paused',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Real-time updates every 30 seconds',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Premium bus selection section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Bus to Track',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ...(_buses.values.map((bus) => _buildPremiumBusCard(bus))),
                  ],
                ),
              ),

              // Premium selected bus details
              if (selectedBus != null) ...[
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: _buildPremiumSelectedBusDetails(selectedBus),
                ),
                SizedBox(
                    height: 4.h), // Increased bottom spacing to prevent overlap
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBusCard(Map<String, dynamic> bus) {
    final isSelected = bus['id'] == _selectedBusId;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.05),
                ]
              : [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(
          color: isSelected
              ? primaryColor.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primaryColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            blurRadius: isSelected ? 20 : 8,
            offset: const Offset(0, 4),
            spreadRadius: isSelected ? -2 : 0,
          ),
          if (isSelected)
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 16),
              spreadRadius: -8,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectBus(bus['id']),
          borderRadius: BorderRadius.circular(cardBorderRadius),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isSelected
                          ? [
                              primaryColor,
                              primaryColor.withOpacity(0.8),
                            ]
                          : [
                              Colors.grey.shade400,
                              Colors.grey.shade300,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(7.w),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? primaryColor.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.directions_bus_rounded,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus['name'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? primaryColor : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        bus['route'],
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [
                                  primaryColor.withOpacity(0.15),
                                  primaryColor.withOpacity(0.08),
                                ]
                              : [
                                  Colors.grey.withOpacity(0.1),
                                  Colors.grey.withOpacity(0.05),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? primaryColor.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '${bus['speed'].toStringAsFixed(1)} km/h',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? primaryColor : Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${bus['students']} students',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumSelectedBusDetails(Map<String, dynamic> bus) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.15),
                      primaryColor.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: primaryColor,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Bus Details',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildPremiumDetailRow('Driver', bus['driver'], Icons.person_rounded),
          _buildPremiumDetailRow('Route', bus['route'], Icons.route_rounded),
          _buildPremiumDetailRow(
              'Status', bus['status'].toString().toUpperCase(), Icons.circle),
          _buildPremiumDetailRow('Speed',
              '${bus['speed'].toStringAsFixed(1)} km/h', Icons.speed_rounded),
          _buildPremiumDetailRow(
              'Students', '${bus['students']}', Icons.groups_rounded),
        ],
      ),
    );
  }

  Widget _buildPremiumDetailRow(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.05),
            primaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.15),
                  primaryColor.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 4.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 0.2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
