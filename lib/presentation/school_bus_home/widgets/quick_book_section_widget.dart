import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickBookSectionWidget extends StatefulWidget {
  const QuickBookSectionWidget({super.key});

  @override
  State<QuickBookSectionWidget> createState() => _QuickBookSectionWidgetState();
}

class _QuickBookSectionWidgetState extends State<QuickBookSectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _quickBookOptions = [
    {
      'route': 'Bastos → Nsimeyong',
      'time': '45 min',
      'image':
          'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=400',
      'available': 8,
    },
    {
      'route': 'Université → Etoudi',
      'time': '25 min',
      'image':
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      'available': 12,
    },
    {
      'route': 'Centre Ville → Emombo',
      'time': '35 min',
      'image':
          'https://images.unsplash.com/photo-1565440962783-f87efdea99ce?w=400',
      'available': 5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Book',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryLight,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.secondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 20.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              itemCount: _quickBookOptions.length,
              itemBuilder: (context, index) {
                return _buildQuickBookCard(_quickBookOptions[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBookCard(Map<String, dynamic> option, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      margin: EdgeInsets.only(right: 4.w),
      width: 65.w,
      child: GestureDetector(
        onTap: () => _handleQuickBook(option),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.w),
            child: Stack(
              children: [
                _buildCardImage(option['image']),
                _buildCardGradient(),
                _buildCardContent(option),
                _buildAvailabilityBadge(option['available']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage(String imageUrl) {
    return Positioned.fill(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppTheme.neutralLight.withValues(alpha: 0.3),
            child: Icon(
              Icons.directions_bus,
              size: 15.w,
              color: AppTheme.primaryLight,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardGradient() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(Map<String, dynamic> option) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              option['route'],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppTheme.secondaryLight,
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      option['time'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityBadge(int available) {
    return Positioned(
      top: 3.w,
      right: 3.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
        decoration: BoxDecoration(
          color: available > 5 ? AppTheme.successLight : AppTheme.warningLight,
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: Text(
          '$available seats',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  void _handleQuickBook(Map<String, dynamic> option) {
    final routeParts = option['route'].split(' → ');
    Navigator.pushNamed(context, AppRoutes.busBookingForm, arguments: {
      'from': routeParts[0],
      'to': routeParts[1],
      'preselected': true,
    });
  }
}
