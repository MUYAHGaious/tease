import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class BookingSummaryCard extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const BookingSummaryCard({
    Key? key,
    required this.bookingData,
  }) : super(key: key);

  @override
  State<BookingSummaryCard> createState() => _BookingSummaryCardState();
}

class _BookingSummaryCardState extends State<BookingSummaryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryHeader(),
          if (_isExpanded) _buildExpandedContent(),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Summary',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '${widget.bookingData["from"]} → ${widget.bookingData["to"]}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Total: XFA ${widget.bookingData["totalPrice"]}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName:
                  _isExpanded ? 'keyboard_arrow_up' : 'keyboard_arrow_down',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppTheme.lightTheme.dividerColor),
          SizedBox(height: 2.h),
          _buildRouteDetails(),
          SizedBox(height: 2.h),
          _buildSeatDetails(),
          SizedBox(height: 2.h),
          _buildAddOnsDetails(),
          SizedBox(height: 2.h),
          _buildPriceBreakdown(),
        ],
      ),
    );
  }

  Widget _buildRouteDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Details',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'directions_bus',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                '${widget.bookingData["busNumber"]} - ${widget.bookingData["busType"]}',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'schedule',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              '${widget.bookingData["departureTime"]} - ${widget.bookingData["arrivalTime"]}',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              widget.bookingData["travelDate"] as String,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeatDetails() {
    final selectedSeats = widget.bookingData["selectedSeats"] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seat Details',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'event_seat',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'Seats: ${selectedSeats.join(", ")} (${selectedSeats.length} passenger${selectedSeats.length > 1 ? 's' : ''})',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddOnsDetails() {
    final addOns = widget.bookingData["addOns"] as List;
    if (addOns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add-ons',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...addOns
            .map((addOn) => Padding(
                  padding: EdgeInsets.only(bottom: 0.5.h),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName:
                            addOn["type"] == "baggage" ? 'luggage' : 'pets',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          '${addOn["name"]} - \$${addOn["price"]}',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    final selectedSeats = widget.bookingData["selectedSeats"] as List;
    final addOns = widget.bookingData["addOns"] as List;
    final basePrice = widget.bookingData["basePrice"] as double;
    final addOnTotal = addOns.fold<double>(
        0, (sum, addOn) => sum + (addOn["price"] as double));
    final subtotal = (basePrice * selectedSeats.length) + addOnTotal;
    final taxes = subtotal * 0.12;
    final total = subtotal + taxes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Breakdown',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        _buildPriceRow(
            'Base fare (${selectedSeats.length} seat${selectedSeats.length > 1 ? 's' : ''})',
            '\$${(basePrice * selectedSeats.length).toStringAsFixed(2)}'),
        if (addOnTotal > 0)
          _buildPriceRow('Add-ons', '\$${addOnTotal.toStringAsFixed(2)}'),
        _buildPriceRow('Taxes & fees', '\$${taxes.toStringAsFixed(2)}'),
        Divider(color: AppTheme.lightTheme.dividerColor),
        _buildPriceRow('Total Amount', '\$${total.toStringAsFixed(2)}',
            isTotal: true),
      ],
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTheme.lightTheme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)
                : AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          Text(
            amount,
            style: isTotal
                ? AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  )
                : AppTheme.lightTheme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
