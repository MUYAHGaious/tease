import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'walk_in_booking_widget.dart';

class CustomerServiceWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onWalkInBooking;
  final Function(String bookingId, double amount) onRefundProcessed;

  const CustomerServiceWidget({
    Key? key,
    required this.onWalkInBooking,
    required this.onRefundProcessed,
  }) : super(key: key);

  @override
  State<CustomerServiceWidget> createState() => _CustomerServiceWidgetState();
}

class _CustomerServiceWidgetState extends State<CustomerServiceWidget> {
  final TextEditingController _customerSearchController =
      TextEditingController();
  final TextEditingController _refundBookingIdController =
      TextEditingController();
  final TextEditingController _refundAmountController = TextEditingController();
  String _selectedIssueType = 'General Inquiry';
  String _selectedServiceType = 'Walk-in Booking';

  @override
  void dispose() {
    _customerSearchController.dispose();
    _refundBookingIdController.dispose();
    _refundAmountController.dispose();
    super.dispose();
  }

  void _performCustomerSearch() {
    HapticFeedback.selectionClick();
    // Simulate customer search
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Searching for customer: ${_customerSearchController.text}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _processRefund() {
    HapticFeedback.selectionClick();
    if (_refundBookingIdController.text.isNotEmpty &&
        _refundAmountController.text.isNotEmpty) {
      double? amount = double.tryParse(_refundAmountController.text);
      if (amount != null) {
        widget.onRefundProcessed(_refundBookingIdController.text, amount);
        _refundBookingIdController.clear();
        _refundAmountController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid amount entered for refund.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter booking ID and amount for refund.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showWalkInBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => WalkInBookingWidget(
        onBookingCreated: widget.onWalkInBooking,
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariantColor =
        Theme.of(context).colorScheme.onSurfaceVariant;
    final borderColor = Theme.of(context).colorScheme.outline;

    return SingleChildScrollView(
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Service Operations',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSectionTitle('Quick Services'),
          SizedBox(height: 0.5.h),
          _buildServiceButtons(
              primaryColor, textColor, onSurfaceVariantColor, borderColor),
          SizedBox(height: 2.h),
          _buildSectionTitle('Customer Lookup'),
          SizedBox(height: 0.5.h),
          _buildCustomerSearch(primaryColor, surfaceColor, textColor,
              onSurfaceVariantColor, borderColor),
          SizedBox(height: 2.h),
          _buildSectionTitle('Refund Processing'),
          SizedBox(height: 0.5.h),
          _buildRefundSection(primaryColor, surfaceColor, textColor,
              onSurfaceVariantColor, borderColor),
          SizedBox(height: 2.h),
          _buildSectionTitle('Issue Resolution'),
          SizedBox(height: 0.5.h),
          _buildIssueResolution(primaryColor, surfaceColor, textColor,
              onSurfaceVariantColor, borderColor),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  Widget _buildServiceButtons(Color primaryColor, Color textColor,
      Color onSurfaceVariantColor, Color borderColor) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showWalkInBookingDialog,
            icon: Icon(Icons.person_add),
            label: Text('Walk-in Booking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ticket Modification interface coming soon!'),
                  backgroundColor: primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            icon: Icon(Icons.edit),
            label: Text('Modify Ticket'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: borderColor),
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerSearch(Color primaryColor, Color surfaceColor,
      Color textColor, Color onSurfaceVariantColor, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.2)),
      ),
      child: TextField(
        controller: _customerSearchController,
        style: GoogleFonts.inter(color: textColor, fontSize: 10.sp),
        decoration: InputDecoration(
          hintText: 'Search by Name, Phone, Email, Booking ID',
          hintStyle:
              GoogleFonts.inter(color: onSurfaceVariantColor, fontSize: 10.sp),
          prefixIcon:
              Icon(Icons.search, color: onSurfaceVariantColor, size: 20),
          suffixIcon: IconButton(
            icon: Icon(Icons.arrow_forward, color: primaryColor),
            onPressed: _performCustomerSearch,
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        ),
      ),
    );
  }

  Widget _buildRefundSection(Color primaryColor, Color surfaceColor,
      Color textColor, Color onSurfaceVariantColor, Color borderColor) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor.withOpacity(0.2)),
          ),
          child: TextField(
            controller: _refundBookingIdController,
            style: GoogleFonts.inter(color: textColor, fontSize: 10.sp),
            decoration: InputDecoration(
              hintText: 'Booking ID for Refund',
              hintStyle: GoogleFonts.inter(
                  color: onSurfaceVariantColor, fontSize: 10.sp),
              prefixIcon: Icon(Icons.receipt_long,
                  color: onSurfaceVariantColor, size: 20),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor.withOpacity(0.2)),
          ),
          child: TextField(
            controller: _refundAmountController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(color: textColor, fontSize: 10.sp),
            decoration: InputDecoration(
              hintText: 'Refund Amount (XAF)',
              hintStyle: GoogleFonts.inter(
                  color: onSurfaceVariantColor, fontSize: 10.sp),
              prefixIcon:
                  Icon(Icons.money, color: onSurfaceVariantColor, size: 20),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        ElevatedButton.icon(
          onPressed: _processRefund,
          icon: Icon(Icons.refresh),
          label: Text('Process Refund'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 5.h),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildIssueResolution(Color primaryColor, Color surfaceColor,
      Color textColor, Color onSurfaceVariantColor, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          'Select Issue Type',
          _selectedIssueType,
          ['General Inquiry', 'Complaint', 'Technical Issue', 'Feedback'],
          (newValue) {
            setState(() {
              _selectedIssueType = newValue!;
            });
          },
          surfaceColor,
          textColor,
          onSurfaceVariantColor,
          borderColor,
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor.withOpacity(0.2)),
          ),
          child: TextField(
            maxLines: 4,
            style: GoogleFonts.inter(color: textColor, fontSize: 10.sp),
            decoration: InputDecoration(
              hintText: 'Describe the issue or request...',
              hintStyle: GoogleFonts.inter(
                  color: onSurfaceVariantColor, fontSize: 10.sp),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.selectionClick();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Issue submitted successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            );
          },
          icon: Icon(Icons.send),
          label: Text('Submit Issue'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            minimumSize: Size(double.infinity, 5.h),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
      String hint,
      String value,
      List<String> items,
      ValueChanged<String?> onChanged,
      Color surfaceColor,
      Color textColor,
      Color onSurfaceVariantColor,
      Color borderColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style: GoogleFonts.inter(
                  color: onSurfaceVariantColor, fontSize: 10.sp)),
          icon: Icon(Icons.arrow_drop_down, color: onSurfaceVariantColor),
          style: GoogleFonts.inter(color: textColor, fontSize: 10.sp),
          isExpanded: true,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}
