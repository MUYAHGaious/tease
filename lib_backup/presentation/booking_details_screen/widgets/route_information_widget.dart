import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RouteInformationWidget extends StatelessWidget {
  final Map<String, dynamic> routeData;

  const RouteInformationWidget({
    Key? key,
    required this.routeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stops =
        (routeData['stops'] as List).cast<Map<String, dynamic>>();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'route',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Route Information',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            constraints: BoxConstraints(maxHeight: 40.h),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(stops.length, (index) {
                  final stop = stops[index];
                  final isFirst = index == 0;
                  final isLast = index == stops.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 3.w,
                            height: 3.w,
                            decoration: BoxDecoration(
                              color: isFirst || isLast
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 8.h,
                              color: AppTheme.lightTheme.colorScheme.outline,
                            ),
                        ],
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 2.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      stop['name'] as String,
                                      style: AppTheme
                                          .lightTheme.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    stop['time'] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              if (stop['address'] != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 0.5.h),
                                  child: Text(
                                    stop['address'] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              if (stop['duration'] != null && !isLast)
                                Padding(
                                  padding: EdgeInsets.only(top: 1.h),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      color: AppTheme
                                          .lightTheme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${stop['duration']} to next stop',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
