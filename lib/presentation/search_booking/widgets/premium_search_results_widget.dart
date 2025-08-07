import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PremiumSearchResultsWidget extends StatefulWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> results;
  final Function(Map<String, dynamic>) onResultTap;
  final Function(Map<String, dynamic>) onSaveRoute;
  final Function(Map<String, dynamic>) onShareRoute;
  final Function(Map<String, dynamic>) onPriceAlert;

  const PremiumSearchResultsWidget({
    super.key,
    required this.isLoading,
    required this.results,
    required this.onResultTap,
    required this.onSaveRoute,
    required this.onShareRoute,
    required this.onPriceAlert,
  });

  @override
  State<PremiumSearchResultsWidget> createState() => _PremiumSearchResultsWidgetState();
}

class _PremiumSearchResultsWidgetState extends State<PremiumSearchResultsWidget>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _resultsController;
  late Animation<double> _loadingAnimation;
  late List<AnimationController> _cardControllers;
  late List<Animation<Offset>> _cardAnimations;
  late List<Animation<double>> _fadeAnimations;

  String _sortBy = 'price'; // price, duration, rating, departure

  @override
  void initState() {
    super.initState();
    
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _resultsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    _initializeCardAnimations();
    
    if (widget.isLoading) {
      _loadingController.repeat();
    } else if (widget.results.isNotEmpty) {
      _startResultAnimations();
    }
  }

  void _initializeCardAnimations() {
    _cardControllers = List.generate(
      widget.results.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );

    _cardAnimations = _cardControllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));
    }).toList();

    _fadeAnimations = _cardControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ));
    }).toList();
  }

  void _startResultAnimations() {
    _resultsController.forward();
    
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _cardControllers[i].forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(PremiumSearchResultsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
        if (widget.results.isNotEmpty) {
          _startResultAnimations();
        }
      }
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _resultsController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          // Premium loading animation
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                AnimatedBuilder(
                  animation: _loadingAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _loadingAnimation.value * 2 * math.pi,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.lightTheme.colorScheme.primary,
                                AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                              ],
                              stops: const [0.0, 1.0],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Center icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.directions_bus,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Finding the best buses for you...',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Searching through 100+ operators to get you the best deals',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMediumEmphasisLight,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Loading skeleton cards
          ...List.generate(3, (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedBuilder(
              animation: _loadingAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.grey.shade100,
                        Colors.grey.shade200.withOpacity(_loadingAnimation.value),
                        Colors.grey.shade100,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                );
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSortingHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Icon(
            Icons.sort,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.results.length} buses found',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sort by: ',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMediumEmphasisLight,
                  ),
                ),
                Text(
                  _sortBy.toUpperCase(),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBusCard(Map<String, dynamic> bus, int index) {
    return AnimatedBuilder(
      animation: _cardControllers[index],
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimations[index],
          child: SlideTransition(
            position: _cardAnimations[index],
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onResultTap(bus);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with operator and rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bus['operator'] ?? 'Premium Bus',
                                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.lightTheme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bus['busType'] ?? 'AC Seater',
                                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textMediumEmphasisLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getRatingColor(bus['rating'] ?? 4.0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: _getRatingColor(bus['rating'] ?? 4.0),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    (bus['rating'] ?? 4.0).toStringAsFixed(1),
                                    style: TextStyle(
                                      color: _getRatingColor(bus['rating'] ?? 4.0),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Time and route info
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bus['departure'] ?? '08:00 AM',
                                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textHighEmphasisLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Departure',
                                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textMediumEmphasisLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Journey visualization
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      bus['duration'] ?? '6h 30m',
                                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.lightTheme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(1),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: AppTheme.lightTheme.colorScheme.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Icon(
                                            Icons.directions_bus,
                                            size: 16,
                                            color: AppTheme.lightTheme.colorScheme.primary,
                                          ),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: AppTheme.lightTheme.colorScheme.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    bus['arrival'] ?? '02:30 PM',
                                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textHighEmphasisLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Arrival',
                                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textMediumEmphasisLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Amenities
                        if (bus['amenities'] != null)
                          Container(
                            height: 32,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: (bus['amenities'] as List).length,
                              itemBuilder: (context, amenityIndex) {
                                final amenity = bus['amenities'][amenityIndex];
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightTheme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getAmenityIcon(amenity),
                                        size: 12,
                                        color: AppTheme.lightTheme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        amenity,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.textMediumEmphasisLight,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Price and seats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (bus['originalPrice'] != null) ...[
                                      Text(
                                        '\$${bus['originalPrice'].toStringAsFixed(0)}',
                                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                          decoration: TextDecoration.lineThrough,
                                          color: AppTheme.textMediumEmphasisLight,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      '\$${bus['price'].toStringAsFixed(0)}',
                                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.lightTheme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'per person',
                                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textMediumEmphasisLight,
                                  ),
                                ),
                              ],
                            ),
                            
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _getSeatAvailabilityColor(bus['availableSeats'] ?? 0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${bus['availableSeats']} seats left',
                                style: TextStyle(
                                  color: _getSeatAvailabilityColor(bus['availableSeats'] ?? 0),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.orange;
    return Colors.red;
  }

  Color _getSeatAvailabilityColor(int seats) {
    if (seats > 15) return Colors.green;
    if (seats > 5) return Colors.orange;
    return Colors.red;
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'ac':
        return Icons.ac_unit;
      case 'charging port':
      case 'usb charging':
        return Icons.battery_charging_full;
      case 'entertainment':
      case 'movies':
        return Icons.play_circle;
      case 'meals':
      case 'snacks':
        return Icons.restaurant;
      case 'reading light':
        return Icons.light;
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    if (widget.results.isEmpty) {
      return Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppTheme.textMediumEmphasisLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No buses found',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textHighEmphasisLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria or check different dates',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMediumEmphasisLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSortingHeader(),
        
        // Results list
        ...widget.results.asMap().entries.map((entry) {
          final index = entry.key;
          final bus = entry.value;
          return _buildPremiumBusCard(bus, index);
        }),
        
        SizedBox(height: 10.h),
      ],
    );
  }
}