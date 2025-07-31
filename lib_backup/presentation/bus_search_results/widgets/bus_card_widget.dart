import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BusCardWidget extends StatelessWidget {
  final Map<String, dynamic> busData;
  final VoidCallback onTap;
  final VoidCallback onViewDetails;
  final VoidCallback onSelectSeats;

  const BusCardWidget({
    super.key,
    required this.busData,
    required this.onTap,
    required this.onViewDetails,
    required this.onSelectSeats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBusHeader(),
                SizedBox(height: 2.h),
                _buildTimeAndDurationRow(),
                SizedBox(height: 2.h),
                _buildAmenitiesRow(),
                SizedBox(height: 2.h),
                _buildPriceAndSeatsRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusHeader() {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 6.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color:
                AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImageWidget(
              imageUrl: busData["operatorLogo"] as String,
              width: 12.w,
              height: 6.h,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                busData["operatorName"] as String,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Text(
                    busData["busType"] as String,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      busData["busNumber"] as String,
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildRatingWidget(),
      ],
    );
  }

  Widget _buildRatingWidget() {
    final rating = busData["rating"] as double;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'star',
            color: AppTheme.getSuccessColor(true),
            size: 14,
          ),
          SizedBox(width: 1.w),
          Text(
            rating.toStringAsFixed(1),
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.getSuccessColor(true),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAndDurationRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                busData["departureTime"] as String,
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                busData["departureLocation"] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Text(
                busData["duration"] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Expanded(child: Container()),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                busData["arrivalTime"] as String,
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                busData["arrivalLocation"] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesRow() {
    final amenities = busData["amenities"] as List;
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 3.w,
            runSpacing: 1.h,
            children: amenities.take(4).map((amenity) {
              return _buildAmenityChip(amenity as Map<String, dynamic>);
            }).toList(),
          ),
        ),
        if (amenities.length > 4)
          Text(
            '+${amenities.length - 4} more',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildAmenityChip(Map<String, dynamic> amenity) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: amenity["icon"] as String,
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 12,
          ),
          SizedBox(width: 1.w),
          Text(
            amenity["name"] as String,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndSeatsRow(BuildContext context) {
    final availableSeats = busData["availableSeats"] as int;
    final isLowAvailability = availableSeats <= 5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              busData["price"] as String,
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.secondary,
              ),
            ),
            SizedBox(height: 0.5.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'event_seat',
                  color: isLowAvailability
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.getSuccessColor(true),
                  size: 14,
                ),
                SizedBox(width: 1.w),
                Text(
                  '$availableSeats seats left',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: isLowAvailability
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.getSuccessColor(true),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton(
              onPressed: onViewDetails,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                side: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                ),
              ),
              child: Text(
                'View Details',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            ElevatedButton(
              onPressed: onSelectSeats,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              ),
              child: Text(
                'Select Seats',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
