import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CitySearchWidget extends StatelessWidget {
  final String fromCity;
  final String toCity;
  final TextEditingController fromCityController;
  final TextEditingController toCityController;
  final FocusNode fromCityFocusNode;
  final FocusNode toCityFocusNode;
  final bool showFromCitySuggestions;
  final bool showToCitySuggestions;
  final Function(String, bool) onCitySelected;
  final VoidCallback onSwapCities;

  const CitySearchWidget({
    super.key,
    required this.fromCity,
    required this.toCity,
    required this.fromCityController,
    required this.toCityController,
    required this.fromCityFocusNode,
    required this.toCityFocusNode,
    required this.showFromCitySuggestions,
    required this.showToCitySuggestions,
    required this.onCitySelected,
    required this.onSwapCities,
  });

  // Mock city data
  static final List<Map<String, dynamic>> _mockCities = [
    {
      'name': 'New York',
      'code': 'NYC',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Los Angeles',
      'code': 'LAX',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Chicago',
      'code': 'CHI',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Houston',
      'code': 'HOU',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Phoenix',
      'code': 'PHX',
      'country': 'United States',
      'popular': false,
    },
    {
      'name': 'Philadelphia',
      'code': 'PHL',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'San Antonio',
      'code': 'SAT',
      'country': 'United States',
      'popular': false,
    },
    {
      'name': 'San Diego',
      'code': 'SAN',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Dallas',
      'code': 'DAL',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'San Jose',
      'code': 'SJC',
      'country': 'United States',
      'popular': false,
    },
    {
      'name': 'Austin',
      'code': 'AUS',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Jacksonville',
      'code': 'JAX',
      'country': 'United States',
      'popular': false,
    },
    {
      'name': 'Fort Worth',
      'code': 'FTW',
      'country': 'United States',
      'popular': false,
    },
    {
      'name': 'Columbus',
      'code': 'CMH',
      'country': 'United States',
      'popular': false,
    },
    {
      'name': 'Indianapolis',
      'code': 'IND',
      'country': 'United States',
      'popular': false,
    },
    {
      'name': 'Charlotte',
      'code': 'CLT',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'San Francisco',
      'code': 'SFO',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Seattle',
      'code': 'SEA',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Denver',
      'code': 'DEN',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Washington DC',
      'code': 'WAS',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Boston',
      'code': 'BOS',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'El Paso',
      'code': 'ELP',
      'country': 'United States',
      'popular': false,
    },
    {
      'name': 'Detroit',
      'code': 'DTT',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Nashville',
      'code': 'BNA',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Portland',
      'code': 'PDX',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Oklahoma City',
      'code': 'OKC',
      'country': 'United States',
      'popular': false,
    },
    {
      'name': 'Las Vegas',
      'code': 'LAS',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Louisville',
      'code': 'SDF',
      'country': 'United States',
      'popular': false,
    },
    {
      'name': 'Baltimore',
      'code': 'BWI',
      'country': 'United States',
      'popular': true,
    },
    {
      'name': 'Milwaukee',
      'code': 'MKE',
      'country': 'United States',
      'popular': false,
    },
  ];

  List<Map<String, dynamic>> _getFilteredCities(String query) {
    if (query.isEmpty) {
      return _mockCities.where((city) => city['popular'] == true).toList();
    }

    return _mockCities.where((city) {
      final name = (city['name'] as String).toLowerCase();
      final code = (city['code'] as String).toLowerCase();
      final queryLower = query.toLowerCase();
      return name.contains(queryLower) || code.contains(queryLower);
    }).toList();
  }

  Widget _buildCityField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focusNode.hasFocus
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: focusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 3.w, 4.w, 1.w),
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.w),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textMediumEmphasisLight,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTap: () {
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapButton() {
    return GestureDetector(
      onTap: onSwapCities,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.swap_vert,
          color: Colors.white,
          size: 6.w,
        ),
      ),
    );
  }

  Widget _buildCitySuggestions(String query, bool isFromCity) {
    final filteredCities = _getFilteredCities(query);
    
    if (filteredCities.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Icon(
                  Icons.location_city,
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  query.isEmpty ? 'Popular Cities' : 'Suggestions',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 30.h),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: filteredCities.length > 8 ? 8 : filteredCities.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              itemBuilder: (context, index) {
                final city = filteredCities[index];
                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onCitySelected(city['name'], isFromCity);
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: city['popular']
                                ? AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1)
                                : AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            city['popular'] ? Icons.trending_up : Icons.location_city,
                            color: city['popular']
                                ? AppTheme.lightTheme.colorScheme.secondary
                                : AppTheme.lightTheme.colorScheme.primary,
                            size: 5.w,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                city['name'],
                                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                '${city['code']} • ${city['country']}',
                                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textMediumEmphasisLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (city['popular'])
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Popular',
                              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.centerRight,
          children: [
            Column(
              children: [
                _buildCityField(
                  label: 'FROM',
                  hint: 'Select departure city',
                  controller: fromCityController,
                  focusNode: fromCityFocusNode,
                  icon: Icons.flight_takeoff,
                ),
                SizedBox(height: 2.h),
                _buildCityField(
                  label: 'TO',
                  hint: 'Select destination city',
                  controller: toCityController,
                  focusNode: toCityFocusNode,
                  icon: Icons.flight_land,
                ),
              ],
            ),
            Positioned(
              right: 4.w,
              child: _buildSwapButton(),
            ),
          ],
        ),
        
        // City Suggestions
        if (showFromCitySuggestions)
          _buildCitySuggestions(fromCity, true),
        if (showToCitySuggestions)
          _buildCitySuggestions(toCity, false),
      ],
    );
  }
}