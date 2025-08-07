import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class AdditionalPassengersWidget extends StatefulWidget {
  final int seatCount;
  final Function(List<Map<String, dynamic>>) onDataChanged;
  final List<Map<String, dynamic>>? initialData;

  const AdditionalPassengersWidget({
    Key? key,
    required this.seatCount,
    required this.onDataChanged,
    this.initialData,
  }) : super(key: key);

  @override
  State<AdditionalPassengersWidget> createState() =>
      _AdditionalPassengersWidgetState();
}

class _AdditionalPassengersWidgetState extends State<AdditionalPassengersWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  List<Map<String, dynamic>> _passengers = [];
  List<bool> _expandedStates = [];

  @override
  void initState() {
    super.initState();
    _initializePassengers();
    _initializeAnimations();
  }

  void _initializePassengers() {
    final additionalCount = widget.seatCount - 1; // Excluding primary passenger
    _passengers = List.generate(additionalCount, (index) {
      if (widget.initialData != null && index < widget.initialData!.length) {
        return Map<String, dynamic>.from(widget.initialData![index]);
      }
      return {
        'name': '',
        'age': null,
        'gender': 'Male',
        'isValid': false,
        'nameController': TextEditingController(),
        'ageController': TextEditingController(),
      };
    });
    _expandedStates = List.generate(additionalCount, (index) => index == 0);
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      _passengers.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _slideAnimations = _animationControllers
        .map(
          (controller) => Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
          ),
        )
        .toList();

    _fadeAnimations = _animationControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();

    // Start animations with staggered delay
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _animationControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    for (var passenger in _passengers) {
      passenger['nameController']?.dispose();
      passenger['ageController']?.dispose();
    }
    super.dispose();
  }

  void _validatePassenger(int index) {
    final passenger = _passengers[index];
    final name = passenger['nameController'].text;
    final age = passenger['ageController'].text;

    bool nameValid = name.isNotEmpty &&
        name.length >= 2 &&
        RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
    bool ageValid = age.isNotEmpty &&
        int.tryParse(age) != null &&
        int.parse(age) >= 1 &&
        int.parse(age) <= 120;

    setState(() {
      passenger['name'] = name;
      passenger['age'] = int.tryParse(age);
      passenger['isValid'] = nameValid && ageValid;
    });

    widget.onDataChanged(_passengers);
  }

  void _showAgePicker(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                    ),
                  ),
                  Text(
                    'Select Age',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Done',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListWheelScrollView.useDelegate(
                itemExtent: 50,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (ageIndex) {
                  _passengers[index]['ageController'].text =
                      (ageIndex + 1).toString();
                  _validatePassenger(index);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, ageIndex) {
                    final age = ageIndex + 1;
                    return Center(
                      child: Text(
                        age.toString(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    );
                  },
                  childCount: 120,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerCard(int index) {
    final passenger = _passengers[index];
    final isExpanded = _expandedStates[index];

    return AnimatedBuilder(
      animation: _fadeAnimations[index],
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimations[index],
          child: SlideTransition(
            position: _slideAnimations[index],
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedStates[index] = !_expandedStates[index];
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'person_add',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 24,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Passenger ${index + 2}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          if (passenger['isValid'])
                            CustomIconWidget(
                              iconName: 'check_circle',
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              size: 20,
                            ),
                          SizedBox(width: 2.w),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: CustomIconWidget(
                              iconName: 'expand_more',
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expandable Content
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: isExpanded ? null : 0,
                    child: isExpanded
                        ? Container(
                            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                            child: Column(
                              children: [
                                // Name Field
                                TextFormField(
                                  controller: passenger['nameController'],
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    hintText: 'Enter passenger name',
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(3.w),
                                      child: CustomIconWidget(
                                        iconName: 'person_outline',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  onChanged: (_) => _validatePassenger(index),
                                ),

                                SizedBox(height: 2.h),

                                // Age Field
                                TextFormField(
                                  controller: passenger['ageController'],
                                  decoration: InputDecoration(
                                    labelText: 'Age',
                                    hintText: 'Enter age',
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(3.w),
                                      child: CustomIconWidget(
                                        iconName: 'cake',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        size: 20,
                                      ),
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () => _showAgePicker(index),
                                      child: Padding(
                                        padding: EdgeInsets.all(3.w),
                                        child: CustomIconWidget(
                                          iconName: 'arrow_drop_down',
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: () => _showAgePicker(index),
                                ),

                                SizedBox(height: 2.h),

                                // Gender Selection
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Gender',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  passenger['gender'] = 'Male';
                                                });
                                                widget
                                                    .onDataChanged(_passengers);
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 3.h),
                                                decoration: BoxDecoration(
                                                  color:
                                                      passenger['gender'] ==
                                                              'Male'
                                                          ? AppTheme
                                                              .lightTheme
                                                              .colorScheme
                                                              .primary
                                                          : Colors.transparent,
                                                  borderRadius:
                                                      const BorderRadius
                                                          .horizontal(
                                                    left: Radius.circular(12),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    CustomIconWidget(
                                                      iconName: 'male',
                                                      color: passenger[
                                                                  'gender'] ==
                                                              'Male'
                                                          ? AppTheme
                                                              .lightTheme
                                                              .colorScheme
                                                              .onPrimary
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onSurface,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 2.w),
                                                    Text(
                                                      'Male',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            color: passenger[
                                                                        'gender'] ==
                                                                    'Male'
                                                                ? AppTheme
                                                                    .lightTheme
                                                                    .colorScheme
                                                                    .onPrimary
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onSurface,
                                                            fontWeight:
                                                                passenger['gender'] ==
                                                                        'Male'
                                                                    ? FontWeight
                                                                        .w600
                                                                    : FontWeight
                                                                        .w400,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  passenger['gender'] =
                                                      'Female';
                                                });
                                                widget
                                                    .onDataChanged(_passengers);
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 3.h),
                                                decoration: BoxDecoration(
                                                  color:
                                                      passenger['gender'] ==
                                                              'Female'
                                                          ? AppTheme
                                                              .lightTheme
                                                              .colorScheme
                                                              .primary
                                                          : Colors.transparent,
                                                  borderRadius:
                                                      const BorderRadius
                                                          .horizontal(
                                                    right: Radius.circular(12),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    CustomIconWidget(
                                                      iconName: 'female',
                                                      color: passenger[
                                                                  'gender'] ==
                                                              'Female'
                                                          ? AppTheme
                                                              .lightTheme
                                                              .colorScheme
                                                              .onPrimary
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onSurface,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 2.w),
                                                    Text(
                                                      'Female',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            color: passenger[
                                                                        'gender'] ==
                                                                    'Female'
                                                                ? AppTheme
                                                                    .lightTheme
                                                                    .colorScheme
                                                                    .onPrimary
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onSurface,
                                                            fontWeight:
                                                                passenger['gender'] ==
                                                                        'Female'
                                                                    ? FontWeight
                                                                        .w600
                                                                    : FontWeight
                                                                        .w400,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_passengers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Text(
            'Additional Passengers',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...List.generate(
            _passengers.length, (index) => _buildPassengerCard(index)),
      ],
    );
  }
}