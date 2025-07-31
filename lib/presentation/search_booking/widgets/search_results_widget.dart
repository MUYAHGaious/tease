import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchResultsWidget extends StatefulWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> results;
  final Function(Map<String, dynamic>) onResultTap;
  final Function(Map<String, dynamic>) onSaveRoute;
  final Function(Map<String, dynamic>) onShareRoute;
  final Function(Map<String, dynamic>) onPriceAlert;

  const SearchResultsWidget({
    super.key,
    required this.isLoading,
    required this.results,
    required this.onResultTap,
    required this.onSaveRoute,
    required this.onShareRoute,
    required this.onPriceAlert,
  });

  @override
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget>
    with TickerProviderStateMixin {
  late AnimationController _listController;
  late Animation<double> _listAnimation;

  final List<AnimationController> _itemControllers = [];
  final List<Animation<Offset>> _itemAnimations = [];

  final List<Map<String, dynamic>> _mockResults = [
    {
      "id": 1,
      "operator": "Express Voyage",
      "route": "Douala → Yaoundé",
      "departureTime": "08:30 AM",
      "arrivalTime": "01:00 PM",
      "duration": "4h 30m",
      "price": 6500.00,
      "originalPrice": 7500.00,
      "busType": "AC Sleeper",
      "seatsAvailable": 12,
      "totalSeats": 40,
      "amenities": ["WiFi", "Charging Point", "Entertainment", "Blanket"],
      "rating": 4.5,
      "reviews": 234,
      "image":
          "https://images.pexels.com/photos/1545743/pexels-photo-1545743.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 2,
      "operator": "Cameroon Express",
      "route": "Douala → Yaoundé",
      "departureTime": "10:15 AM",
      "arrivalTime": "02:45 PM",
      "duration": "4h 30m",
      "price": 5500.00,
      "originalPrice": 6500.00,
      "busType": "AC Seater",
      "seatsAvailable": 8,
      "totalSeats": 50,
      "amenities": ["WiFi", "Charging Point", "Water Bottle"],
      "rating": 4.2,
      "reviews": 189,
      "image":
          "https://images.pexels.com/photos/1098365/pexels-photo-1098365.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 3,
      "operator": "Central Voyages",
      "route": "Douala → Yaoundé",
      "departureTime": "02:30 PM",
      "arrivalTime": "07:15 PM",
      "duration": "4h 45m",
      "price": 6000.00,
      "originalPrice": 7000.00,
      "busType": "Non-AC Sleeper",
      "seatsAvailable": 15,
      "totalSeats": 35,
      "amenities": ["WiFi", "Entertainment", "Snacks", "Reading Light"],
      "rating": 4.3,
      "reviews": 156,
      "image":
          "https://images.pexels.com/photos/1098364/pexels-photo-1098364.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
    {
      "id": 4,
      "operator": "Guaranty Express",
      "route": "Douala → Yaoundé",
      "departureTime": "06:00 PM",
      "arrivalTime": "10:45 PM",
      "duration": "4h 45m",
      "price": 8000.00,
      "originalPrice": 9000.00,
      "busType": "Volvo AC",
      "seatsAvailable": 6,
      "totalSeats": 45,
      "amenities": [
        "WiFi",
        "Charging Point",
        "Entertainment",
        "Blanket",
        "Pillow",
        "Snacks"
      ],
      "rating": 4.7,
      "reviews": 298,
      "image":
          "https://images.pexels.com/photos/1098366/pexels-photo-1098366.jpeg?auto=compress&cs=tinysrgb&w=800"
    },
  ];

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Curves.easeOut,
    ));

    _initializeItemAnimations();

    if (!widget.isLoading) {
      _listController.forward();
    }
  }

  void _initializeItemAnimations() {
    final results = widget.results.isNotEmpty ? widget.results : _mockResults;

    for (int i = 0; i < results.length; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 300 + (i * 100)),
        vsync: this,
      );

      final animation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));

      _itemControllers.add(controller);
      _itemAnimations.add(animation);
    }
  }

  @override
  void didUpdateWidget(SearchResultsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading && oldWidget.isLoading) {
      _listController.forward();
      _animateItems();
    }
  }

  void _animateItems() {
    for (int i = 0; i < _itemControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _itemControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildSkeletonLoader();
    }

    final results = widget.results.isNotEmpty ? widget.results : _mockResults;

    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _listAnimation,
          child: ListView.separated(
            padding: EdgeInsets.all(4.w),
            itemCount: results.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              if (index < _itemAnimations.length) {
                return SlideTransition(
                  position: _itemAnimations[index],
                  child: _buildResultCard(results[index], index),
                );
              }
              return _buildResultCard(results[index], index);
            },
          ),
        );
      },
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      itemCount: 4,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40.w,
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: 25.w,
                      height: 1.5.h,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 15.w,
                height: 3.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: List.generate(
                4,
                (index) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index < 3 ? 2.w : 0),
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result, int index) {
    return Dismissible(
      key: Key('result_${result["id"]}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'bookmark',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Save Route',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        widget.onSaveRoute(result);
      },
      child: GestureDetector(
        onTap: () => widget.onResultTap(result),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Row
              Row(
                children: [
                  // Bus Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImageWidget(
                      imageUrl: result["image"] as String,
                      width: 15.w,
                      height: 15.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 3.w),

                  // Operator Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result["operator"] as String,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'star',
                              color: AppTheme.lightTheme.colorScheme.secondary,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${result["rating"]} (${result["reviews"]} reviews)',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textMediumEmphasisLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (result["originalPrice"] != result["price"])
                        Text(
                          '${(result["originalPrice"] as double).toStringAsFixed(0)} XAF',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMediumEmphasisLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        '${(result["price"] as double).toStringAsFixed(0)} XAF',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Time and Duration Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result["departureTime"] as String,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Departure',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMediumEmphasisLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result["duration"] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          result["arrivalTime"] as String,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Arrival',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMediumEmphasisLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Bus Type and Seats Row
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      result["busType"] as String,
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(width: 2.w),

                  CustomIconWidget(
                    iconName: 'event_seat',
                    color: result["seatsAvailable"] > 10
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.error,
                    size: 14,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${result["seatsAvailable"]}/${result["totalSeats"]} seats',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: result["seatsAvailable"] > 10
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  // Quick Actions
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => widget.onShareRoute(result),
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme
                                .lightTheme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: CustomIconWidget(
                            iconName: 'share',
                            color: AppTheme.textMediumEmphasisLight,
                            size: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      GestureDetector(
                        onTap: () => widget.onPriceAlert(result),
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme
                                .lightTheme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: CustomIconWidget(
                            iconName: 'notifications',
                            color: AppTheme.textMediumEmphasisLight,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Amenities
              if ((result["amenities"] as List).isNotEmpty) ...[
                SizedBox(height: 1.5.h),
                Wrap(
                  spacing: 1.w,
                  runSpacing: 0.5.h,
                  children:
                      (result["amenities"] as List).take(4).map((amenity) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        amenity as String,
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.textMediumEmphasisLight,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
