import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/floating_back_to_top_button.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _listAnimation;
  late ScrollController _scrollController;

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Completed', 'Cancelled', 'Upcoming'];

  final List<Map<String, dynamic>> _trips = [
    {
      'id': 'TRP001',
      'route': 'Douala → Yaoundé',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'departureTime': '08:30 AM',
      'arrivalTime': '12:45 PM',
      'busOperator': 'Express Voyageur',
      'seatNumber': 'A12',
      'amount': 'XFA 3,500',
      'status': 'completed',
      'rating': 4.5,
      'bookingRef': 'BK001234',
      'passengers': 1,
      'busType': 'VIP',
      'duration': '4h 15m',
    },
    {
      'id': 'TRP002',
      'route': 'Bamenda → Kumba',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'departureTime': '02:00 PM',
      'arrivalTime': '05:30 PM',
      'busOperator': 'Guarantee Express',
      'seatNumber': 'B08',
      'amount': 'XFA 2,800',
      'status': 'completed',
      'rating': 5.0,
      'bookingRef': 'BK001235',
      'passengers': 2,
      'busType': 'Standard',
      'duration': '3h 30m',
    },
    {
      'id': 'TRP003',
      'route': 'Yaoundé → Garoua',
      'date': DateTime.now().subtract(const Duration(days: 14)),
      'departureTime': '06:00 AM',
      'arrivalTime': '02:30 PM',
      'busOperator': 'Central Express',
      'seatNumber': 'C05',
      'amount': 'XFA 5,200',
      'status': 'cancelled',
      'rating': 0.0,
      'bookingRef': 'BK001236',
      'passengers': 1,
      'busType': 'VIP',
      'duration': '8h 30m',
    },
    {
      'id': 'TRP004',
      'route': 'Limbe → Beau',
      'date': DateTime.now().add(const Duration(days: 3)),
      'departureTime': '09:15 AM',
      'arrivalTime': '01:45 PM',
      'busOperator': 'Coastal Express',
      'seatNumber': 'A06',
      'amount': 'XFA 4,100',
      'status': 'upcoming',
      'rating': 0.0,
      'bookingRef': 'BK001237',
      'passengers': 1,
      'busType': 'Premium',
      'duration': '4h 30m',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: _filters.length, vsync: this);
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _listAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTrips {
    if (_selectedFilter == 'All') return _trips;
    return _trips.where((trip) => trip['status'] == _selectedFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSophisticatedAppBar(),
              _buildStatsOverview(),
              _buildFilterTabs(),
              _buildTripsList(),
            ],
          ),
          FloatingBackToTopButton(
            scrollController: _scrollController,
            showOffset: 300.0,
          ),
        ],
      ),
    );
  }

  Widget _buildSophisticatedAppBar() {
    return SliverAppBar(
      expandedHeight: 18.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1A4A47),
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _headerAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * _headerAnimation.value),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A4A47),
                      Color(0xFF2A5D5A),
                      Color(0xFF1A4A47),
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(3.w),
                                ),
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: CustomIconWidget(
                                    iconName: 'arrow_back',
                                    color: Colors.white,
                                    size: 6.w,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(3.w),
                                ),
                                child: IconButton(
                                  onPressed: _showSearchDialog,
                                  icon: CustomIconWidget(
                                    iconName: 'search',
                                    color: Colors.white,
                                    size: 6.w,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          FadeTransition(
                            opacity: _headerAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC8E53F).withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(2.w),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'history',
                                        color: const Color(0xFFC8E53F),
                                        size: 4.w,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        'Travel History',
                                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Your Journey\\nMemories',
                                  style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Track and manage all your past and upcoming trips',
                                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      leading: Container(),
    );
  }

  Widget _buildStatsOverview() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Expanded(child: _buildStatCard('Total Trips', '${_trips.length}', 'route', Colors.blue)),
            SizedBox(width: 3.w),
            Expanded(child: _buildStatCard('Completed', '${_trips.where((t) => t['status'] == 'completed').length}', 'check_circle', Colors.green)),
            SizedBox(width: 3.w),
            Expanded(child: _buildStatCard('Upcoming', '${_trips.where((t) => t['status'] == 'upcoming').length}', 'schedule', Colors.orange)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String icon, Color color) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.w),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.map((filter) {
              final isSelected = _selectedFilter == filter;
              return Container(
                margin: EdgeInsets.only(right: 2.w),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    borderRadius: BorderRadius.circular(3.w),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  AppTheme.lightTheme.colorScheme.primary,
                                  AppTheme.lightTheme.colorScheme.primaryContainer,
                                ],
                              )
                            : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(3.w),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: isSelected ? 8 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        filter,
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTripsList() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      sliver: AnimatedBuilder(
        animation: _listAnimation,
        builder: (context, child) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final trip = _filteredTrips[index];
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _listAnimation.value)),
                  child: Opacity(
                    opacity: _listAnimation.value,
                    child: _buildSophisticatedTripCard(trip, index),
                  ),
                );
              },
              childCount: _filteredTrips.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSophisticatedTripCard(Map<String, dynamic> trip, int index) {
    final status = trip['status'] as String;
    final statusColor = _getStatusColor(status);
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTripDetails(trip),
          borderRadius: BorderRadius.circular(4.w),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.w),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        trip['bookingRef'],
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  
                  // Route and Time
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip['route'],
                              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'schedule',
                                  color: AppTheme.lightTheme.colorScheme.primary,
                                  size: 4.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '${trip['departureTime']} - ${trip['arrivalTime']}',
                                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            trip['amount'],
                            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(1.w),
                            ),
                            child: Text(
                              trip['busType'],
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Details Row
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Row(
                      children: [
                        _buildDetailItem('date', _formatTripDate(trip['date']), 'Date'),
                        const Spacer(),
                        _buildDetailItem('event_seat', trip['seatNumber'], 'Seat'),
                        const Spacer(),
                        _buildDetailItem('directions_bus', trip['busOperator'], 'Operator'),
                        if (status == 'completed' && trip['rating'] > 0) ...[
                          const Spacer(),
                          _buildRatingItem(trip['rating']),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String icon, String value, String label) {
    return Column(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontSize: 9,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRatingItem(double rating) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return CustomIconWidget(
              iconName: index < rating.floor() ? 'star' : 'star_border',
              color: Colors.amber,
              size: 3.w,
            );
          }),
        ),
        SizedBox(height: 0.5.h),
        Text(
          rating.toString(),
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
        Text(
          'Rating',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'upcoming':
        return Colors.orange;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _formatTripDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 0) {
      return 'In ${(-difference.inDays)} days';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _showTripDetails(Map<String, dynamic> trip) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTripDetailsSheet(trip),
    );
  }

  Widget _buildTripDetailsSheet(Map<String, dynamic> trip) {
    return Container(
      height: 85.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip Details',
                    style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  // Trip details content would go here
                  Text(
                    'Complete trip details coming soon...',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    // Implementation for search functionality
  }
}