import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class BusLayoutWidget extends StatefulWidget {
  final List<Map<String, dynamic>> seats;
  final List<int> selectedSeats;
  final Function(int) onSeatTap;
  final double zoomLevel;

  const BusLayoutWidget({
    Key? key,
    required this.seats,
    required this.selectedSeats,
    required this.onSeatTap,
    required this.zoomLevel,
  }) : super(key: key);

  @override
  State<BusLayoutWidget> createState() => _BusLayoutWidgetState();
}

class _BusLayoutWidgetState extends State<BusLayoutWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getSeatColor(Map<String, dynamic> seat) {
    final seatId = seat['id'] as int;
    final status = seat['status'] as String;

    if (widget.selectedSeats.contains(seatId)) {
      return AppTheme.lightTheme.colorScheme.secondary;
    }

    switch (status) {
      case 'available':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'occupied':
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
      case 'premium':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  Widget _buildSeat(Map<String, dynamic> seat, int index) {
    final seatId = seat['id'] as int;
    final seatNumber = seat['number'] as String;
    final status = seat['status'] as String;
    final isSelected = widget.selectedSeats.contains(seatId);
    final isAvailable = status == 'available' || status == 'premium';

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: isAvailable ? () => widget.onSeatTap(seatId) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 12.w * widget.zoomLevel,
              height: 12.w * widget.zoomLevel,
              margin: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: _getSeatColor(seat),
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.secondary
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.secondary
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  seatNumber,
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: isAvailable
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontSize: (8 * widget.zoomLevel).sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDriverSection() {
    return Container(
      width: double.infinity,
      height: 8.h,
      margin: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(2.w),
                  bottomLeft: Radius.circular(2.w),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'drive_eta',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 6.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Driver',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(2.w),
                  bottomRight: Radius.circular(2.w),
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'door_front',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDriverSection(),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                crossAxisSpacing: 1.w,
                mainAxisSpacing: 1.w,
              ),
              itemCount: widget.seats.length,
              itemBuilder: (context, index) {
                return _buildSeat(widget.seats[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
