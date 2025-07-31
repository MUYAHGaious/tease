import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ContactInformationWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic>? initialData;

  const ContactInformationWidget({
    Key? key,
    required this.onDataChanged,
    this.initialData,
  }) : super(key: key);

  @override
  State<ContactInformationWidget> createState() =>
      _ContactInformationWidgetState();
}

class _ContactInformationWidgetState extends State<ContactInformationWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String _selectedCountryCode = '+1';
  bool _emailValid = false;
  bool _phoneValid = false;
  String? _emailError;
  String? _phoneError;
  bool _showCountryPicker = false;

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.initialData != null) {
      _emailController.text = widget.initialData!['email'] ?? '';
      _phoneController.text = widget.initialData!['phone'] ?? '';
      _selectedCountryCode = widget.initialData!['countryCode'] ?? '+1';
      _validateEmail(_emailController.text);
      _validatePhone(_phoneController.text);
    }

    _animationController.forward();
    _emailController.addListener(() => _validateEmail(_emailController.text));
    _phoneController.addListener(() => _validatePhone(_phoneController.text));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailValid = false;
        _emailError = 'Email is required';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _emailValid = false;
        _emailError = 'Please enter a valid email address';
      } else {
        _emailValid = true;
        _emailError = null;
      }
    });
    _notifyDataChanged();
  }

  void _validatePhone(String value) {
    setState(() {
      if (value.isEmpty) {
        _phoneValid = false;
        _phoneError = 'Phone number is required';
      } else if (value.length < 10) {
        _phoneValid = false;
        _phoneError = 'Phone number must be at least 10 digits';
      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        _phoneValid = false;
        _phoneError = 'Phone number can only contain digits';
      } else {
        _phoneValid = true;
        _phoneError = null;
      }
    });
    _notifyDataChanged();
  }

  void _notifyDataChanged() {
    widget.onDataChanged({
      'email': _emailController.text,
      'phone': _phoneController.text,
      'countryCode': _selectedCountryCode,
      'isValid': _emailValid && _phoneValid,
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0.0, _slideAnimation.value),
          end: Offset.zero,
        ).animate(_animationController),
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
                    iconName: 'contact_mail',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),

              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter your email address',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'email',
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      errorText: _emailError,
                      suffixIcon: _emailValid
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
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                  ),
                  if (_emailError != null) SizedBox(height: 1.h),
                ],
              ),

              SizedBox(height: 2.h),

              // Phone Field with Country Code
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              color: Theme.of(context).colorScheme.outline,
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
                            errorText: _phoneError,
                            suffixIcon: _phoneValid
                                ? Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: CustomIconWidget(
                                      iconName: 'check_circle',
                                      color: AppTheme
                                          .lightTheme.colorScheme.tertiary,
                                      size: 20,
                                    ),
                                  )
                                : null,
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                  if (_phoneError != null) SizedBox(height: 1.h),
                ],
              ),

              SizedBox(height: 2.h),

              // Auto-fill suggestion
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'We\'ll use this information for booking confirmations and updates.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
        ),
      ),
    );
  }
}