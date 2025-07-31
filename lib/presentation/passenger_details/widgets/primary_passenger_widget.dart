import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PrimaryPassengerWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic>? initialData;

  const PrimaryPassengerWidget({
    Key? key,
    required this.onDataChanged,
    this.initialData,
  }) : super(key: key);

  @override
  State<PrimaryPassengerWidget> createState() => _PrimaryPassengerWidgetState();
}

class _PrimaryPassengerWidgetState extends State<PrimaryPassengerWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedGender = 'Male';
  bool _nameValid = false;
  bool _ageValid = false;
  String? _nameError;
  String? _ageError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _ageController.text = widget.initialData!['age']?.toString() ?? '';
      _selectedGender = widget.initialData!['gender'] ?? 'Male';
      _validateName(_nameController.text);
      _validateAge(_ageController.text);
    }

    _animationController.forward();
    _nameController.addListener(() => _validateName(_nameController.text));
    _ageController.addListener(() => _validateAge(_ageController.text));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameValid = false;
        _nameError = 'Name is required';
      } else if (value.length < 2) {
        _nameValid = false;
        _nameError = 'Name must be at least 2 characters';
      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
        _nameValid = false;
        _nameError = 'Name can only contain letters and spaces';
      } else {
        _nameValid = true;
        _nameError = null;
      }
    });
    _notifyDataChanged();
  }

  void _validateAge(String value) {
    setState(() {
      if (value.isEmpty) {
        _ageValid = false;
        _ageError = 'Age is required';
      } else {
        final age = int.tryParse(value);
        if (age == null || age < 1 || age > 120) {
          _ageValid = false;
          _ageError = 'Please enter a valid age (1-120)';
        } else {
          _ageValid = true;
          _ageError = null;
        }
      }
    });
    _notifyDataChanged();
  }

  void _notifyDataChanged() {
    widget.onDataChanged({
      'name': _nameController.text,
      'age': int.tryParse(_ageController.text),
      'gender': _selectedGender,
      'isValid': _nameValid && _ageValid,
    });
  }

  void _showAgePicker() {
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
                onSelectedItemChanged: (index) {
                  _ageController.text = (index + 1).toString();
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    final age = index + 1;
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        padding: EdgeInsets.all(4.w),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'person',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Primary Passenger',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Name Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'person_outline',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    errorText: _nameError,
                    suffixIcon: _nameValid
                        ? Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CustomIconWidget(
                              iconName: 'check_circle',
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                ),
                if (_nameError != null) SizedBox(height: 1.h),
              ],
            ),

            SizedBox(height: 2.h),

            // Age Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    hintText: 'Enter age',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'cake',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: _showAgePicker,
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'arrow_drop_down',
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                    errorText: _ageError,
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  readOnly: true,
                  onTap: _showAgePicker,
                ),
                if (_ageError != null) SizedBox(height: 1.h),
              ],
            ),

            SizedBox(height: 2.h),

            // Gender Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                SizedBox(height: 1.h),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedGender = 'Male');
                            _notifyDataChanged();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(vertical: 3.h),
                            decoration: BoxDecoration(
                              color: _selectedGender == 'Male'
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'male',
                                  color: _selectedGender == 'Male'
                                      ? AppTheme
                                          .lightTheme.colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Male',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: _selectedGender == 'Male'
                                            ? AppTheme.lightTheme.colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                        fontWeight: _selectedGender == 'Male'
                                            ? FontWeight.w600
                                            : FontWeight.w400,
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
                            setState(() => _selectedGender = 'Female');
                            _notifyDataChanged();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(vertical: 3.h),
                            decoration: BoxDecoration(
                              color: _selectedGender == 'Female'
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'female',
                                  color: _selectedGender == 'Female'
                                      ? AppTheme
                                          .lightTheme.colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Female',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: _selectedGender == 'Female'
                                            ? AppTheme.lightTheme.colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                        fontWeight: _selectedGender == 'Female'
                                            ? FontWeight.w600
                                            : FontWeight.w400,
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
      ),
    );
  }
}
