import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

/// Modern, crash-proof bus tracking implementation following Flutter 3.27 best practices
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
            selectedBus['speed'] = (currentSpeed + (random.nextDouble() - 0.5) * 2)
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Bus Tracking'),
        backgroundColor: const Color(0xFF1a4d3a),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateBack,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTracking ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: _isTracking ? _stopTracking : _startSafeTracking,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // Status header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a4d3a),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isTracking ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _isTracking ? Icons.gps_fixed : Icons.gps_off,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isTracking ? 'Tracking Active' : 'Tracking Paused',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Updates every 30 seconds',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bus selection
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Bus to Track',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a4d3a),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...(_buses.values.map((bus) => _buildBusCard(bus))),
                  ],
                ),
              ),
              
              // Selected bus details
              if (selectedBus != null) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildSelectedBusDetails(selectedBus),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusCard(Map<String, dynamic> bus) {
    final isSelected = bus['id'] == _selectedBusId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected ? const Color(0xFF1a4d3a).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: () => _selectBus(bus['id']),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1a4d3a) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.directions_bus,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFF1a4d3a) : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bus['route'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${bus['speed'].toStringAsFixed(1)} km/h',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF1a4d3a) : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bus['students']} students',
                      style: TextStyle(
                        fontSize: 12,
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

  Widget _buildSelectedBusDetails(Map<String, dynamic> bus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Color(0xFF1a4d3a),
            ),
            const SizedBox(width: 8),
            const Text(
              'Bus Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1a4d3a),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailRow('Driver', bus['driver']),
        _buildDetailRow('Route', bus['route']),
        _buildDetailRow('Status', bus['status'].toString().toUpperCase()),
        _buildDetailRow('Speed', '${bus['speed'].toStringAsFixed(1)} km/h'),
        _buildDetailRow('Students', '${bus['students']}'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}