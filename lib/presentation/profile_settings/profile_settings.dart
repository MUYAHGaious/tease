import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/animated_toggle_widget.dart';
import './widgets/language_selector_widget.dart';
import './widgets/payment_card_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/user_header_widget.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({Key? key}) : super(key: key);

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // User preferences state
  bool _darkModeEnabled = false;
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = false;
  bool _bookingNotifications = true;
  bool _tripReminders = true;
  bool _promotionalOffers = false;
  bool _priceAlerts = true;
  bool _reducedMotion = false;
  String _selectedLanguage = "en";

  // Mock user data
  final Map<String, dynamic> userData = {
    "id": 1,
    "name": "Sarah Johnson",
    "email": "sarah.johnson@email.com",
    "avatar":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?fm=jpg&q=60&w=400&ixlib=rb-4.0.3",
    "membershipTier": "Gold Member",
    "loyaltyPoints": 2450,
    "nextTierPoints": 3000,
    "phone": "+1 (555) 123-4567",
    "dateOfBirth": "1990-03-15",
    "preferredSeat": "Window",
    "savedRoutes": ["New York - Boston", "Boston - Philadelphia"],
  };

  // Mock payment cards data
  final List<Map<String, dynamic>> paymentCards = [
    {
      "id": 1,
      "type": "Visa",
      "lastFour": "4532",
      "holderName": "SARAH JOHNSON",
      "expiryDate": "12/26",
      "isDefault": true,
    },
    {
      "id": 2,
      "type": "Mastercard",
      "lastFour": "8901",
      "holderName": "SARAH JOHNSON",
      "expiryDate": "08/25",
      "isDefault": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _handleEditProfile() {
    _showEditProfileDialog();
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: const Text(
            "Profile editing functionality would be implemented here with form fields for name, email, phone, etc."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _handleDeleteCard(int cardId) {
    setState(() {
      paymentCards.removeWhere((card) => card["id"] == cardId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment method removed")),
    );
  }

  void _handleAddPaymentMethod() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              "Add payment method functionality would be implemented here")),
    );
  }

  void _handleChangePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: const Text(
            "Password change functionality would be implemented here with secure form fields."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/splash-screen',
                (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Delete Account",
          style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
        ),
        content: const Text(
            "This action cannot be undone. All your data will be permanently deleted."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text("Delete Account"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profile Settings"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Theme.of(context).colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: CustomIconWidget(
              iconName: 'logout',
              color: Theme.of(context).colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Column(
            children: [
              // User Header
              UserHeaderWidget(
                userData: userData,
                onEditProfile: _handleEditProfile,
              ),

              SizedBox(height: 3.h),

              // Personal Information Section
              SettingsSectionWidget(
                title: "Personal Information",
                children: [
                  SettingsItemWidget(
                    iconName: 'person',
                    title: "Edit Profile",
                    subtitle: "Update your personal details",
                    onTap: _handleEditProfile,
                  ),
                  SettingsItemWidget(
                    iconName: 'phone',
                    title: "Phone Number",
                    subtitle: userData["phone"] as String,
                    onTap: () {},
                  ),
                  SettingsItemWidget(
                    iconName: 'cake',
                    title: "Date of Birth",
                    subtitle: userData["dateOfBirth"] as String,
                    onTap: () {},
                    showDivider: false,
                  ),
                ],
              ),

              // Travel Preferences Section
              SettingsSectionWidget(
                title: "Travel Preferences",
                children: [
                  SettingsItemWidget(
                    iconName: 'airline_seat_recline_normal',
                    title: "Preferred Seat",
                    subtitle: userData["preferredSeat"] as String,
                    onTap: () {},
                  ),
                  SettingsItemWidget(
                    iconName: 'route',
                    title: "Saved Routes",
                    subtitle:
                        "${(userData["savedRoutes"] as List).length} routes saved",
                    onTap: () {},
                    showDivider: false,
                  ),
                ],
              ),

              // Payment Methods Section
              SettingsSectionWidget(
                title: "Payment Methods",
                children: [
                  Container(
                    height: 20.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: paymentCards.length + 1,
                      itemBuilder: (context, index) {
                        if (index == paymentCards.length) {
                          return GestureDetector(
                            onTap: _handleAddPaymentMethod,
                            child: Container(
                              width: 70.w,
                              margin: EdgeInsets.only(right: 4.w),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'add_circle_outline',
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 10.w,
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    "Add Payment Method",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final card = paymentCards[index];
                        return PaymentCardWidget(
                          cardData: card,
                          isDefault: card["isDefault"] as bool,
                          onDelete: () => _handleDeleteCard(card["id"] as int),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Notifications Section
              SettingsSectionWidget(
                title: "Notifications",
                children: [
                  SettingsItemWidget(
                    iconName: 'notifications',
                    title: "Booking Confirmations",
                    subtitle: "Get notified about booking status",
                    trailing: AnimatedToggleWidget(
                      value: _bookingNotifications,
                      onChanged: (value) {
                        setState(() {
                          _bookingNotifications = value;
                        });
                      },
                    ),
                    showDivider: true,
                  ),
                  SettingsItemWidget(
                    iconName: 'schedule',
                    title: "Trip Reminders",
                    subtitle: "Reminders before your trips",
                    trailing: AnimatedToggleWidget(
                      value: _tripReminders,
                      onChanged: (value) {
                        setState(() {
                          _tripReminders = value;
                        });
                      },
                    ),
                    showDivider: true,
                  ),
                  SettingsItemWidget(
                    iconName: 'local_offer',
                    title: "Promotional Offers",
                    subtitle: "Special deals and discounts",
                    trailing: AnimatedToggleWidget(
                      value: _promotionalOffers,
                      onChanged: (value) {
                        setState(() {
                          _promotionalOffers = value;
                        });
                      },
                    ),
                    showDivider: true,
                  ),
                  SettingsItemWidget(
                    iconName: 'trending_down',
                    title: "Price Alerts",
                    subtitle: "Notify when prices drop",
                    trailing: AnimatedToggleWidget(
                      value: _priceAlerts,
                      onChanged: (value) {
                        setState(() {
                          _priceAlerts = value;
                        });
                      },
                    ),
                    showDivider: false,
                  ),
                ],
              ),

              // App Settings Section
              SettingsSectionWidget(
                title: "App Settings",
                children: [
                  SettingsItemWidget(
                    iconName: 'dark_mode',
                    title: "Dark Mode",
                    subtitle: "Switch to dark theme",
                    trailing: AnimatedToggleWidget(
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                      },
                    ),
                    showDivider: true,
                  ),
                  SettingsItemWidget(
                    iconName: 'language',
                    title: "Language",
                    subtitle: "App display language",
                    trailing: LanguageSelectorWidget(
                      currentLanguage: _selectedLanguage,
                      onLanguageChanged: (language) {
                        setState(() {
                          _selectedLanguage = language;
                        });
                      },
                    ),
                    showDivider: true,
                  ),
                  SettingsItemWidget(
                    iconName: 'accessibility',
                    title: "Reduced Motion",
                    subtitle: "Minimize animations",
                    trailing: AnimatedToggleWidget(
                      value: _reducedMotion,
                      onChanged: (value) {
                        setState(() {
                          _reducedMotion = value;
                        });
                      },
                    ),
                    showDivider: false,
                  ),
                ],
              ),

              // Security Section
              SettingsSectionWidget(
                title: "Security",
                children: [
                  SettingsItemWidget(
                    iconName: 'lock',
                    title: "Change Password",
                    subtitle: "Update your account password",
                    onTap: _handleChangePassword,
                  ),
                  SettingsItemWidget(
                    iconName: 'fingerprint',
                    title: "Biometric Authentication",
                    subtitle: "Use fingerprint or face ID",
                    trailing: AnimatedToggleWidget(
                      value: _biometricEnabled,
                      onChanged: (value) {
                        setState(() {
                          _biometricEnabled = value;
                        });
                      },
                    ),
                    showDivider: true,
                  ),
                  SettingsItemWidget(
                    iconName: 'security',
                    title: "Two-Factor Authentication",
                    subtitle: "Extra security for your account",
                    trailing: AnimatedToggleWidget(
                      value: _twoFactorEnabled,
                      onChanged: (value) {
                        setState(() {
                          _twoFactorEnabled = value;
                        });
                      },
                    ),
                    showDivider: true,
                  ),
                  SettingsItemWidget(
                    iconName: 'devices',
                    title: "Active Sessions",
                    subtitle: "Manage logged in devices",
                    onTap: () {},
                    showDivider: false,
                  ),
                ],
              ),

              // Account Actions Section
              SettingsSectionWidget(
                title: "Account",
                children: [
                  SettingsItemWidget(
                    iconName: 'help',
                    title: "Help & Support",
                    subtitle: "Get help with your account",
                    onTap: () {},
                  ),
                  SettingsItemWidget(
                    iconName: 'privacy_tip',
                    title: "Privacy Policy",
                    subtitle: "Read our privacy policy",
                    onTap: () {},
                  ),
                  SettingsItemWidget(
                    iconName: 'description',
                    title: "Terms of Service",
                    subtitle: "View terms and conditions",
                    onTap: () {},
                  ),
                  SettingsItemWidget(
                    iconName: 'delete_forever',
                    title: "Delete Account",
                    subtitle: "Permanently delete your account",
                    onTap: _handleDeleteAccount,
                    showDivider: false,
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              // App Version
              Text(
                "Tease v1.2.3",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 4, // Profile tab active
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home-dashboard');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/passenger-details');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/payment-gateway');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/my-tickets');
                break;
              case 4:
                // Already on profile settings
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'home',
                color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor!,
                size: 6.w,
              ),
              activeIcon: CustomIconWidget(
                iconName: 'home',
                color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .selectedItemColor!,
                size: 6.w,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'search',
                color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor!,
                size: 6.w,
              ),
              activeIcon: CustomIconWidget(
                iconName: 'search',
                color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .selectedItemColor!,
                size: 6.w,
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'payment',
                color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor!,
                size: 6.w,
              ),
              activeIcon: CustomIconWidget(
                iconName: 'payment',
                color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .selectedItemColor!,
                size: 6.w,
              ),
              label: 'Payment',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'confirmation_number',
                color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor!,
                size: 6.w,
              ),
              activeIcon: CustomIconWidget(
                iconName: 'confirmation_number',
                color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .selectedItemColor!,
                size: 6.w,
              ),
              label: 'Tickets',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'person',
                color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor!,
                size: 6.w,
              ),
              activeIcon: CustomIconWidget(
                iconName: 'person',
                color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .selectedItemColor!,
                size: 6.w,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
