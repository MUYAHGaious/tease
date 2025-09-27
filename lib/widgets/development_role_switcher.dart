import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../core/app_state.dart';
import '../models/user_model.dart';
import '../services/role_ui_service.dart';

// 2025 Design Constants
const Color primaryColor = Color(0xFF008B8B);
const double cardBorderRadius = 16.0;

class DevelopmentRoleSwitcher extends StatefulWidget {
  const DevelopmentRoleSwitcher({super.key});

  @override
  State<DevelopmentRoleSwitcher> createState() =>
      _DevelopmentRoleSwitcherState();
}

class _DevelopmentRoleSwitcherState extends State<DevelopmentRoleSwitcher> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final mockUsers = appState.getMockUsers();
    final currentUser = appState.currentUser;

    return Positioned(
      top: 10.h,
      right: 5.w,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.9),
                Colors.black.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(cardBorderRadius),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(cardBorderRadius),
                  topRight: Radius.circular(cardBorderRadius),
                ),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(1.5.w),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.developer_mode,
                          color: primaryColor,
                          size: 4.w,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'DEV',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white70,
                        size: 4.w,
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded content
              if (_isExpanded) ...[
                Container(
                  height: 1,
                  color: primaryColor.withOpacity(0.3),
                ),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 50.h,
                    maxWidth: 80.w,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(2.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Current user info
                        if (currentUser != null) ...[
                          Text(
                            'Current User:',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          _buildCurrentUserCard(currentUser),
                          SizedBox(height: 2.h),
                        ],

                        Text(
                          'Switch Role:',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),

                        // User role options
                        ...mockUsers.map((user) => _buildUserOption(user)),

                        SizedBox(height: 1.h),

                        // Logout option
                        _buildLogoutOption(),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentUserCard(UserModel user) {
    return Container(
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  user.fullName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (RoleUIService.getRoleBadge(user) != null)
                RoleUIService.getRoleBadge(user)!,
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            user.email,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 8.sp,
            ),
          ),
          if (user.affiliation != null) ...[
            SizedBox(height: 0.5.h),
            Text(
              'Affiliation: ${user.affiliation}',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 7.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserOption(UserModel user) {
    final appState = AppState();
    final isCurrentUser = appState.currentUser?.id == user.id;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCurrentUser ? null : () => _switchToUser(user),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? primaryColor.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isCurrentUser
                    ? primaryColor.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: RoleUIService.getRoleColor(user).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.w),
                    border: Border.all(
                      color: RoleUIService.getRoleColor(user).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getRoleIcon(user),
                    color: RoleUIService.getRoleColor(user),
                    size: 4.w,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.firstName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _getRoleDisplayName(user),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 7.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrentUser)
                  Icon(
                    Icons.check_circle,
                    color: primaryColor,
                    size: 4.w,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutOption() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _logout,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 4.w,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon(UserModel user) {
    switch (user.role) {
      case 'conductor':
        return Icons.person_pin;
      case 'driver':
        return Icons.drive_eta;
      case 'booking_clerk':
        return Icons.book_online;
      case 'schedule_manager':
        return Icons.admin_panel_settings;
      default:
        if (user.isUniversityAffiliated) {
          return user.position == 'student' ? Icons.school : Icons.work;
        }
        return Icons.person;
    }
  }

  String _getRoleDisplayName(UserModel user) {
    switch (user.role) {
      case 'conductor':
        return 'Bus Conductor';
      case 'driver':
        return 'Bus Driver';
      case 'booking_clerk':
        return 'Booking Clerk';
      case 'schedule_manager':
        return 'Schedule Manager';
      default:
        if (user.isUniversityAffiliated) {
          return user.position == 'student'
              ? 'University Student'
              : 'University Staff';
        }
        return 'Regular User';
    }
  }

  Future<void> _switchToUser(UserModel user) async {
    final appState = AppState();
    final success = await appState.quickLogin(user);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to ${user.fullName}'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Close the switcher
      setState(() {
        _isExpanded = false;
      });
    }
  }

  Future<void> _logout() async {
    final appState = AppState();
    await appState.logout();

    if (mounted) {
      setState(() {
        _isExpanded = false;
      });
    }
  }
}
