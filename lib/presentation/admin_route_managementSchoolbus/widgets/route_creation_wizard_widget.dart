import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RouteCreationWizardWidget extends StatefulWidget {
  final VoidCallback? onCancel;
  final Function(Map<String, dynamic>)? onSave;

  const RouteCreationWizardWidget({
    super.key,
    this.onCancel,
    this.onSave,
  });

  @override
  State<RouteCreationWizardWidget> createState() =>
      _RouteCreationWizardWidgetState();
}

class _RouteCreationWizardWidgetState extends State<RouteCreationWizardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentStep = 0;

  // Form controllers
  final _routeNumberController = TextEditingController();
  final _routeNameController = TextEditingController();
  final _capacityController = TextEditingController();

  // Form data
  String? _selectedBus;
  String? _selectedDriver;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<Map<String, dynamic>> _stops = [];

  // Mock data
  final List<String> _availableBuses = [
    'Bus A001 (Capacity: 45)',
    'Bus A002 (Capacity: 50)',
    'Bus A003 (Capacity: 40)',
    'Bus A004 (Capacity: 48)',
  ];

  final List<String> _availableDrivers = [
    'John Smith',
    'Sarah Johnson',
    'Michael Brown',
    'Emily Davis',
    'Robert Wilson',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentStep = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _routeNumberController.dispose();
    _routeNameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _tabController.animateTo(_currentStep + 1);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _tabController.animateTo(_currentStep - 1);
    }
  }

  void _addStop() {
    showDialog(
      context: context,
      builder: (context) => _AddStopDialog(
        onAdd: (stop) {
          setState(() {
            _stops.add(stop);
          });
        },
      ),
    );
  }

  void _removeStop(int index) {
    setState(() {
      _stops.removeAt(index);
    });
  }

  void _saveRoute() {
    final routeData = {
      'routeNumber': _routeNumberController.text,
      'routeName': _routeNameController.text,
      'assignedBus': _selectedBus,
      'driverName': _selectedDriver,
      'capacity': int.tryParse(_capacityController.text) ?? 0,
      'startTime': _startTime?.format(context),
      'endTime': _endTime?.format(context),
      'stops': _stops,
      'status': 'Active',
      'createdAt': DateTime.now().toIso8601String(),
    };

    widget.onSave?.call(routeData);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(
                  'Create New Route',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.onPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.onPrimaryLight,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Progress indicator
          Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: List.generate(4, (index) {
                final isActive = index <= _currentStep;
                final isCompleted = index < _currentStep;

                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.successLight
                              : isActive
                                  ? AppTheme.secondaryLight
                                  : (isDark
                                      ? AppTheme.dividerDark
                                      : AppTheme.dividerLight),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? CustomIconWidget(
                                  iconName: 'check',
                                  color: AppTheme.onPrimaryLight,
                                  size: 16,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: isActive
                                            ? AppTheme.onSecondaryLight
                                            : (isDark
                                                ? AppTheme
                                                    .textMediumEmphasisDark
                                                : AppTheme
                                                    .textMediumEmphasisLight),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                        ),
                      ),
                      if (index < 3)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: isCompleted
                                ? AppTheme.successLight
                                : (isDark
                                    ? AppTheme.dividerDark
                                    : AppTheme.dividerLight),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppTheme.primaryLight,
            unselectedLabelColor: isDark
                ? AppTheme.textMediumEmphasisDark
                : AppTheme.textMediumEmphasisLight,
            indicatorColor: AppTheme.secondaryLight,
            tabs: const [
              Tab(text: 'Basic Info'),
              Tab(text: 'Assignment'),
              Tab(text: 'Schedule'),
              Tab(text: 'Stops'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoStep(),
                _buildAssignmentStep(),
                _buildScheduleStep(),
                _buildStopsStep(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                ),
              ),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == 3 ? _saveRoute : _nextStep,
                    child: Text(_currentStep == 3 ? 'Create Route' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 3.h),
          TextField(
            controller: _routeNumberController,
            decoration: const InputDecoration(
              labelText: 'Route Number',
              hintText: 'e.g., R001',
              prefixIcon: Icon(Icons.route),
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _routeNameController,
            decoration: const InputDecoration(
              labelText: 'Route Name',
              hintText: 'e.g., Main Campus - North District',
              prefixIcon: Icon(Icons.label),
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _capacityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Passenger Capacity',
              hintText: 'e.g., 45',
              prefixIcon: Icon(Icons.people),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bus & Driver Assignment',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 3.h),
          DropdownButtonFormField<String>(
            value: _selectedBus,
            decoration: const InputDecoration(
              labelText: 'Assigned Bus',
              prefixIcon: Icon(Icons.directions_bus),
            ),
            items: _availableBuses.map((bus) {
              return DropdownMenuItem(
                value: bus,
                child: Text(bus),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBus = value;
              });
            },
          ),
          SizedBox(height: 2.h),
          DropdownButtonFormField<String>(
            value: _selectedDriver,
            decoration: const InputDecoration(
              labelText: 'Assigned Driver',
              prefixIcon: Icon(Icons.person),
            ),
            items: _availableDrivers.map((driver) {
              return DropdownMenuItem(
                value: driver,
                child: Text(driver),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDriver = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route Schedule',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 3.h),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'schedule',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            title: const Text('Start Time'),
            subtitle: Text(_startTime?.format(context) ?? 'Not set'),
            trailing: CustomIconWidget(
              iconName: 'keyboard_arrow_right',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _startTime ?? TimeOfDay.now(),
              );
              if (time != null) {
                setState(() {
                  _startTime = time;
                });
              }
            },
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'schedule',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            title: const Text('End Time'),
            subtitle: Text(_endTime?.format(context) ?? 'Not set'),
            trailing: CustomIconWidget(
              iconName: 'keyboard_arrow_right',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _endTime ?? TimeOfDay.now(),
              );
              if (time != null) {
                setState(() {
                  _endTime = time;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStopsStep() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              Text(
                'Route Stops (${_stops.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addStop,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: AppTheme.onSecondaryLight,
                  size: 18,
                ),
                label: const Text('Add Stop'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _stops.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'location_off',
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.textMediumEmphasisDark
                            : AppTheme.textMediumEmphasisLight,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No stops added yet',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppTheme.textMediumEmphasisDark
                                  : AppTheme.textMediumEmphasisLight,
                            ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Add stops to complete your route',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: _stops.length,
                  itemBuilder: (context, index) {
                    final stop = _stops[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 2.h),
                      child: ListTile(
                        leading: Container(
                          width: 8.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: AppTheme.onSecondaryLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        title: Text(stop['name'] ?? 'Unknown Stop'),
                        subtitle: Text(stop['address'] ?? 'No address'),
                        trailing: IconButton(
                          onPressed: () => _removeStop(index),
                          icon: CustomIconWidget(
                            iconName: 'delete',
                            color: AppTheme.errorLight,
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AddStopDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const _AddStopDialog({required this.onAdd});

  @override
  State<_AddStopDialog> createState() => _AddStopDialogState();
}

class _AddStopDialogState extends State<_AddStopDialog> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _addStop() {
    if (_nameController.text.isNotEmpty && _addressController.text.isNotEmpty) {
      widget.onAdd({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': _nameController.text,
        'address': _addressController.text,
        'coordinates': {
          'lat': 40.7128 + (DateTime.now().millisecond / 10000),
          'lng': -74.0060 + (DateTime.now().millisecond / 10000),
        },
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Stop'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Stop Name',
              hintText: 'e.g., Main Street Station',
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              hintText: 'e.g., 123 Main Street',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addStop,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
