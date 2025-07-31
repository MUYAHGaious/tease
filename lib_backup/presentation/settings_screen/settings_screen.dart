import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'XFA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 2.h),
            _buildSection(
              'General',
              [
                _buildSwitchItem(
                  'Push Notifications',
                  'Receive booking updates and offers',
                  _notificationsEnabled,
                  (value) => setState(() => _notificationsEnabled = value),
                ),
                _buildSwitchItem(
                  'Location Services',
                  'Find nearby bus stops and get accurate timing',
                  _locationEnabled,
                  (value) => setState(() => _locationEnabled = value),
                ),
                _buildDropdownItem(
                  'Language',
                  'Choose your preferred language',
                  _selectedLanguage,
                  ['English', 'French', 'Fulfulde', 'Ewondo'],
                  (value) => setState(() => _selectedLanguage = value!),
                ),
                _buildDropdownItem(
                  'Currency',
                  'Select your preferred currency',
                  _selectedCurrency,
                  ['XFA', 'FCFA', 'USD', 'EUR'],
                  (value) => setState(() => _selectedCurrency = value!),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildSection(
              'Appearance',
              [
                _buildSwitchItem(
                  'Dark Mode',
                  'Use dark theme for better viewing at night',
                  _darkModeEnabled,
                  (value) => setState(() => _darkModeEnabled = value),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildSection(
              'Privacy & Security',
              [
                _buildActionItem(
                  'Privacy Policy',
                  'Read our privacy policy',
                  () => _showPrivacyPolicy(),
                ),
                _buildActionItem(
                  'Terms of Service',
                  'View terms and conditions',
                  () => _showTermsOfService(),
                ),
                _buildActionItem(
                  'Data & Storage',
                  'Manage your personal data',
                  () => _showDataManagement(),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildSection(
              'Support',
              [
                _buildActionItem(
                  'Help Center',
                  'Get help and support',
                  () => _openHelpCenter(),
                ),
                _buildActionItem(
                  'Contact Us',
                  'Reach out to our support team',
                  () => _contactSupport(),
                ),
                _buildActionItem(
                  'Rate App',
                  'Rate Tease on app store',
                  () => _rateApp(),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildSection(
              'About',
              [
                _buildInfoItem('Version', '1.0.0'),
                _buildInfoItem('Build', '2025.01.20'),
                _buildActionItem(
                  'Licenses',
                  'Open source licenses',
                  () => _showLicenses(),
                ),
              ],
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
            child: Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  Widget _buildDropdownItem(
    String title,
    String subtitle,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: Container(),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionItem(
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        value,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    // Implementation for privacy policy
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: Text('Privacy policy content would be shown here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    // Implementation for terms of service
  }

  void _showDataManagement() {
    // Implementation for data management
  }

  void _openHelpCenter() {
    // Implementation for help center
  }

  void _contactSupport() {
    // Implementation for contact support
  }

  void _rateApp() {
    // Implementation for app rating
  }

  void _showLicenses() {
    showLicensePage(context: context);
  }
}