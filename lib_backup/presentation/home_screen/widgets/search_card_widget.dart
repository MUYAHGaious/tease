import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchCardWidget extends StatefulWidget {
  final Function(String from, String to, DateTime date, TimeOfDay time)?
      onSearch;

  const SearchCardWidget({
    Key? key,
    this.onSearch,
  }) : super(key: key);

  @override
  State<SearchCardWidget> createState() => _SearchCardWidgetState();
}

class _SearchCardWidgetState extends State<SearchCardWidget> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now().replacing(
    hour: TimeOfDay.now().hour,
    minute: TimeOfDay.now().minute + 30,
  );

  final List<String> _cities = [
    'New York',
    'Los Angeles',
    'Chicago',
    'Houston',
    'Phoenix',
    'Philadelphia',
    'San Antonio',
    'San Diego',
    'Dallas',
    'San Jose',
    'Austin',
    'Jacksonville',
    'Fort Worth',
    'Columbus',
    'Charlotte',
    'San Francisco',
    'Indianapolis',
    'Seattle',
    'Denver',
    'Washington DC',
    'Boston',
    'El Paso',
    'Nashville',
    'Detroit',
    'Oklahoma City',
    'Portland',
    'Las Vegas',
    'Memphis',
    'Louisville',
    'Baltimore',
    'Milwaukee',
    'Albuquerque',
    'Tucson',
    'Fresno',
    'Sacramento',
    'Kansas City',
    'Mesa',
    'Atlanta',
    'Colorado Springs',
    'Omaha',
    'Raleigh',
    'Miami',
    'Long Beach',
    'Virginia Beach',
    'Oakland',
    'Minneapolis',
    'Tampa',
    'Tulsa',
    'Arlington',
    'New Orleans'
  ];

  List<String> _getFilteredCities(String query) {
    if (query.isEmpty) return [];
    return _cities
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }

  void _swapLocations() {
    final temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return DatePickerTheme(
          data: DatePickerThemeData(
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            headerBackgroundColor: AppTheme.lightTheme.primaryColor,
            headerForegroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.lightTheme.colorScheme.onPrimary;
              }
              return AppTheme.lightTheme.colorScheme.onSurface;
            }),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.lightTheme.primaryColor;
              }
              return Colors.transparent;
            }),
            todayForegroundColor:
                WidgetStateProperty.all(AppTheme.lightTheme.primaryColor),
            todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
            todayBorder:
                BorderSide(color: AppTheme.lightTheme.primaryColor, width: 1),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _getCurrentLocation() {
    // Mock current location detection
    setState(() {
      _fromController.text = 'Current Location';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where are you going?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // From and To fields with swap button
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildLocationField(
                      controller: _fromController,
                      label: 'From',
                      hint: 'Departure city',
                      showGpsIcon: true,
                    ),
                    SizedBox(height: 1.5.h),
                    _buildLocationField(
                      controller: _toController,
                      label: 'To',
                      hint: 'Destination city',
                    ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              GestureDetector(
                onTap: _swapLocations,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'swap_vert',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Date and Time selection
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'calendar_today',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: GestureDetector(
                  onTap: _selectTime,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'access_time',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                _selectedTime.format(context),
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.5.h),

          // Search button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_fromController.text.isNotEmpty &&
                    _toController.text.isNotEmpty) {
                  widget.onSearch?.call(
                    _fromController.text,
                    _toController.text,
                    _selectedDate,
                    _selectedTime,
                  );
                  Navigator.pushNamed(context, '/seat-selection-screen');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryLight,
                foregroundColor: AppTheme.onSecondaryLight,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Search Buses',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.onSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool showGpsIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: showGpsIcon
                ? GestureDetector(
                    onTap: _getCurrentLocation,
                    child: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: CustomIconWidget(
                        iconName: 'my_location',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  )
                : null,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        if (controller.text.isNotEmpty && _getFilteredCities(controller.text).isNotEmpty) ...[
          SizedBox(height: 0.5.h),
          Container(
            constraints: BoxConstraints(maxHeight: 15.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: _getFilteredCities(controller.text).length,
              itemBuilder: (context, index) {
                final city = _getFilteredCities(controller.text)[index];
                return Container(
                  decoration: BoxDecoration(
                    border: index < _getFilteredCities(controller.text).length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                              width: 0.5,
                            ),
                          )
                        : null,
                  ),
                  child: ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    title: Text(
                      city,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      controller.text = city;
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
}
