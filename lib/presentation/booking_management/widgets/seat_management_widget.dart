import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class SeatManagementWidget extends StatefulWidget {
  final Function(String seatId, String status) onSeatStatusChanged;

  const SeatManagementWidget({
    Key? key,
    required this.onSeatStatusChanged,
  }) : super(key: key);

  @override
  State<SeatManagementWidget> createState() => _SeatManagementWidgetState();
}

class _SeatManagementWidgetState extends State<SeatManagementWidget>
    with TickerProviderStateMixin {
  // Theme-aware colors following your pattern
  Color get primaryColor => Theme.of(context).colorScheme.primary;
  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(context).colorScheme.surface;
  Color get textColor => Theme.of(context).colorScheme.onSurface;
  Color get onSurfaceVariantColor =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  Color get shadowColor => Theme.of(context).colorScheme.shadow;
  Color get borderColor => Theme.of(context).colorScheme.outline;

  String _selectedRoute = 'Douala → Yaoundé';
  String _selectedDate = 'Today';
  Map<String, String> _seatStatuses = {};

  late AnimationController _animationController;
  late Animation<double> _animation;

  // Mock routes data
  final List<String> _routes = [
    'Douala → Yaoundé',
    'Yaoundé → Bamenda',
    'Douala → Bafoussam',
    'Garoua → Maroua',
    'Bamenda → Yaoundé',
  ];

  // Mock seat data
  final List<Map<String, dynamic>> _seats = [
    {'id': 'A1', 'status': 'available', 'type': 'window'},
    {'id': 'A2', 'status': 'occupied', 'type': 'aisle'},
    {'id': 'A3', 'status': 'available', 'type': 'window'},
    {'id': 'A4', 'status': 'maintenance', 'type': 'aisle'},
    {'id': 'B1', 'status': 'available', 'type': 'window'},
    {'id': 'B2', 'status': 'occupied', 'type': 'aisle'},
    {'id': 'B3', 'status': 'available', 'type': 'window'},
    {'id': 'B4', 'status': 'available', 'type': 'aisle'},
    {'id': 'C1', 'status': 'occupied', 'type': 'window'},
    {'id': 'C2', 'status': 'available', 'type': 'aisle'},
    {'id': 'C3', 'status': 'maintenance', 'type': 'window'},
    {'id': 'C4', 'status': 'available', 'type': 'aisle'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(_animation),
      child: FadeTransition(
        opacity: _animation,
        child: Column(
          children: [
            _buildHeader(),
            _buildRouteSelector(),
            _buildSeatMap(),
            _buildLegend(),
            _buildBulkActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seat Management',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Manage seat availability and status',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: onSurfaceVariantColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                _refreshSeatData();
              },
              icon: Icon(
                Icons.refresh,
                color: primaryColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Route & Date',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRoute,
                  decoration: InputDecoration(
                    labelText: 'Route',
                    labelStyle: GoogleFonts.inter(
                      color: onSurfaceVariantColor,
                      fontSize: 12.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                  ),
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: 14.sp,
                  ),
                  items: _routes.map((route) {
                    return DropdownMenuItem(
                      value: route,
                      child: Text(route),
                    );
                  }).toList(),
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedRoute = value!;
                    });
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDate,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    labelStyle: GoogleFonts.inter(
                      color: onSurfaceVariantColor,
                      fontSize: 12.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                  ),
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: 14.sp,
                  ),
                  items: ['Today', 'Tomorrow', 'Next Week'].map((date) {
                    return DropdownMenuItem(
                      value: date,
                      child: Text(date),
                    );
                  }).toList(),
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedDate = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatMap() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seat Layout',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.2,
            ),
            itemCount: _seats.length,
            itemBuilder: (context, index) {
              final seat = _seats[index];
              return _buildSeatItem(seat);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSeatItem(Map<String, dynamic> seat) {
    final String seatId = seat['id'];
    final String status = seat['status'];
    final String type = seat['type'];

    Color seatColor = _getSeatColor(status);
    IconData seatIcon = _getSeatIcon(status);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _showSeatStatusDialog(seatId, status);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: seatColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: seatColor,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              seatIcon,
              color: seatColor,
              size: 6.w,
            ),
            SizedBox(height: 0.5.h),
            Text(
              seatId,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: seatColor,
              ),
            ),
            Text(
              type,
              style: GoogleFonts.inter(
                fontSize: 8.sp,
                color: seatColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Available', Colors.green, Icons.check_circle),
              _buildLegendItem('Occupied', Colors.red, Icons.person),
              _buildLegendItem('Maintenance', Colors.orange, Icons.build),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 1.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBulkActions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                _bulkUpdateSeats('available');
              },
              icon: Icon(Icons.check_circle),
              label: Text('Mark Available'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                _bulkUpdateSeats('maintenance');
              },
              icon: Icon(Icons.build),
              label: Text('Mark Maintenance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeatColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'occupied':
        return Colors.red;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeatIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle;
      case 'occupied':
        return Icons.person;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.help;
    }
  }

  void _showSeatStatusDialog(String seatId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: Text(
          'Update Seat $seatId',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current status: ${currentStatus.toUpperCase()}',
              style: GoogleFonts.inter(
                color: onSurfaceVariantColor,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Select new status:',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            SizedBox(height: 1.h),
            ...['available', 'occupied', 'maintenance'].map((status) {
              return ListTile(
                leading: Icon(
                  _getSeatIcon(status),
                  color: _getSeatColor(status),
                ),
                title: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _updateSeatStatus(seatId, status);
                },
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _updateSeatStatus(String seatId, String newStatus) {
    setState(() {
      _seatStatuses[seatId] = newStatus;
      // Update the seat in the list
      final seatIndex = _seats.indexWhere((seat) => seat['id'] == seatId);
      if (seatIndex != -1) {
        _seats[seatIndex]['status'] = newStatus;
      }
    });

    widget.onSeatStatusChanged(seatId, newStatus);
  }

  void _bulkUpdateSeats(String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: Text(
          'Bulk Update Seats',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        content: Text(
          'Are you sure you want to mark all selected seats as ${status.toUpperCase()}?',
          style: GoogleFonts.inter(
            color: textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.selectionClick();
              // Implement bulk update logic here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bulk update completed'),
                  backgroundColor: primaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _refreshSeatData() {
    setState(() {
      // Simulate data refresh
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seat data refreshed'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

