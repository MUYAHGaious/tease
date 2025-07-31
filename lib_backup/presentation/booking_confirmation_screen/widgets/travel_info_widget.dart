import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TravelInfoWidget extends StatefulWidget {
  final Map<String, dynamic> travelInfo;

  const TravelInfoWidget({
    super.key,
    required this.travelInfo,
  });

  @override
  State<TravelInfoWidget> createState() => _TravelInfoWidgetState();
}

class _TravelInfoWidgetState extends State<TravelInfoWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info_outline',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Important Travel Information',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                    child: Column(
                      children: [
                        Container(
                          height: 1,
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                        ),
                        SizedBox(height: 2.h),
                        _buildInfoSection(
                          'Reporting Time',
                          widget.travelInfo['reportingTime'] as String,
                          'Please arrive 15 minutes before departure',
                          'schedule',
                        ),
                        SizedBox(height: 2.h),
                        _buildInfoSection(
                          'Boarding Point',
                          widget.travelInfo['boardingPoint'] as String,
                          'Tap to view on map',
                          'location_on',
                          hasAction: true,
                        ),
                        SizedBox(height: 2.h),
                        _buildInfoSection(
                          'Baggage Allowance',
                          widget.travelInfo['baggageAllowance'] as String,
                          'Additional charges apply for excess baggage',
                          'luggage',
                        ),
                        SizedBox(height: 2.h),
                        _buildInfoSection(
                          'Cancellation Policy',
                          widget.travelInfo['cancellationPolicy'] as String,
                          'Terms and conditions apply',
                          'cancel',
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    String content,
    String subtitle,
    String iconName, {
    bool hasAction = false,
  }) {
    return GestureDetector(
      onTap: hasAction ? () => _showMapDialog() : null,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primaryContainer
              .withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: hasAction
              ? Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    content,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontStyle:
                          hasAction ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (hasAction)
              CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 4.w,
              ),
          ],
        ),
      ),
    );
  }

  void _showMapDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Boarding Point Location',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 6.w,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'map',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 12.w,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Interactive Map',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          widget.travelInfo['boardingPoint'] as String,
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
