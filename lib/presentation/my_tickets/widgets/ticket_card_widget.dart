import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class TicketCardWidget extends StatefulWidget {
  final Map<String, dynamic> ticketData;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onModify;
  final VoidCallback? onShare;
  final VoidCallback? onRebook;
  final VoidCallback? onRate;
  final VoidCallback? onDownload;

  const TicketCardWidget({
    Key? key,
    required this.ticketData,
    this.onTap,
    this.onCancel,
    this.onModify,
    this.onShare,
    this.onRebook,
    this.onRate,
    this.onDownload,
  }) : super(key: key);

  @override
  State<TicketCardWidget> createState() => _TicketCardWidgetState();
}

class _TicketCardWidgetState extends State<TicketCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _qrAnimationController;
  late Animation<double> _qrPulseAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _qrAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _qrPulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _qrAnimationController,
      curve: Curves.easeInOut,
    ));
    _qrAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _qrAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = widget.ticketData['status'] == 'upcoming';
    final String statusColor = _getStatusColor(widget.ticketData['status']);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTicketHeader(),
                      SizedBox(height: 2.h),
                      _buildRouteInfo(),
                      SizedBox(height: 2.h),
                      _buildTravelDetails(),
                      SizedBox(height: 2.h),
                      _buildQRCodeSection(),
                      if (_isExpanded) ...[
                        SizedBox(height: 2.h),
                        _buildActionButtons(isUpcoming),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking ID: ${widget.ticketData['bookingId']}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                widget.ticketData['busOperator'] ?? 'Tease Express',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: _getStatusColorValue(widget.ticketData['status'])
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getStatusColorValue(widget.ticketData['status']),
              width: 1,
            ),
          ),
          child: Text(
            widget.ticketData['status']?.toString().toUpperCase() ??
                'CONFIRMED',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: _getStatusColorValue(widget.ticketData['status']),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.ticketData['fromCity'] ?? 'Douala',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                widget.ticketData['fromTerminal'] ?? 'Port Authority',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 8.w,
                height: 2,
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
              ),
              CustomIconWidget(
                iconName: 'directions_bus',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              Container(
                width: 8.w,
                height: 2,
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.ticketData['toCity'] ?? 'Yaoundé',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                widget.ticketData['toTerminal'] ?? 'South Station',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTravelDetails() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDetailItem(
              'date',
              'Date',
              widget.ticketData['travelDate'] ?? 'Jul 28, 2025',
            ),
          ),
          Container(
            width: 1,
            height: 6.h,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildDetailItem(
              'access_time',
              'Time',
              widget.ticketData['departureTime'] ?? '09:30 AM',
            ),
          ),
          Container(
            width: 1,
            height: 6.h,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildDetailItem(
              'event_seat',
              'Seats',
              widget.ticketData['seatNumbers'] ?? 'A1, A2',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String iconName, String label, String value) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQRCodeSection() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _qrPulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _qrPulseAnimation.value,
                  child: Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'qr_code',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 8.w,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Digital Ticket',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Tap to ${_isExpanded ? 'collapse' : 'expand'} QR code',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: _isExpanded ? 'expand_less' : 'expand_more',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isUpcoming) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: isUpcoming ? _buildUpcomingActions() : _buildPastActions(),
    );
  }

  Widget _buildUpcomingActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'cancel',
            'Cancel',
            AppTheme.lightTheme.colorScheme.error,
            widget.onCancel,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildActionButton(
            'edit',
            'Modify',
            AppTheme.lightTheme.colorScheme.primary,
            widget.onModify,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildActionButton(
            'share',
            'Share',
            AppTheme.lightTheme.colorScheme.secondary,
            widget.onShare,
          ),
        ),
      ],
    );
  }

  Widget _buildPastActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'refresh',
            'Rebook',
            AppTheme.lightTheme.colorScheme.primary,
            widget.onRebook,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildActionButton(
            'star',
            'Rate',
            AppTheme.lightTheme.colorScheme.secondary,
            widget.onRate,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildActionButton(
            'download',
            'Receipt',
            AppTheme.lightTheme.colorScheme.tertiary,
            widget.onDownload,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String iconName,
    String label,
    Color color,
    VoidCallback? onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 20,
              ),
              SizedBox(height: 0.5.h),
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return 'success';
      case 'upcoming':
        return 'primary';
      case 'completed':
        return 'tertiary';
      case 'cancelled':
        return 'error';
      default:
        return 'primary';
    }
  }

  Color _getStatusColorValue(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'upcoming':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'completed':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'cancelled':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}