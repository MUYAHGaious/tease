import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class BillingAddressSection extends StatefulWidget {
  final Function(Map<String, String>) onAddressChanged;

  const BillingAddressSection({
    Key? key,
    required this.onAddressChanged,
  }) : super(key: key);

  @override
  State<BillingAddressSection> createState() => _BillingAddressSectionState();
}

class _BillingAddressSectionState extends State<BillingAddressSection> {
  bool _isExpanded = false;
  bool _isEditing = false;

  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();

  // Mock user profile data
  final Map<String, String> _defaultAddress = {
    "street": "123 Main Street, Apt 4B",
    "city": "New York",
    "state": "NY",
    "zip": "10001",
    "country": "United States",
  };

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
    _streetController.addListener(_onAddressChanged);
    _cityController.addListener(_onAddressChanged);
    _stateController.addListener(_onAddressChanged);
    _zipController.addListener(_onAddressChanged);
    _countryController.addListener(_onAddressChanged);
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _loadDefaultAddress() {
    _streetController.text = _defaultAddress["street"]!;
    _cityController.text = _defaultAddress["city"]!;
    _stateController.text = _defaultAddress["state"]!;
    _zipController.text = _defaultAddress["zip"]!;
    _countryController.text = _defaultAddress["country"]!;
    _onAddressChanged();
  }

  void _onAddressChanged() {
    final address = {
      "street": _streetController.text,
      "city": _cityController.text,
      "state": _stateController.text,
      "zip": _zipController.text,
      "country": _countryController.text,
    };
    widget.onAddressChanged(address);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (_isExpanded) _buildExpandedContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'location_on',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Billing Address',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${_cityController.text}, ${_stateController.text} ${_zipController.text}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (_isExpanded && !_isEditing)
              TextButton(
                onPressed: () => setState(() => _isEditing = true),
                child: Text('Edit'),
              ),
            CustomIconWidget(
              iconName:
                  _isExpanded ? 'keyboard_arrow_up' : 'keyboard_arrow_down',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppTheme.lightTheme.dividerColor),
          SizedBox(height: 2.h),
          if (_isEditing) _buildEditableForm() else _buildReadOnlyView(),
        ],
      ),
    );
  }

  Widget _buildReadOnlyView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAddressRow('Street Address', _streetController.text),
        SizedBox(height: 1.h),
        _buildAddressRow('City', _cityController.text),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(child: _buildAddressRow('State', _stateController.text)),
            SizedBox(width: 4.w),
            Expanded(child: _buildAddressRow('ZIP Code', _zipController.text)),
          ],
        ),
        SizedBox(height: 1.h),
        _buildAddressRow('Country', _countryController.text),
      ],
    );
  }

  Widget _buildAddressRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEditableForm() {
    return Column(
      children: [
        TextFormField(
          controller: _streetController,
          decoration: InputDecoration(
            labelText: 'Street Address',
            hintText: 'Enter your street address',
            prefixIcon: CustomIconWidget(
              iconName: 'home',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: _cityController,
          decoration: InputDecoration(
            labelText: 'City',
            hintText: 'Enter city',
            prefixIcon: CustomIconWidget(
              iconName: 'location_city',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                  labelText: 'State',
                  hintText: 'NY',
                  prefixIcon: CustomIconWidget(
                    iconName: 'map',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: TextFormField(
                controller: _zipController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ZIP Code',
                  hintText: '10001',
                  prefixIcon: CustomIconWidget(
                    iconName: 'markunread_mailbox',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: _countryController,
          decoration: InputDecoration(
            labelText: 'Country',
            hintText: 'United States',
            prefixIcon: CustomIconWidget(
              iconName: 'public',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
        SizedBox(height: 3.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _loadDefaultAddress();
                  setState(() => _isEditing = false);
                },
                child: Text('Cancel'),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _isEditing = false),
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
