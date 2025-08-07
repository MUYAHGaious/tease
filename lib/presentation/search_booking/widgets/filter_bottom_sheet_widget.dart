import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersApplied,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic> _filters = {};
  int _resultCount = 24;

  final List<String> _departureTimeSlots = [
    'Early Morning (6AM - 10AM)',
    'Morning (10AM - 2PM)',
    'Afternoon (2PM - 6PM)',
    'Evening (6PM - 10PM)',
    'Night (10PM - 6AM)',
  ];

  final List<String> _busTypes = [
    'AC Sleeper',
    'Non-AC Sleeper',
    'AC Seater',
    'Non-AC Seater',
    'Volvo',
    'Multi-Axle',
  ];

  final List<String> _amenities = [
    'WiFi',
    'Charging Point',
    'Entertainment',
    'Blanket',
    'Pillow',
    'Water Bottle',
    'Snacks',
    'Reading Light',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
    _updateResultCount();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _updateResultCount() {
    // Mock result count based on filters
    int count = 24;
    if (_filters['departureTime'] != null &&
        (_filters['departureTime'] as List).isNotEmpty) {
      count = (count * 0.7).round();
    }
    if (_filters['busType'] != null &&
        (_filters['busType'] as List).isNotEmpty) {
      count = (count * 0.8).round();
    }
    if (_filters['priceRange'] != null) {
      count = (count * 0.6).round();
    }
    if (_filters['amenities'] != null &&
        (_filters['amenities'] as List).isNotEmpty) {
      count = (count * 0.5).round();
    }

    setState(() {
      _resultCount = count.clamp(3, 24);
    });
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _resultCount = 24;
    });
  }

  void _applyFilters() {
    widget.onFiltersApplied(_filters);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: 85.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 2.h),
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Routes',
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: Text(
                      'Clear All',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDepartureTimeSection(),
                    SizedBox(height: 3.h),
                    _buildBusTypeSection(),
                    SizedBox(height: 3.h),
                    _buildPriceRangeSection(),
                    SizedBox(height: 3.h),
                    _buildAmenitiesSection(),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_resultCount routes found',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Tap to view results',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMediumEmphasisLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartureTimeSection() {
    return _buildFilterSection(
      title: 'Departure Time',
      icon: 'schedule',
      child: Column(
        children: _departureTimeSlots.map((timeSlot) {
          final isSelected =
              (_filters['departureTime'] as List?)?.contains(timeSlot) ?? false;
          return _buildCheckboxTile(
            title: timeSlot,
            isSelected: isSelected,
            onChanged: (value) {
              setState(() {
                _filters['departureTime'] ??= <String>[];
                final list = _filters['departureTime'] as List<String>;
                if (value == true) {
                  list.add(timeSlot);
                } else {
                  list.remove(timeSlot);
                }
                _updateResultCount();
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBusTypeSection() {
    return _buildFilterSection(
      title: 'Bus Type',
      icon: 'directions_bus',
      child: Column(
        children: _busTypes.map((busType) {
          final isSelected =
              (_filters['busType'] as List?)?.contains(busType) ?? false;
          return _buildCheckboxTile(
            title: busType,
            isSelected: isSelected,
            onChanged: (value) {
              setState(() {
                _filters['busType'] ??= <String>[];
                final list = _filters['busType'] as List<String>;
                if (value == true) {
                  list.add(busType);
                } else {
                  list.remove(busType);
                }
                _updateResultCount();
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    final currentRange =
        _filters['priceRange'] as RangeValues? ?? const RangeValues(20, 100);

    return _buildFilterSection(
      title: 'Price Range',
      icon: 'attach_money',
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${currentRange.start.round()}',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${currentRange.end.round()}',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          RangeSlider(
            values: currentRange,
            min: 15,
            max: 150,
            divisions: 27,
            onChanged: (RangeValues values) {
              setState(() {
                _filters['priceRange'] = values;
                _updateResultCount();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return _buildFilterSection(
      title: 'Amenities',
      icon: 'star',
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: _amenities.map((amenity) {
          final isSelected =
              (_filters['amenities'] as List?)?.contains(amenity) ?? false;
          return FilterChip(
            label: Text(amenity),
            selected: isSelected,
            onSelected: (value) {
              setState(() {
                _filters['amenities'] ??= <String>[];
                final list = _filters['amenities'] as List<String>;
                if (value) {
                  list.add(amenity);
                } else {
                  list.remove(amenity);
                }
                _updateResultCount();
              });
            },
            backgroundColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            selectedColor:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
            checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
            labelStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required String icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        leading: CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        ),
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool isSelected,
    required Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium,
      ),
      value: isSelected,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
