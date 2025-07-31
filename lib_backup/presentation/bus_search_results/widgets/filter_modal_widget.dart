import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterModalWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const FilterModalWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersApplied,
  });

  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  late Map<String, dynamic> _filters;
  RangeValues _priceRange = const RangeValues(500, 2000);

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    if (_filters['priceRange'] != null) {
      _priceRange = _filters['priceRange'] as RangeValues;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDepartureTimeSection(),
                  SizedBox(height: 3.h),
                  _buildBusOperatorsSection(),
                  SizedBox(height: 3.h),
                  _buildAmenitiesSection(),
                  SizedBox(height: 3.h),
                  _buildPriceRangeSection(),
                  SizedBox(height: 3.h),
                  _buildBusTypeSection(),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Text(
                'Filter Buses',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: Text(
                  'Clear All',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepartureTimeSection() {
    final timeSlots = [
      {'key': 'early_morning', 'label': 'Early Morning', 'time': '6AM - 12PM'},
      {'key': 'afternoon', 'label': 'Afternoon', 'time': '12PM - 6PM'},
      {'key': 'evening', 'label': 'Evening', 'time': '6PM - 11PM'},
      {'key': 'night', 'label': 'Night', 'time': '11PM - 6AM'},
    ];

    return _buildFilterSection(
      'Departure Time',
      Column(
        children: timeSlots
            .map((slot) => _buildCheckboxTile(
                  slot['label'] as String,
                  slot['time'] as String,
                  _filters['departureTime']?.contains(slot['key']) ?? false,
                  (value) =>
                      _toggleFilter('departureTime', slot['key'] as String),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBusOperatorsSection() {
    final operators = [
      'RedBus Express',
      'VRL Travels',
      'SRS Travels',
      'Orange Tours',
      'Kallada Travels',
      'KPN Travels',
    ];

    return _buildFilterSection(
      'Bus Operators',
      Column(
        children: operators
            .map((operator) => _buildCheckboxTile(
                  operator,
                  null,
                  _filters['operators']?.contains(operator) ?? false,
                  (value) => _toggleFilter('operators', operator),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    final amenities = [
      {'key': 'wifi', 'label': 'WiFi', 'icon': 'wifi'},
      {
        'key': 'charging',
        'label': 'Charging Point',
        'icon': 'battery_charging_full'
      },
      {'key': 'restroom', 'label': 'Restroom', 'icon': 'wc'},
      {'key': 'entertainment', 'label': 'Entertainment', 'icon': 'tv'},
      {
        'key': 'blanket',
        'label': 'Blanket',
        'icon': 'airline_seat_legroom_extra'
      },
      {'key': 'water', 'label': 'Water Bottle', 'icon': 'local_drink'},
    ];

    return _buildFilterSection(
      'Amenities',
      Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: amenities
            .map((amenity) => _buildAmenityChip(
                  amenity['key'] as String,
                  amenity['label'] as String,
                  amenity['icon'] as String,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    return _buildFilterSection(
      'Price Range',
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${_priceRange.start.round()}',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${_priceRange.end.round()}',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          RangeSlider(
            values: _priceRange,
            min: 200,
            max: 3000,
            divisions: 28,
            activeColor: AppTheme.lightTheme.colorScheme.secondary,
            inactiveColor:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
                _filters['priceRange'] = values;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBusTypeSection() {
    final busTypes = [
      'AC Seater',
      'Non-AC Seater',
      'AC Sleeper',
      'Non-AC Sleeper',
      'Volvo AC',
      'Multi-Axle',
    ];

    return _buildFilterSection(
      'Bus Type',
      Column(
        children: busTypes
            .map((type) => _buildCheckboxTile(
                  type,
                  null,
                  _filters['busTypes']?.contains(type) ?? false,
                  (value) => _toggleFilter('busTypes', type),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconColor: AppTheme.lightTheme.colorScheme.secondary,
          collapsedIconColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          children: [
            Padding(
              padding: EdgeInsets.all(4.w),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(
      String title, String? subtitle, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      value: value,
      onChanged: (val) => onChanged(val ?? false),
      activeColor: AppTheme.lightTheme.colorScheme.secondary,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildAmenityChip(String key, String label, String icon) {
    final isSelected = _filters['amenities']?.contains(key) ?? false;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.onSecondary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          SizedBox(width: 1.w),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) => _toggleFilter('amenities', key),
      selectedColor: AppTheme.lightTheme.colorScheme.secondary,
      backgroundColor: AppTheme.lightTheme.cardColor,
      labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
        color: isSelected
            ? AppTheme.lightTheme.colorScheme.onSecondary
            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearAllFilters,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                side:
                    BorderSide(color: AppTheme.lightTheme.colorScheme.outline),
              ),
              child: Text(
                'Clear All',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                widget.onFiltersApplied(_filters);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              ),
              child: Text(
                'Apply Filters',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFilter(String filterType, String value) {
    setState(() {
      _filters[filterType] ??= <String>[];
      final List<String> filterList =
          List<String>.from(_filters[filterType] as List);

      if (filterList.contains(value)) {
        filterList.remove(value);
      } else {
        filterList.add(value);
      }

      _filters[filterType] = filterList;
    });
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _priceRange = const RangeValues(500, 2000);
    });
  }
}
