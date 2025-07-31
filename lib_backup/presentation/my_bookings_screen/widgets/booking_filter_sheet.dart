import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BookingFilterSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const BookingFilterSheet({
    Key? key,
    required this.currentFilters,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  State<BookingFilterSheet> createState() => _BookingFilterSheetState();
}

class _BookingFilterSheetState extends State<BookingFilterSheet> {
  late Map<String, dynamic> _filters;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    if (_filters['dateRange'] != null) {
      _selectedDateRange = _filters['dateRange'] as DateTimeRange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangeSection(context),
                  SizedBox(height: 3.h),
                  _buildStatusSection(context),
                  SizedBox(height: 3.h),
                  _buildRouteSection(context),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter Bookings',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.textSecondaryLight,
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: _selectDateRange,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.dividerLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDateRange != null
                      ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                      : 'Select date range',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: _selectedDateRange != null
                        ? AppTheme.textPrimaryLight
                        : AppTheme.textDisabledLight,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: AppTheme.primaryLight,
                  size: 5.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    final List<String> statuses = [
      'All',
      'Confirmed',
      'Pending',
      'Completed',
      'Cancelled'
    ];
    final String selectedStatus = _filters['status'] ?? 'All';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Status',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: statuses.map((status) {
            final bool isSelected = selectedStatus == status;
            return FilterChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filters['status'] = selected ? status : 'All';
                });
              },
              backgroundColor: AppTheme.lightTheme.cardColor,
              selectedColor: AppTheme.primaryLight.withValues(alpha: 0.1),
              labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? AppTheme.primaryLight
                    : AppTheme.textPrimaryLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color:
                    isSelected ? AppTheme.primaryLight : AppTheme.dividerLight,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRouteSection(BuildContext context) {
    final List<String> routes = [
      'All Routes',
      'New York - Boston',
      'Los Angeles - San Francisco',
      'Chicago - Detroit',
      'Miami - Orlando',
      'Seattle - Portland',
    ];
    final String selectedRoute = _filters['route'] ?? 'All Routes';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.dividerLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedRoute,
              isExpanded: true,
              items: routes.map((route) {
                return DropdownMenuItem<String>(
                  value: route,
                  child: Text(
                    route,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _filters['route'] = value;
                });
              },
              icon: CustomIconWidget(
                iconName: 'keyboard_arrow_down',
                color: AppTheme.primaryLight,
                size: 6.w,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearFilters,
              child: Text('Clear All'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryLight,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _filters['dateRange'] = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _filters.clear();
      _selectedDateRange = null;
    });
  }

  void _applyFilters() {
    widget.onFiltersApplied(_filters);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
