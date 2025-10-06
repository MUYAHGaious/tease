import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickActionsWidget extends StatelessWidget {
  final Function(String action) onActionSelected;

  const QuickActionsWidget({
    Key? key,
    required this.onActionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Theme-aware colors following your pattern
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariantColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final shadowColor = Theme.of(context).colorScheme.shadow;
    final borderColor = Theme.of(context).colorScheme.outline;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: onSurfaceVariantColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 3.h),
          _buildActionGrid(context),
          SizedBox(height: 3.h),
          _buildCloseButton(context),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        'title': 'Quick Booking',
        'icon': Icons.add_circle,
        'color': Colors.green,
        'action': 'quick_booking',
        'description': 'Create walk-in booking',
      },
      {
        'title': 'Seat Management',
        'icon': Icons.event_seat,
        'color': Colors.blue,
        'action': 'seat_management',
        'description': 'Manage seat availability',
      },
      {
        'title': 'Customer Service',
        'icon': Icons.support_agent,
        'color': Colors.orange,
        'action': 'customer_service',
        'description': 'Handle customer inquiries',
      },
      {
        'title': 'Reports',
        'icon': Icons.analytics,
        'color': Colors.purple,
        'action': 'reports',
        'description': 'View analytics & reports',
      },
      {
        'title': 'Refund Processing',
        'icon': Icons.money_off,
        'color': Colors.red,
        'action': 'refund_processing',
        'description': 'Process cancellations',
      },
      {
        'title': 'Customer Lookup',
        'icon': Icons.search,
        'color': Colors.teal,
        'action': 'customer_lookup',
        'description': 'Search customer info',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 3.h,
        childAspectRatio: 1.2,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(context, action);
      },
    );
  }

  Widget _buildActionCard(BuildContext context, Map<String, dynamic> action) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariantColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final shadowColor = Theme.of(context).colorScheme.shadow;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onActionSelected(action['action']);
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: action['color'].withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: action['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                action['icon'],
                color: action['color'],
                size: 8.w,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              action['title'],
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.5.h),
            Text(
              action['description'],
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: onSurfaceVariantColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          Navigator.pop(context);
        },
        child: Text(
          'Close',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: primaryColor),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
