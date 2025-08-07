import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StudentMarkerWidget extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onTap;

  const StudentMarkerWidget({
    super.key,
    required this.student,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'at_stop':
        return Colors.green;
      case 'approaching':
        return Colors.orange;
      case 'walking':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'at_stop':
        return Icons.location_on;
      case 'approaching':
        return Icons.directions_walk;
      case 'walking':
        return Icons.directions_run;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ultra-simplified student marker for mobile performance
    final status = student['status'] as String;
    final statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: statusColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          _getStatusIcon(status),
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}