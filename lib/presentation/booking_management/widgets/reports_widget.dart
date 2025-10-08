import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsWidget extends StatefulWidget {
  final Function(String reportType) onExportReport;

  const ReportsWidget({
    Key? key,
    required this.onExportReport,
  }) : super(key: key);

  @override
  State<ReportsWidget> createState() => _ReportsWidgetState();
}

class _ReportsWidgetState extends State<ReportsWidget>
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

  String _selectedPeriod = 'Today';
  String _selectedReportType = 'Daily Summary';

  late AnimationController _animationController;
  late Animation<double> _animation;

  // Mock data for enhanced reports
  final List<String> _periods = ['Today', 'This Week', 'This Month', 'Custom'];
  final List<String> _reportTypes = [
    'Daily Summary',
    'Route Performance',
    'Bus Utilization',
    'Customer Stats',
    'Recent Bookings',
  ];

  // Mock data for reports
  final Map<String, dynamic> _dailyStats = {
    'totalBookings': 45,
    'totalRevenue': '337,500 XAF',
    'averageBookingValue': '7,500 XAF',
    'completedTrips': 12,
    'cancelledBookings': 3,
    'refundAmount': '22,500 XAF',
  };

  final List<Map<String, dynamic>> _routePerformance = [
    {
      'route': 'Douala → Yaoundé',
      'bookings': 18,
      'revenue': '135,000 XAF',
      'utilization': '85%'
    },
    {
      'route': 'Yaoundé → Bamenda',
      'bookings': 12,
      'revenue': '96,000 XAF',
      'utilization': '70%'
    },
    {
      'route': 'Douala → Bafoussam',
      'bookings': 8,
      'revenue': '56,000 XAF',
      'utilization': '60%'
    },
    {
      'route': 'Garoua → Maroua',
      'bookings': 7,
      'revenue': '45,500 XAF',
      'utilization': '55%'
    },
  ];

  final List<Map<String, dynamic>> _busUtilization = [
    {
      'busId': 'BUS-001',
      'route': 'Douala → Yaoundé',
      'seatsUsed': 45,
      'totalSeats': 70,
      'utilization': '64%'
    },
    {
      'busId': 'BUS-002',
      'route': 'Yaoundé → Bamenda',
      'seatsUsed': 38,
      'totalSeats': 70,
      'utilization': '54%'
    },
    {
      'busId': 'BUS-003',
      'route': 'Douala → Bafoussam',
      'seatsUsed': 28,
      'totalSeats': 70,
      'utilization': '40%'
    },
    {
      'busId': 'BUS-004',
      'route': 'Garoua → Maroua',
      'seatsUsed': 25,
      'totalSeats': 70,
      'utilization': '36%'
    },
  ];

  final List<Map<String, dynamic>> _recentBookings = [
    {
      'id': 'BF001',
      'customer': 'John Doe',
      'route': 'Douala → Yaoundé',
      'amount': '7,500 XAF',
      'time': '10:30 AM'
    },
    {
      'id': 'BF002',
      'customer': 'Jane Smith',
      'route': 'Yaoundé → Bamenda',
      'amount': '8,000 XAF',
      'time': '11:15 AM'
    },
    {
      'id': 'BF003',
      'customer': 'Mike Johnson',
      'route': 'Douala → Bafoussam',
      'amount': '7,000 XAF',
      'time': '12:00 PM'
    },
    {
      'id': 'BF004',
      'customer': 'Sarah Wilson',
      'route': 'Garoua → Maroua',
      'amount': '6,500 XAF',
      'time': '12:45 PM'
    },
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
      curve: Curves.easeInOut,
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
    return FadeTransition(
      opacity: _animation,
      child: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildReportsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(3.w),
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
            'Reports & Analytics',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'View booking statistics and performance metrics',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: onSurfaceVariantColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(3.w),
      child: Column(
        children: [
          _buildQuickStats(),
          SizedBox(height: 2.h),
          _buildSelectedReport(),
          SizedBox(height: 2.h),
          _buildExportOptions(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: EdgeInsets.all(3.w),
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
            'Today\'s Quick Stats',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Bookings',
                  _dailyStats['totalBookings'].toString(),
                  Icons.book_online,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                  'Revenue',
                  _dailyStats['totalRevenue'],
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completed Trips',
                  _dailyStats['completedTrips'].toString(),
                  Icons.check_circle,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatCard(
                  'Cancelled',
                  _dailyStats['cancelledBookings'].toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              color: onSurfaceVariantColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedReport() {
    switch (_selectedReportType) {
      case 'Daily Summary':
        return _buildDailySummary();
      case 'Route Performance':
        return _buildRoutePerformance();
      case 'Bus Utilization':
        return _buildBusUtilization();
      case 'Customer Stats':
        return _buildCustomerStats();
      case 'Recent Bookings':
        return _buildRecentBookings();
      default:
        return _buildDailySummary();
    }
  }

  Widget _buildDailySummary() {
    return Container(
      padding: EdgeInsets.all(3.w),
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
            'Daily Summary Details',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSummaryRow(
              'Total Bookings', _dailyStats['totalBookings'].toString()),
          _buildSummaryRow('Total Revenue', _dailyStats['totalRevenue']),
          _buildSummaryRow(
              'Average Booking Value', _dailyStats['averageBookingValue']),
          _buildSummaryRow(
              'Completed Trips', _dailyStats['completedTrips'].toString()),
          _buildSummaryRow('Cancelled Bookings',
              _dailyStats['cancelledBookings'].toString()),
          _buildSummaryRow('Refund Amount', _dailyStats['refundAmount']),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: onSurfaceVariantColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutePerformance() {
    return Container(
      padding: EdgeInsets.all(3.w),
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
            'Route Performance',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          ..._routePerformance.map((route) => _buildRouteCard(route)),
        ],
      ),
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            route['route'],
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 0.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${route['bookings']} bookings',
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  color: onSurfaceVariantColor,
                ),
              ),
              Text(
                route['revenue'],
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              Text(
                route['utilization'],
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusUtilization() {
    return Container(
      padding: EdgeInsets.all(3.w),
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
            'Bus Utilization',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          ..._busUtilization.map((bus) => _buildBusCard(bus)),
        ],
      ),
    );
  }

  Widget _buildBusCard(Map<String, dynamic> bus) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bus['busId'],
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Text(
                bus['utilization'],
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            bus['route'],
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              color: onSurfaceVariantColor,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            '${bus['seatsUsed']}/${bus['totalSeats']} seats used',
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              color: onSurfaceVariantColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerStats() {
    return Container(
      padding: EdgeInsets.all(3.w),
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
            'Customer Statistics',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSummaryRow('New Customers Today', '12'),
          _buildSummaryRow('Returning Customers', '33'),
          _buildSummaryRow('Customer Satisfaction', '4.2/5'),
          _buildSummaryRow('Average Customer Value', '7,500 XAF'),
          _buildSummaryRow('Customer Complaints', '2'),
          _buildSummaryRow('Resolved Issues', '2'),
        ],
      ),
    );
  }

  Widget _buildRecentBookings() {
    return Container(
      padding: EdgeInsets.all(3.w),
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
            'Recent Bookings',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          ..._recentBookings.map((booking) => _buildBookingCard(booking)),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['id'],
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  booking['customer'],
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: onSurfaceVariantColor,
                  ),
                ),
                Text(
                  booking['route'],
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: onSurfaceVariantColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                booking['amount'],
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              Text(
                booking['time'],
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  color: onSurfaceVariantColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptions() {
    return Container(
      padding: EdgeInsets.all(3.w),
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
            'Export Options',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportReport('PDF'),
                  icon: Icon(Icons.picture_as_pdf, size: 16.sp),
                  label: Text(
                    'Export PDF',
                    style: GoogleFonts.inter(fontSize: 10.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportReport('Excel'),
                  icon: Icon(Icons.table_chart, size: 16.sp),
                  label: Text(
                    'Export Excel',
                    style: GoogleFonts.inter(fontSize: 10.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _exportReport(String format) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting $_selectedReportType as $format...'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _refreshReports() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Refreshing reports...'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
