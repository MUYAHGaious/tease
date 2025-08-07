import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class EmergencyContactWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic>? initialData;

  const EmergencyContactWidget({
    Key? key,
    required this.onDataChanged,
    this.initialData,
  }) : super(key: key);

  @override
  State<EmergencyContactWidget> createState() => _EmergencyContactWidgetState();
}

class _EmergencyContactWidgetState extends State<EmergencyContactWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isExpanded = false;
  String _selectedCountryCode = '+1';
  bool _nameValid = true; // Optional field
  bool _phoneValid = true; // Optional field
  bool _relationValid = true; // Optional field

  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'country': 'US', 'name': 'United States'},
    {'code': '+44', 'country': 'GB', 'name': 'United Kingdom'},
    {'code': '+91', 'country': 'IN', 'name': 'India'},
    {'code': '+86', 'country': 'CN', 'name': 'China'},
    {'code': '+49', 'country': 'DE', 'name': 'Germany'},
    {'code': '+33', 'country': 'FR', 'name': 'France'},
    {'code': '+81', 'country': 'JP', 'name': 'Japan'},
    {'code': '+61', 'country': 'AU', 'name': 'Australia'},
    {'code': '+55', 'country': 'BR', 'name': 'Brazil'},
    {'code': '+7', 'country': 'RU', 'name': 'Russia'},
  ];

  final List<String> _relationshipOptions = [
    'Parent',
    'Spouse',
    'Sibling',
    'Child',
    'Friend',
    'Colleague',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _phoneController.text = widget.initialData!['phone'] ?? '';
      _relationController.text = widget.initialData!['relation'] ?? '';
      _selectedCountryCode = widget.initialData!['countryCode'] ?? '+1';
      _isExpanded = widget.initialData!['isExpanded'] ?? false;
      _validateFields();
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _animationController.forward();
    });

    _nameController.addListener(_validateFields);
    _phoneController.addListener(_validateFields);
    _relationController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      // Since this is optional, we only validate if fields are not empty
      _nameValid = _nameController.text.isEmpty ||
          (_nameController.text.length >= 2 &&
              RegExp(r'^[a-zA-Z\s]+$').hasMatch(_nameController.text));

      _phoneValid = _phoneController.text.isEmpty ||
          (_phoneController.text.length >= 10 &&
              RegExp(r'^[0-9]+$').hasMatch(_phoneController.text));

      _relationValid = _relationController.text.isEmpty ||
          _relationController.text.length >= 2;
    });
    _notifyDataChanged();
  }

  void _notifyDataChanged() {
    final hasData = _nameController.text.isNotEmpty ||
        _phoneController.text.isNotEmpty ||
        _relationController.text.isNotEmpty;

    widget.onDataChanged({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'relation': _relationController.text,
      'countryCode': _selectedCountryCode,
      'isExpanded': _isExpanded,
      'isValid': _nameValid && _phoneValid && _relationValid,
      'hasData': hasData,
    });
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                  ),
                ),
              ),
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
                    'Select Country Code',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 60),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _countryCodes.length,
                itemBuilder: (context, index) {
                  final country = _countryCodes[index];
                  final isSelected = country['code'] == _selectedCountryCode;

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      child: Center(
                        child: Text(
                          country['country']!,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                    title: Text(
                      country['name']!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          country['code']!,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (isSelected) ...[
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    selectedTileColor: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    onTap: () {
                      setState(() {
                        _selectedCountryCode = country['code']!;
                      });
                      _notifyDataChanged();
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRelationshipPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                  ),
                ),
              ),
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
                    'Select Relationship',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 60),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _relationshipOptions.length,
                itemBuilder: (context, index) {
                  final relation = _relationshipOptions[index];
                  final isSelected = relation == _relationController.text;

                  return ListTile(
                    title: Text(
                      relation,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: isSelected
                        ? CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          )
                        : null,
                    selected: isSelected,
                    selectedTileColor: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    onTap: () {
                      setState(() {
                        _relationController.text = relation;
                      });
                      _notifyDataChanged();
                      Navigator.pop(context);
                    },
                  );
                },
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
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                    _isExpanded = !_isExpanded;
                  });
                  _notifyDataChanged();
                },
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'emergency',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 24,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Contact',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              'Optional',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: CustomIconWidget(
                          iconName: 'expand_more',
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                height: _isExpanded ? null : 0,
                child: _isExpanded
                    ? Container(
                        padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                        child: Column(
                          children: [
                            // Name Field
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Contact Name',
                                hintText: 'Enter emergency contact name',
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
                                errorText: !_nameValid
                                    ? 'Please enter a valid name'
                                    : null,
                              ),
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                            ),

                            SizedBox(height: 2.h),

                            // Phone Field with Country Code
                            Row(
                              children: [
                                // Country Code Selector
                                GestureDetector(
                                  onTap: _showCountryCodePicker,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3.w, vertical: 4.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _selectedCountryCode,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        SizedBox(width: 1.w),
                                        CustomIconWidget(
                                          iconName: 'arrow_drop_down',
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(width: 2.w),

                                // Phone Number Field
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      hintText: 'Enter phone number',
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.all(3.w),
                                        child: CustomIconWidget(
                                          iconName: 'phone',
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          size: 20,
                                        ),
                                      ),
                                      errorText: !_phoneValid
                                          ? 'Please enter a valid phone number'
                                          : null,
                                    ),
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 2.h),

                            // Relationship Field
                            TextFormField(
                              controller: _relationController,
                              decoration: InputDecoration(
                                labelText: 'Relationship',
                                hintText: 'Select relationship',
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: CustomIconWidget(
                                    iconName: 'family_restroom',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    size: 20,
                                  ),
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: _showRelationshipPicker,
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
                                errorText: !_relationValid
                                    ? 'Please enter a valid relationship'
                                    : null,
                              ),
                              readOnly: true,
                              onTap: _showRelationshipPicker,
                            ),

                            SizedBox(height: 2.h),

                            // Info message
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.secondary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme
                                      .lightTheme.colorScheme.secondary
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'info',
                                    color: AppTheme
                                        .lightTheme.colorScheme.secondary,
                                    size: 16,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      'This contact will be notified in case of emergency during your journey.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
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
  }
}
