import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/admin_header_widget.dart';
import './widgets/route_card_widget.dart';
import './widgets/route_creation_wizard_widget.dart';
import './widgets/route_optimization_widget.dart';

class AdminRouteManagement extends StatefulWidget {
  const AdminRouteManagement({super.key});

  @override
  State<AdminRouteManagement> createState() => _AdminRouteManagementState();
}

class _AdminRouteManagementState extends State<AdminRouteManagement> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  bool _showOptimization = false;

  // Mock data for routes
  List<Map<String, dynamic>> _routes = [
    {
      'id': 'R001',
      'routeNumber': 'R001',
      'routeName': 'Main Campus - North District',
      'assignedBus': 'Bus A001 (Capacity: 45)',
      'driverName': 'John Smith',
      'status': 'Active',
      'capacity': 45,
      'currentOccupancy': 38,
      'stops': [
        {
          'id': 'S001',
          'name': 'Main Campus Gate',
          'address': '123 University Ave, Campus',
          'coordinates': {'lat': 40.7128, 'lng': -74.0060},
        },
        {
          'id': 'S002',
          'name': 'North District Plaza',
          'address': '456 North St, District',
          'coordinates': {'lat': 40.7589, 'lng': -73.9851},
        },
        {
          'id': 'S003',
          'name': 'Community Center',
          'address': '789 Community Rd, North',
          'coordinates': {'lat': 40.7831, 'lng': -73.9712},
        },
      ],
      'createdAt': '2025-01-15T08:00:00Z',
    },
    {
      'id': 'R002',
      'routeNumber': 'R002',
      'routeName': 'South Campus - Downtown',
      'assignedBus': 'Bus A002 (Capacity: 50)',
      'driverName': 'Sarah Johnson',
      'status': 'Active',
      'capacity': 50,
      'currentOccupancy': 42,
      'stops': [
        {
          'id': 'S004',
          'name': 'South Campus Library',
          'address': '321 Library Lane, South Campus',
          'coordinates': {'lat': 40.6892, 'lng': -74.0445},
        },
        {
          'id': 'S005',
          'name': 'Downtown Transit Hub',
          'address': '654 Transit Ave, Downtown',
          'coordinates': {'lat': 40.7282, 'lng': -74.0776},
        },
      ],
      'createdAt': '2025-01-20T09:30:00Z',
    },
    {
      'id': 'R003',
      'routeNumber': 'R003',
      'routeName': 'East Campus - Residential',
      'assignedBus': 'Bus A003 (Capacity: 40)',
      'driverName': 'Michael Brown',
      'status': 'Maintenance',
      'capacity': 40,
      'currentOccupancy': 0,
      'stops': [
        {
          'id': 'S006',
          'name': 'East Campus Dormitory',
          'address': '987 Dorm Circle, East Campus',
          'coordinates': {'lat': 40.7505, 'lng': -73.9934},
        },
        {
          'id': 'S007',
          'name': 'Residential Complex A',
          'address': '147 Residential Blvd, East',
          'coordinates': {'lat': 40.7614, 'lng': -73.9776},
        },
        {
          'id': 'S008',
          'name': 'Shopping District',
          'address': '258 Shopping St, East',
          'coordinates': {'lat': 40.7749, 'lng': -73.9442},
        },
      ],
      'createdAt': '2025-01-25T07:15:00Z',
    },
  ];

  @override
  void initState() {
    super.initState();
    _refreshRoutes();
  }

  Future<void> _refreshRoutes() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  void _showCreateRouteWizard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RouteCreationWizardWidget(
        onCancel: () => Navigator.of(context).pop(),
        onSave: (routeData) {
          setState(() {
            _routes.add({
              ...routeData,
              'id': 'R${(_routes.length + 1).toString().padLeft(3, '0')}',
              'currentOccupancy': 0,
            });
          });
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Route created successfully!'),
              backgroundColor: AppTheme.successLight,
            ),
          );
        },
      ),
    );
  }

  void _editRoute(String routeId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit route $routeId - Feature coming soon!'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  void _duplicateRoute(String routeId) {
    final originalRoute = _routes.firstWhere((route) => route['id'] == routeId);
    final duplicatedRoute = Map<String, dynamic>.from(originalRoute);
    duplicatedRoute['id'] =
        'R${(_routes.length + 1).toString().padLeft(3, '0')}';
    duplicatedRoute['routeNumber'] = duplicatedRoute['id'];
    duplicatedRoute['routeName'] = '${duplicatedRoute['routeName']} (Copy)';
    duplicatedRoute['status'] = 'Inactive';
    duplicatedRoute['assignedBus'] = null;
    duplicatedRoute['driverName'] = null;
    duplicatedRoute['currentOccupancy'] = 0;
    duplicatedRoute['createdAt'] = DateTime.now().toIso8601String();

    setState(() {
      _routes.add(duplicatedRoute);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Route duplicated successfully!'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _archiveRoute(String routeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Route'),
        content: const Text(
            'Are you sure you want to archive this route? This action can be undone later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _routes.removeWhere((route) => route['id'] == routeId);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Route archived successfully!'),
                  backgroundColor: AppTheme.warningLight,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningLight,
              foregroundColor: AppTheme.onPrimaryLight,
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _updateRouteStops(String routeId, List<Map<String, dynamic>> newStops) {
    setState(() {
      final routeIndex = _routes.indexWhere((route) => route['id'] == routeId);
      if (routeIndex != -1) {
        _routes[routeIndex]['stops'] = newStops;
      }
    });
  }

  void _onOptimizationApplied(Map<String, dynamic> optimization) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Optimization applied: ${optimization['title']}'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _exportRouteData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Route Data'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CSV export started - Check downloads'),
                  backgroundColor: AppTheme.primaryLight,
                ),
              );
            },
            child: const Text('CSV'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF export started - Check downloads'),
                  backgroundColor: AppTheme.primaryLight,
                ),
              );
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      drawer: _buildDrawer(),
      body: Column(
        children: [
          // Header
          AdminHeaderWidget(
            adminName: 'Dr. Sarah Wilson',
            systemStatus: 'Online',
            showBackButton: true,
            onBackTap: () => Navigator.pop(context),
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            onNotificationTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications - Feature coming soon!'),
                  backgroundColor: AppTheme.primaryLight,
                ),
              );
            },
          ),

          // Action buttons row
          Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showOptimization = !_showOptimization;
                      });
                    },
                    icon: CustomIconWidget(
                      iconName: 'auto_awesome',
                      color: AppTheme.primaryLight,
                      size: 18,
                    ),
                    label: Text(_showOptimization
                        ? 'Hide Optimization'
                        : 'Show Optimization'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exportRouteData,
                    icon: CustomIconWidget(
                      iconName: 'download',
                      color: AppTheme.primaryLight,
                      size: 18,
                    ),
                    label: const Text('Export'),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshRoutes,
              color: AppTheme.primaryLight,
              child: CustomScrollView(
                slivers: [
                  // Optimization widget
                  if (_showOptimization)
                    SliverToBoxAdapter(
                      child: RouteOptimizationWidget(
                        routes: _routes,
                        onOptimizationApplied: _onOptimizationApplied,
                      ),
                    ),

                  // Routes header
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
                      child: Row(
                        children: [
                          Text(
                            'Routes (${_routes.length})',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.successLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_routes.where((r) => r['status'] == 'Active').length} Active',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.successLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Routes list
                  if (_isLoading)
                    SliverToBoxAdapter(
                      child: Container(
                        height: 30.h,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryLight),
                          ),
                        ),
                      ),
                    )
                  else if (_routes.isEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        height: 30.h,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'route',
                                color: isDark
                                    ? AppTheme.textMediumEmphasisDark
                                    : AppTheme.textMediumEmphasisLight,
                                size: 48,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'No routes found',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: isDark
                                          ? AppTheme.textMediumEmphasisDark
                                          : AppTheme.textMediumEmphasisLight,
                                    ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Create your first route to get started',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final route = _routes[index];
                          return RouteCardWidget(
                            route: route,
                            onEdit: () => _editRoute(route['id']),
                            onDuplicate: () => _duplicateRoute(route['id']),
                            onArchive: () => _archiveRoute(route['id']),
                            onStopsReordered: (newStops) =>
                                _updateRouteStops(route['id'], newStops),
                          );
                        },
                        childCount: _routes.length,
                      ),
                    ),

                  // Bottom spacing
                  SliverToBoxAdapter(
                    child: SizedBox(height: 10.h),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateRouteWizard,
        backgroundColor: AppTheme.secondaryLight,
        foregroundColor: AppTheme.onSecondaryLight,
        icon: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.onSecondaryLight,
          size: 24,
        ),
        label: const Text('Add Route'),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 15.w,
                      height: 7.h,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'S',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppTheme.onSecondaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SchoolBus Pro',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppTheme.onPrimaryLight,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Admin Dashboard',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.onPrimaryLight
                                      .withValues(alpha: 0.8),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'dashboard',
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'route',
                    color: AppTheme.secondaryLight,
                    size: 24,
                  ),
                  title: const Text('Route Management'),
                  selected: true,
                  selectedTileColor:
                      AppTheme.primaryLight.withValues(alpha: 0.1),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'book_online',
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                  title: const Text('School Bus Booking'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/bus-booking-form');
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'qr_code',
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                  title: const Text('QR Code Display'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/qr-code-display');
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'family_restroom',
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                  title: const Text('Parent Dashboard'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/parent-dashboard');
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'drive_eta',
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                  title: const Text('Driver Interface'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/driver-boarding-interface');
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'history',
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                  title: const Text('Booking History'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/booking-history');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'settings',
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'logout',
                    color: AppTheme.errorLight,
                    size: 24,
                  ),
                  title: const Text('Logout'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
