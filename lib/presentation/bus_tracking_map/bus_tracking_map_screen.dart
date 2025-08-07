import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../core/app_export.dart';
import './widgets/bus_marker_widget.dart';
import './widgets/student_marker_widget.dart';
import './widgets/tracking_control_panel.dart';
import './widgets/bus_info_card.dart';
import './widgets/student_eta_panel.dart';

class BusTrackingMapScreen extends StatefulWidget {
  const BusTrackingMapScreen({super.key});

  @override
  State<BusTrackingMapScreen> createState() => _BusTrackingMapScreenState();
}

class _BusTrackingMapScreenState extends State<BusTrackingMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _mapController;
  late AnimationController _panelController;
  late Animation<double> _mapAnimation;
  late Animation<Offset> _panelAnimation;

  Timer? _locationUpdateTimer;
  bool _isTracking = false;
  String _selectedBusId = 'bus_1';
  bool _showStudentMarkers = false; // Disabled by default for better mobile performance
  bool _showETAPanel = false;

  // Mock GPS coordinates (using a local area for demo)
  final Map<String, Map<String, dynamic>> _buses = {
    'bus_1': {
      'id': 'bus_1',
      'name': 'School Bus A',
      'driver': 'John Smith',
      'route': 'Route 1 - North District',
      'capacity': 45,
      'currentStudents': 32,
      'lat': 40.7128,
      'lng': -74.0060,
      'speed': 25.5,
      'heading': 45.0,
      'status': 'active',
      'nextStop': 'Maple Street Station',
      'etaToNextStop': 8,
    },
    'bus_2': {
      'id': 'bus_2',
      'name': 'School Bus B',
      'driver': 'Sarah Johnson',
      'route': 'Route 2 - South District',
      'capacity': 45,
      'currentStudents': 28,
      'lat': 40.7589,
      'lng': -73.9851,
      'speed': 18.2,
      'heading': 120.0,
      'status': 'active',
      'nextStop': 'Oak Avenue Stop',
      'etaToNextStop': 12,
    },
  };

  final List<Map<String, dynamic>> _students = [
    {
      'id': 'student_1',
      'name': 'Emma Wilson',
      'grade': '5th Grade',
      'busId': 'bus_1',
      'lat': 40.7138,
      'lng': -74.0070,
      'distanceToBus': 0.8,
      'etaToBus': 3,
      'status': 'walking',
      'parentPhone': '+1 (555) 123-4567',
    },
    {
      'id': 'student_2',
      'name': 'Liam Thompson',
      'grade': '3rd Grade',
      'busId': 'bus_1',
      'lat': 40.7118,
      'lng': -74.0050,
      'distanceToBus': 1.2,
      'etaToBus': 5,
      'status': 'at_stop',
      'parentPhone': '+1 (555) 234-5678',
    },
    {
      'id': 'student_3',
      'name': 'Olivia Davis',
      'grade': '4th Grade',
      'busId': 'bus_1',
      'lat': 40.7108,
      'lng': -74.0040,
      'distanceToBus': 2.1,
      'etaToBus': 8,
      'status': 'approaching',
      'parentPhone': '+1 (555) 345-6789',
    },
    {
      'id': 'student_4',
      'name': 'Noah Martinez',
      'grade': '6th Grade',
      'busId': 'bus_2',
      'lat': 40.7599,
      'lng': -73.9841,
      'distanceToBus': 0.5,
      'etaToBus': 2,
      'status': 'at_stop',
      'parentPhone': '+1 (555) 456-7890',
    },
    {
      'id': 'student_5',
      'name': 'Ava Garcia',
      'grade': '2nd Grade',
      'busId': 'bus_2',
      'lat': 40.7579,
      'lng': -73.9861,
      'distanceToBus': 1.8,
      'etaToBus': 7,
      'status': 'walking',
      'parentPhone': '+1 (555) 567-8901',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Mobile-optimized: Minimal animations for stability
    _mapController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _panelController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _mapAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mapController,
      curve: Curves.easeOut,
    ));

    _panelAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOut,
    ));

    // Start immediately for mobile
    _mapController.forward();
    _panelController.forward();

    // Start tracking after UI settles (mobile-friendly delay)
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && context.mounted) {
        _startLocationTracking();
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _panelController.dispose();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  void _startLocationTracking() {
    setState(() {
      _isTracking = true;
    });

    // Mobile-optimized: Very conservative update frequency
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted && _isTracking && context.mounted) {
        try {
          _updateBusLocations();
          // Only update student ETAs every other cycle to reduce load
          if (DateTime.now().second % 40 == 0) {
            _updateStudentETAs();
          }
        } catch (e) {
          // Fail silently on mobile to prevent crashes
          debugPrint('Update error: $e');
        }
      }
    });
  }

  void _stopLocationTracking() {
    setState(() {
      _isTracking = false;
    });
    _locationUpdateTimer?.cancel();
  }

  void _updateBusLocations() {
    if (!_isTracking || !mounted || !context.mounted) return;

    // Mobile-optimized: Minimal state updates
    try {
      if (mounted) {
        setState(() {
          // Only update the selected bus to reduce processing
          final selectedBus = _buses[_selectedBusId];
          if (selectedBus != null) {
            final random = math.Random();
            final speedKmh = selectedBus['speed'] as double;
            
            // Ultra-simplified movement - just tiny random changes
            selectedBus['lat'] = (selectedBus['lat'] as double) + (random.nextDouble() - 0.5) * 0.0001;
            selectedBus['lng'] = (selectedBus['lng'] as double) + (random.nextDouble() - 0.5) * 0.0001;
            
            // Very occasional speed updates
            if (random.nextDouble() < 0.1) {
              selectedBus['speed'] = (speedKmh + (random.nextDouble() - 0.5)).clamp(20.0, 30.0);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Bus update error: $e');
    }
  }

  void _updateStudentETAs() {
    if (!_isTracking || !mounted) return;

    if (mounted) {
      setState(() {
        // Process only students for selected bus to reduce calculations
        final studentsForBus = _students.where((s) => s['busId'] == _selectedBusId);
        for (var student in studentsForBus) {
          final busId = student['busId'] as String;
          final bus = _buses[busId];
          if (bus != null) {
            // Simplified distance calculation for mobile performance
            final studentLat = student['lat'] as double;
            final studentLng = student['lng'] as double;
            final busLat = bus['lat'] as double;
            final busLng = bus['lng'] as double;
            
            // Approximate distance without complex trigonometry
            final latDiff = (studentLat - busLat).abs();
            final lngDiff = (studentLng - busLng).abs();
            final distance = (latDiff + lngDiff) * 111.0; // Rough km approximation
            
            student['distanceToBus'] = distance;
            student['etaToBus'] = (distance / 5.0 * 60).round().clamp(1, 30);
            
            // Simplified status updates
            if (distance < 0.1) {
              student['status'] = 'at_stop';
            } else if (distance < 0.5) {
              student['status'] = 'approaching';
            } else {
              student['status'] = 'walking';
            }
          }
        }
      });
    }
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadiusKm = 6371.0;
    
    final double dLat = (lat2 - lat1) * math.pi / 180;
    final double dLng = (lng2 - lng1) * math.pi / 180;
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadiusKm * c;
  }

  List<Map<String, dynamic>> _getStudentsForBus(String busId) {
    return _students.where((student) => student['busId'] == busId).toList();
  }

  void _toggleStudentMarkers() {
    setState(() {
      _showStudentMarkers = !_showStudentMarkers;
    });
    HapticFeedback.lightImpact();
  }

  void _toggleETAPanel() {
    setState(() {
      _showETAPanel = !_showETAPanel;
    });
    HapticFeedback.lightImpact();
  }

  void _selectBus(String busId) {
    setState(() {
      _selectedBusId = busId;
    });
    HapticFeedback.selectionClick();
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              'Bus Tracking',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _toggleETAPanel,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: _showETAPanel
                    ? AppTheme.lightTheme.colorScheme.primary
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.schedule,
                color: _showETAPanel
                    ? Colors.white
                    : AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockMap(BuildContext context) {
    // Mobile-optimized: Ultra-lightweight map
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(
          color: Colors.green.shade300,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Simple grid background
          Container(
            color: Colors.green.shade50,
            child: CustomPaint(
              painter: SimplGridPainter(),
              size: Size.infinite,
            ),
          ),
          
          // Show only selected bus and one other to reduce load
          ...[
            _buses[_selectedBusId],
            _buses.values.firstWhere((bus) => bus['id'] != _selectedBusId, orElse: () => _buses.values.first)
          ].where((bus) => bus != null).map((bus) {
            final index = bus!['id'] == _selectedBusId ? 0 : 1;
            return Positioned(
              left: 80.0 + (index * 160.0),
              top: 120.0 + (index * 100.0),
              child: BusMarkerWidget(
                bus: bus,
                isSelected: bus['id'] == _selectedBusId,
                onTap: () => _selectBus(bus['id']),
              ),
            );
          }),
          
          // Show student markers only if enabled and for selected bus
          if (_showStudentMarkers)
            ..._students.where((student) => student['busId'] == _selectedBusId)
                .take(2) // Limit to 2 students max
                .map((student) {
              final index = _students.indexOf(student);
              return Positioned(
                left: 120.0 + (index * 80.0),
                top: 200.0 + (index * 60.0),
                child: StudentMarkerWidget(
                  student: student,
                  onTap: () => _showStudentDetails(student),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showStudentDetails(Map<String, dynamic> student) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'],
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        student['grade'],
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMediumEmphasisLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(student['status']).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(student['status']),
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(student['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${student['distanceToBus'].toStringAsFixed(1)} km',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Distance',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMediumEmphasisLight,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${student['etaToBus']} min',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.secondary,
                      ),
                    ),
                    Text(
                      'ETA',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMediumEmphasisLight,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      student['parentPhone'],
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Parent Contact',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMediumEmphasisLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'at_stop':
        return Colors.green;
      case 'approaching':
        return Colors.orange;
      case 'walking':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'at_stop':
        return 'At Stop';
      case 'approaching':
        return 'Approaching';
      case 'walking':
        return 'Walking';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedBus = _buses[_selectedBusId];
    final studentsForBus = _getStudentsForBus(_selectedBusId);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // App Bar
                  FadeTransition(
                    opacity: _mapAnimation,
                    child: _buildAppBar(),
                  ),
                  
                  // Map Container
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: FadeTransition(
                          opacity: _mapAnimation,
                          child: _buildMockMap(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Control Panel
              SlideTransition(
                position: _panelAnimation,
                child: TrackingControlPanel(
                  isTracking: _isTracking,
                  showStudentMarkers: _showStudentMarkers,
                  buses: _buses,
                  selectedBusId: _selectedBusId,
                  onTrackingToggle: _isTracking ? _stopLocationTracking : _startLocationTracking,
                  onStudentMarkersToggle: _toggleStudentMarkers,
                  onBusSelected: _selectBus,
                ),
              ),
              
              // Bus Info Card
              if (selectedBus != null)
                Positioned(
                  bottom: 2.h,
                  left: 4.w,
                  right: 4.w,
                  child: FadeTransition(
                    opacity: _mapAnimation,
                    child: BusInfoCard(
                      bus: selectedBus,
                      studentCount: studentsForBus.length,
                    ),
                  ),
                ),
              
              // Student ETA Panel
              if (_showETAPanel)
                StudentETAPanel(
                  students: studentsForBus,
                  onClose: _toggleETAPanel,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple grid painter for mobile performance
class SimplGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.1)
      ..strokeWidth = 0.5;

    // Draw only a few grid lines to suggest a map
    for (int i = 0; i < 4; i++) {
      final x = (size.width / 4) * i;
      final y = (size.height / 4) * i;
      
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}