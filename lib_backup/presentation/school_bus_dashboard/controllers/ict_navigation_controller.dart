import 'package:flutter/material.dart';
import '../../../core/app_export.dart';

class ICTNavigationController {
  static final ICTNavigationController _instance = ICTNavigationController._internal();
  factory ICTNavigationController() => _instance;
  ICTNavigationController._internal();

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  final List<ICTUniversityScreen> _screens = [
    ICTUniversityScreen(
      route: AppRoutes.schoolBusDashboard,
      title: 'ICT University Transport',
      subtitle: 'Student Dashboard',
    ),
    ICTUniversityScreen(
      route: AppRoutes.schoolBusBookingForm,
      title: 'Book Campus Shuttle',
      subtitle: 'Schedule Your Ride',
    ),
    ICTUniversityScreen(
      route: AppRoutes.schoolBusQrDisplay,
      title: 'Digital Pass',
      subtitle: 'Your Active Ticket',
    ),
    ICTUniversityScreen(
      route: AppRoutes.schoolBusBookingHistory,
      title: 'Travel History',
      subtitle: 'Past Campus Trips',
    ),
    ICTUniversityScreen(
      route: '/ict-university-info',
      title: 'ICT University',
      subtitle: 'Campus Information',
    ),
  ];

  List<ICTUniversityScreen> get screens => _screens;

  void navigateToIndex(BuildContext context, int index) {
    if (index == _currentIndex) return;
    
    _currentIndex = index;
    
    // Handle special navigation cases
    switch (index) {
      case 0: // Dashboard
        _navigateWithReplacement(context, AppRoutes.schoolBusDashboard);
        break;
      case 1: // Book Ride
        Navigator.pushNamed(context, AppRoutes.schoolBusBookingForm);
        break;
      case 2: // My Ticket
        _handleTicketNavigation(context);
        break;
      case 3: // History
        Navigator.pushNamed(context, AppRoutes.schoolBusBookingHistory);
        break;
      case 4: // ICT Hub
        _showICTUniversityInfo(context);
        break;
    }
  }

  void _navigateWithReplacement(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  void _handleTicketNavigation(BuildContext context) {
    // Check if user has active booking
    bool hasActiveBooking = _checkActiveBooking();
    
    if (hasActiveBooking) {
      Navigator.pushNamed(context, AppRoutes.schoolBusQrDisplay);
    } else {
      _showNoActiveBookingDialog(context);
    }
  }

  bool _checkActiveBooking() {
    // Mock check - in real app, this would check user's active bookings
    // For demo purposes, return true
    return true;
  }

  void _showNoActiveBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFFFF9800),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No Active Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B4D3E),
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'You don\'t have any active campus shuttle bookings. Would you like to book a ride now?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Maybe Later',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              navigateToIndex(context, 1); // Navigate to booking
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4D3E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showICTUniversityInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B4D3E), Color(0xFF2D5A47)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.school,
                        color: Color(0xFFFFD700),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ICT University',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Campus Transportation Hub',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(
                      'Campus Shuttle Service',
                      'Safe and reliable transportation for ICT University students',
                      Icons.directions_bus,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      'Digital Ticketing',
                      'QR code-based boarding system for contactless travel',
                      Icons.qr_code,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      'Real-time Tracking',
                      'Live updates on shuttle locations and arrival times',
                      Icons.location_on,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      'Student Discounts',
                      'Special rates for ICT University students',
                      Icons.local_offer,
                    ),
                    
                    const Spacer(),
                    
                    // Contact Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B4D3E).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Need Help?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B4D3E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Contact ICT University Transport Services',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                color: Color(0xFFFFD700),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '+237 123 456 789',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1B4D3E),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1B4D3E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1B4D3E),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B4D3E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void updateIndex(int index) {
    _currentIndex = index;
  }

  void resetNavigation() {
    _currentIndex = 0;
  }
}

class ICTUniversityScreen {
  final String route;
  final String title;
  final String subtitle;

  const ICTUniversityScreen({
    required this.route,
    required this.title,
    required this.subtitle,
  });
}