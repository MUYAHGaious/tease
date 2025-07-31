import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_drawer.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _staggerController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _staggerAnimation;

  // Color Palette
  static const Color darkGreen = Color(0xFF1B4D3E);
  static const Color secondaryGreen = Color(0xFF2D5A47);
  static const Color accentYellow = Color(0xFFFFD700);
  static const Color brightYellow = Color(0xFFF4D03F);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFE8E8E8);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);

  // Mock user data
  final Map<String, dynamic> _userData = {
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+237 678 123 456",
    "membershipType": "Premium",
    "totalTrips": 24,
    "savedAmount": 4500,
    "joinDate": "January 2024",
    "walletBalance": "25,000",
    "loyaltyPoints": 1250,
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _staggerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Curves.easeOutQuart,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _onMenuItemTap(String action) {
    HapticFeedback.lightImpact();
    switch (action) {
      case 'personal_info':
        _showComingSoonDialog('Personal Information');
        break;
      case 'payment_methods':
        _showComingSoonDialog('Payment Methods');
        break;
      case 'notifications':
        _showComingSoonDialog('Notifications');
        break;
      case 'security':
        _showComingSoonDialog('Security Settings');
        break;
      case 'help':
        Navigator.pushNamed(context, '/help');
        break;
      case 'about':
        _showComingSoonDialog('About');
        break;
      case 'logout':
        _handleLogout();
        break;
      default:
        _showComingSoonDialog(action);
    }
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: accentYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.construction,
                color: accentYellow,
                size: 6.w,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: whiteText,
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        content: Text(
          '$feature is under development and will be available soon!',
          style: TextStyle(
            color: lightGray,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: accentYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: errorRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.logout,
                color: errorRed,
                size: 6.w,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'Logout',
              style: TextStyle(
                color: whiteText,
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: lightGray,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: lightGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.splashScreen);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: errorRed,
              foregroundColor: whiteText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen,
      drawer: const CustomDrawer(),
      body: _isLoading ? _buildLoadingState() : _buildMainContent(),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [darkGreen, secondaryGreen],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [accentYellow, brightYellow],
                ),
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: darkGreen,
                  strokeWidth: 3,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Logging out...',
              style: TextStyle(
                color: whiteText,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [darkGreen, secondaryGreen],
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    _buildStatsCards(),
                    SizedBox(height: 4.h),
                    _buildMenuSections(),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 35.h,
      pinned: true,
      backgroundColor: darkGreen,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: Icon(
            Icons.menu,
            color: whiteText,
            size: 7.w,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _onMenuItemTap('notifications'),
          icon: Stack(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: whiteText,
                size: 7.w,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 3.w,
                  height: 3.w,
                  decoration: BoxDecoration(
                    color: errorRed,
                    borderRadius: BorderRadius.circular(1.5.w),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 2.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildProfileHeader(),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(6.w, 12.h, 6.w, 4.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Profile Avatar with Animation
          Hero(
            tag: 'profile_avatar',
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [accentYellow, brightYellow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.w),
                boxShadow: [
                  BoxShadow(
                    color: accentYellow.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'JD',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          
          // Name and Email
          Text(
            _userData['name'],
            style: TextStyle(
              color: whiteText,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _userData['email'],
            style: TextStyle(
              color: lightGray,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          
          // Membership Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [accentYellow, brightYellow],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: accentYellow.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.diamond,
                  color: darkGreen,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  '${_userData['membershipType']} Member',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return AnimatedBuilder(
      animation: _staggerAnimation,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Row(
            children: [
              Expanded(
                child: Transform.translate(
                  offset: Offset(0, (1 - _staggerAnimation.value) * 50),
                  child: Opacity(
                    opacity: _staggerAnimation.value,
                    child: _buildStatCard(
                      'Total Trips',
                      '${_userData['totalTrips']}',
                      Icons.directions_bus,
                      successGreen,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Transform.translate(
                  offset: Offset(0, (1 - _staggerAnimation.value) * 50),
                  child: Opacity(
                    opacity: _staggerAnimation.value,
                    child: _buildStatCard(
                      'Wallet',
                      'XFA ${_userData['walletBalance']}',
                      Icons.account_balance_wallet,
                      accentYellow,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: secondaryGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 8.w,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              color: whiteText,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: TextStyle(
              color: lightGray,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSections() {
    return AnimatedBuilder(
      animation: _staggerAnimation,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            children: [
              Transform.translate(
                offset: Offset(0, (1 - _staggerAnimation.value) * 30),
                child: Opacity(
                  opacity: _staggerAnimation.value,
                  child: _buildMenuSection(
                    'Account Settings',
                    [
                      _buildMenuItem(
                        'Personal Information',
                        'Manage your profile details',
                        Icons.person_outline,
                        'personal_info',
                      ),
                      _buildMenuItem(
                        'Payment Methods',
                        'Cards and payment options',
                        Icons.payment,
                        'payment_methods',
                      ),
                      _buildMenuItem(
                        'Security & Privacy',
                        'Password and privacy settings',
                        Icons.security,
                        'security',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Transform.translate(
                offset: Offset(0, (1 - _staggerAnimation.value) * 30),
                child: Opacity(
                  opacity: _staggerAnimation.value,
                  child: _buildMenuSection(
                    'Support & Info',
                    [
                      _buildMenuItem(
                        'Help & FAQ',
                        'Get help and support',
                        Icons.help_outline,
                        'help',
                      ),
                      _buildMenuItem(
                        'About Tease',
                        'App version and information',
                        Icons.info_outline,
                        'about',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Transform.translate(
                offset: Offset(0, (1 - _staggerAnimation.value) * 30),
                child: Opacity(
                  opacity: _staggerAnimation.value,
                  child: _buildLogoutButton(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 4.w, 5.w, 2.w),
            child: Text(
              title,
              style: TextStyle(
                color: whiteText,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, String subtitle, IconData icon, String action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onMenuItemTap(action),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [accentYellow, brightYellow],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: darkGreen,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: whiteText,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: lightGray,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: lightGray,
                size: 6.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 7.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [errorRed, errorRed.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: errorRed.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onMenuItemTap('logout'),
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: whiteText,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: whiteText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}